import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/store_hierarchy.dart';
import '../../domain/services/item_text_parser.dart';
import '../local/app_database.dart';
import '../models/procesar_lista_response.dart';
import '../services/ai_classifier_service.dart';

class ShoppingActionException implements Exception {
  const ShoppingActionException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AddItemsOutcome {
  const AddItemsOutcome({
    required this.addedCount,
    required this.fromLocalCount,
    required this.fromAiCount,
    required this.savedOfflineCount,
    this.quotaInfo,
  });

  final int addedCount;
  final int fromLocalCount;
  final int fromAiCount;
  final int savedOfflineCount;
  final AiQuotaInfo? quotaInfo;
}

class ShoppingRepository {
  ShoppingRepository({
    required this._db,
    required this._aiClassifier,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final AiClassifierService _aiClassifier;
  final Uuid _uuid;

  bool _isReprocessing = false;

  // ---------------------------------------------------------------------------
  // Streams & Queries
  // ---------------------------------------------------------------------------

  Stream<UserPreferencesEntity> watchPreferences() {
    final query = _db.select(_db.localPreferences)
      ..where((t) => t.id.equals(1));
    return query.watchSingleOrNull().map(
      (row) =>
          row ??
          const UserPreferencesEntity(
            id: 1,
            city: StoreHierarchy.defaultCity,
            themeMode: 'system',
            onboardingCompleted: false,
            keepScreenOn: true,
          ),
    );
  }

  Stream<List<ShoppingListEntity>> watchLists() {
    final query = _db.select(_db.localLists)
      ..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc),
      ]);
    return query.watch();
  }

  Stream<List<ShoppingItemEntity>> watchItemsForList(String listId) {
    final query = _db.select(_db.localItems)
      ..where((t) => t.listId.equals(listId))
      ..orderBy([
        (t) => OrderingTerm(expression: t.isChecked, mode: OrderingMode.asc),
        (t) => OrderingTerm(expression: t.position, mode: OrderingMode.asc),
        (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.asc),
      ]);
    return query.watch();
  }

  Stream<Map<(String, String), int>> watchAisleOrderMap() {
    return _db.select(_db.localAisleOrder).watch().map((rows) {
      return <(String, String), int>{
        for (final row in rows)
          (row.storeCategory, row.aisleName): row.sortOrder,
      };
    });
  }

  Future<Map<(String, String), int>> getAisleOrderMap() async {
    final rows = await _db.select(_db.localAisleOrder).get();
    return <(String, String), int>{
      for (final row in rows) (row.storeCategory, row.aisleName): row.sortOrder,
    };
  }

  Stream<int> watchPendingAiCount(String listId) {
    final query = _db.select(_db.localItems)
      ..where(
        (t) => t.listId.equals(listId) & t.syncStatus.equals('pending_ai'),
      );
    return query.watch().map((rows) => rows.length);
  }

  // ---------------------------------------------------------------------------
  // Lists CRUD (Max 3 lists in Phase 2)
  // ---------------------------------------------------------------------------

  Future<String> createList(String rawTitle) async {
    final title = ItemTextParser.toSentenceCase(rawTitle);
    if (title.isEmpty) {
      throw const ShoppingActionException(AppStrings.invalidListNameError);
    }

    final existing = await _db.select(_db.localLists).get();
    if (existing.length >= StoreHierarchy.maxActiveListsPhase2) {
      throw const ShoppingActionException(AppStrings.maxListsReached);
    }

    final id = _uuid.v4();
    final now = DateTime.now();
    await _db
        .into(_db.localLists)
        .insert(
          LocalListsCompanion.insert(
            id: id,
            title: title,
            createdAt: now,
            updatedAt: now,
            syncStatus: const Value('pending'),
          ),
        );
    return id;
  }

  Future<void> renameList(String listId, String rawTitle) async {
    final title = ItemTextParser.toSentenceCase(rawTitle);
    if (title.isEmpty) {
      throw const ShoppingActionException(AppStrings.invalidListNameError);
    }

    await (_db.update(_db.localLists)..where((t) => t.id.equals(listId))).write(
      LocalListsCompanion(
        title: Value(title),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }

  Future<void> deleteList(String listId) async {
    final existing = await _db.select(_db.localLists).get();
    if (existing.length <= 1) {
      throw const ShoppingActionException(AppStrings.cannotDeleteLastList);
    }

    await (_db.delete(_db.localLists)..where((t) => t.id.equals(listId))).go();
  }

  // ---------------------------------------------------------------------------
  // Smart Input + Learned Items Token-Saving + Offline Fallback
  // ---------------------------------------------------------------------------

  Future<AddItemsOutcome> addItemsFromInput({
    required String listId,
    required String rawInput,
    required bool isOnline,
  }) async {
    final parseResult = ItemTextParser.parseInput(rawInput);
    if (parseResult.originalText.isEmpty) {
      throw const ShoppingActionException(AppStrings.emptyInputError);
    }

    var localAdded = 0;
    var aiAdded = 0;
    var offlineAdded = 0;
    AiQuotaInfo? quotaInfo;
    String? textForAi;
    var candidatesForOffline = parseResult.candidates;

    if (!parseResult.isComplex && parseResult.candidates.isNotEmpty) {
      final normalizedKeys = parseResult.candidates
          .map((c) => c.normalizedName)
          .where((k) => k.isNotEmpty)
          .toSet()
          .toList();

      final learnedRows = normalizedKeys.isEmpty
          ? const <LearnedItemEntity>[]
          : await (_db.select(
              _db.localLearnedItems,
            )..where((t) => t.normalizedName.isIn(normalizedKeys))).get();

      final learnedByKey = <String, LearnedItemEntity>{
        for (final row in learnedRows) row.normalizedName: row,
      };

      final matched = <(ParsedCandidate, LearnedItemEntity)>[];
      final unknown = <ParsedCandidate>[];

      for (final candidate in parseResult.candidates) {
        final found = learnedByKey[candidate.normalizedName];
        if (found != null) {
          matched.add((candidate, found));
        } else {
          unknown.add(candidate);
        }
      }

      if (matched.isNotEmpty) {
        await _insertMatchedLocalItems(listId, matched);
        localAdded = matched.length;
      }

      if (unknown.isEmpty) {
        return AddItemsOutcome(
          addedCount: localAdded,
          fromLocalCount: localAdded,
          fromAiCount: 0,
          savedOfflineCount: 0,
        );
      }

      candidatesForOffline = unknown;
      textForAi = unknown.map((c) => c.rawText).join(', ');
    } else {
      textForAi = parseResult.originalText;
    }

    if (!isOnline) {
      offlineAdded = await _insertOfflinePendingItems(
        listId,
        candidatesForOffline.isEmpty
            ? <ParsedCandidate>[
                ItemTextParser.parseSingleSegment(parseResult.originalText),
              ]
            : candidatesForOffline,
      );
      return AddItemsOutcome(
        addedCount: localAdded + offlineAdded,
        fromLocalCount: localAdded,
        fromAiCount: 0,
        savedOfflineCount: offlineAdded,
      );
    }

    try {
      final response = await _aiClassifier.classifyText(textForAi);
      quotaInfo = response.quota;
      aiAdded = await _insertAiItemsAndLearn(
        listId: listId,
        rawText: textForAi,
        items: response.items,
      );
      return AddItemsOutcome(
        addedCount: localAdded + aiAdded,
        fromLocalCount: localAdded,
        fromAiCount: aiAdded,
        savedOfflineCount: 0,
        quotaInfo: quotaInfo,
      );
    } on AiOfflineOrNetworkException {
      offlineAdded = await _insertOfflinePendingItems(
        listId,
        candidatesForOffline.isEmpty
            ? <ParsedCandidate>[
                ItemTextParser.parseSingleSegment(parseResult.originalText),
              ]
            : candidatesForOffline,
      );
      return AddItemsOutcome(
        addedCount: localAdded + offlineAdded,
        fromLocalCount: localAdded,
        fromAiCount: 0,
        savedOfflineCount: offlineAdded,
      );
    }
  }

  /// Automatically reprocesses any items stored with `syncStatus == 'pending_ai'`
  /// when connectivity returns. Returns the number of resolved offline items.
  Future<int> reprocessPendingAiItems() async {
    if (_isReprocessing) return 0;
    _isReprocessing = true;

    try {
      final pendingRows =
          await (_db.select(_db.localItems)
                ..where((t) => t.syncStatus.equals('pending_ai'))
                ..orderBy([
                  (t) => OrderingTerm(
                    expression: t.position,
                    mode: OrderingMode.asc,
                  ),
                ]))
              .get();

      if (pendingRows.isEmpty) {
        return 0;
      }

      // Group by list so each list is sent in a single token-saving AI request.
      final byList = <String, List<ShoppingItemEntity>>{};
      for (final row in pendingRows) {
        byList.putIfAbsent(row.listId, () => <ShoppingItemEntity>[]).add(row);
      }

      var resolvedCount = 0;

      for (final entry in byList.entries) {
        final listId = entry.key;
        final rows = entry.value;
        final combinedText = rows.map((r) => r.rawText).join('\n');

        final response = await _aiClassifier.classifyText(combinedText);
        if (response.items.isEmpty) {
          continue;
        }

        final resolved = await _replacePendingRowsWithAiResults(
          listId: listId,
          pendingRows: rows,
          aiItems: response.items,
        );
        resolvedCount += resolved;
      }

      return resolvedCount;
    } finally {
      _isReprocessing = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Item interactions
  // ---------------------------------------------------------------------------

  Future<void> toggleItemChecked(ShoppingItemEntity item) async {
    final now = DateTime.now();
    await (_db.update(
      _db.localItems,
    )..where((t) => t.id.equals(item.id))).write(
      LocalItemsCompanion(
        isChecked: Value(!item.isChecked),
        updatedAt: Value(now),
      ),
    );
    await _touchList(item.listId, now);
  }

  Future<void> updateItemAndLearn({
    required ShoppingItemEntity original,
    required String cleanName,
    required double quantity,
    required String unit,
    required String storeCategory,
    required String aisleName,
  }) async {
    final trimmedName = ItemTextParser.toSentenceCase(cleanName);
    if (trimmedName.isEmpty) {
      throw const ShoppingActionException(AppStrings.invalidItemNameError);
    }

    final normalizedStore = StoreHierarchy.normalizeStore(storeCategory);
    final normalizedAisle = StoreHierarchy.normalizeAisle(
      normalizedStore,
      aisleName,
    );
    final safeQty = quantity > 0 ? quantity : 1.0;
    final safeUnit = unit.trim().isEmpty
        ? 'u'
        : ItemTextParser.normalizeUnit(unit);
    final now = DateTime.now();

    await _db.transaction(() async {
      await (_db.update(
        _db.localItems,
      )..where((t) => t.id.equals(original.id))).write(
        LocalItemsCompanion(
          cleanName: Value(trimmedName),
          quantity: Value(safeQty),
          unit: Value(safeUnit),
          storeCategory: Value(normalizedStore),
          aisleName: Value(normalizedAisle),
          updatedAt: Value(now),
          // Clear 'pending_ai' if the user already organized it manually.
          syncStatus: const Value('pending'),
        ),
      );

      await _ensureAisleOrderExists(normalizedStore, normalizedAisle);

      final learnedKey = ItemTextParser.normalizeProductName(trimmedName);
      if (learnedKey.isNotEmpty) {
        final existingLearned = await (_db.select(
          _db.localLearnedItems,
        )..where((t) => t.normalizedName.equals(learnedKey))).getSingleOrNull();

        await _db
            .into(_db.localLearnedItems)
            .insertOnConflictUpdate(
              LocalLearnedItemsCompanion.insert(
                normalizedName: learnedKey,
                preferredStore: normalizedStore,
                preferredAisle: normalizedAisle,
                useCount: Value((existingLearned?.useCount ?? 0) + 1),
                updatedAt: now,
              ),
            );
      }

      await _touchList(original.listId, now);
    });
  }

  Future<void> deleteItem(ShoppingItemEntity item) async {
    await (_db.delete(_db.localItems)..where((t) => t.id.equals(item.id))).go();
    await _touchList(item.listId, DateTime.now());
  }

  // ---------------------------------------------------------------------------
  // Preferences
  // ---------------------------------------------------------------------------

  Future<void> updatePreferences({
    String? city,
    String? themeMode,
    bool? onboardingCompleted,
    bool? keepScreenOn,
  }) async {
    await _db
        .into(_db.localPreferences)
        .insertOnConflictUpdate(
          LocalPreferencesCompanion(
            id: const Value(1),
            city: city != null ? Value(city) : const Value.absent(),
            themeMode: themeMode != null
                ? Value(themeMode)
                : const Value.absent(),
            onboardingCompleted: onboardingCompleted != null
                ? Value(onboardingCompleted)
                : const Value.absent(),
            keepScreenOn: keepScreenOn != null
                ? Value(keepScreenOn)
                : const Value.absent(),
          ),
        );
  }

  // ---------------------------------------------------------------------------
  // Internal transaction helpers
  // ---------------------------------------------------------------------------

  Future<void> _insertMatchedLocalItems(
    String listId,
    List<(ParsedCandidate, LearnedItemEntity)> matched,
  ) async {
    final now = DateTime.now();
    await _db.transaction(() async {
      var nextPos = await _nextPosition(listId);
      final companions = <LocalItemsCompanion>[];

      for (final (candidate, learned) in matched) {
        companions.add(
          LocalItemsCompanion.insert(
            id: _uuid.v4(),
            listId: listId,
            rawText: candidate.rawText,
            cleanName: candidate.cleanName,
            quantity: Value(candidate.quantity),
            unit: Value(candidate.unit),
            storeCategory: learned.preferredStore,
            aisleName: learned.preferredAisle,
            isChecked: const Value(false),
            position: Value(nextPos++),
            updatedAt: now,
            syncStatus: const Value('pending'),
          ),
        );

        await (_db.update(
          _db.localLearnedItems,
        )..where((t) => t.normalizedName.equals(learned.normalizedName))).write(
          LocalLearnedItemsCompanion(
            useCount: Value(learned.useCount + 1),
            updatedAt: Value(now),
          ),
        );
      }

      await _db.batch((b) => b.insertAll(_db.localItems, companions));
      await _touchList(listId, now);
    });
  }

  Future<int> _insertOfflinePendingItems(
    String listId,
    List<ParsedCandidate> candidates,
  ) async {
    final now = DateTime.now();
    await _db.transaction(() async {
      var nextPos = await _nextPosition(listId);
      final companions = candidates.map((c) {
        return LocalItemsCompanion.insert(
          id: _uuid.v4(),
          listId: listId,
          rawText: c.rawText,
          cleanName: c.cleanName,
          quantity: Value(c.quantity),
          unit: Value(c.unit),
          storeCategory: StoreHierarchy.fallbackStore,
          aisleName: StoreHierarchy.offlinePendingAisle,
          isChecked: const Value(false),
          position: Value(nextPos++),
          updatedAt: now,
          syncStatus: const Value('pending_ai'),
        );
      }).toList();

      await _db.batch((b) => b.insertAll(_db.localItems, companions));
      await _touchList(listId, now);
    });
    return candidates.length;
  }

  Future<int> _insertAiItemsAndLearn({
    required String listId,
    required String rawText,
    required List<ProcessedAiItem> items,
  }) async {
    if (items.isEmpty) return 0;
    final now = DateTime.now();

    await _db.transaction(() async {
      var nextPos = await _nextPosition(listId);
      final companions = <LocalItemsCompanion>[];

      for (final item in items) {
        final key = ItemTextParser.normalizeProductName(item.cleanName);
        final learned = key.isEmpty
            ? null
            : await (_db.select(
                _db.localLearnedItems,
              )..where((t) => t.normalizedName.equals(key))).getSingleOrNull();

        // Respect prior user corrections if already learned locally.
        final store = learned?.preferredStore ?? item.storeCategory;
        final aisle = learned?.preferredAisle ?? item.aisleName;

        companions.add(
          LocalItemsCompanion.insert(
            id: _uuid.v4(),
            listId: listId,
            rawText: rawText,
            cleanName: item.cleanName,
            quantity: Value(item.quantity),
            unit: Value(item.unit),
            storeCategory: store,
            aisleName: aisle,
            isChecked: const Value(false),
            position: Value(nextPos++),
            updatedAt: now,
            syncStatus: const Value('pending'),
          ),
        );

        await _ensureAisleOrderExists(store, aisle);
        if (key.isNotEmpty) {
          if (learned == null) {
            await _db
                .into(_db.localLearnedItems)
                .insert(
                  LocalLearnedItemsCompanion.insert(
                    normalizedName: key,
                    preferredStore: store,
                    preferredAisle: aisle,
                    useCount: const Value(1),
                    updatedAt: now,
                  ),
                  mode: InsertMode.insertOrIgnore,
                );
          } else {
            await (_db.update(
              _db.localLearnedItems,
            )..where((t) => t.normalizedName.equals(key))).write(
              LocalLearnedItemsCompanion(
                useCount: Value(learned.useCount + 1),
                updatedAt: Value(now),
              ),
            );
          }
        }
      }

      await _db.batch((b) => b.insertAll(_db.localItems, companions));
      await _touchList(listId, now);
    });

    return items.length;
  }

  Future<int> _replacePendingRowsWithAiResults({
    required String listId,
    required List<ShoppingItemEntity> pendingRows,
    required List<ProcessedAiItem> aiItems,
  }) async {
    final now = DateTime.now();
    var replacedCount = 0;

    await _db.transaction(() async {
      final candidateIds = pendingRows.map((r) => r.id).toList();
      final stillPending =
          await (_db.select(_db.localItems)..where(
                (t) =>
                    t.id.isIn(candidateIds) & t.syncStatus.equals('pending_ai'),
              ))
              .get();

      if (stillPending.isEmpty) {
        return;
      }

      final checkedByNormalizedName = <String, bool>{};
      for (final row in stillPending) {
        if (row.isChecked) {
          checkedByNormalizedName[ItemTextParser.normalizeProductName(
                row.cleanName,
              )] =
              true;
        }
      }
      final singleWasChecked =
          stillPending.length == 1 && stillPending.first.isChecked;

      final minPos = stillPending
          .map((r) => r.position)
          .reduce((a, b) => a < b ? a : b);
      var pos = minPos;

      await (_db.delete(
        _db.localItems,
      )..where((t) => t.id.isIn(stillPending.map((r) => r.id)))).go();

      final companions = <LocalItemsCompanion>[];
      for (var i = 0; i < aiItems.length; i++) {
        final item = aiItems[i];
        final key = ItemTextParser.normalizeProductName(item.cleanName);
        final learned = key.isEmpty
            ? null
            : await (_db.select(
                _db.localLearnedItems,
              )..where((t) => t.normalizedName.equals(key))).getSingleOrNull();

        final store = learned?.preferredStore ?? item.storeCategory;
        final aisle = learned?.preferredAisle ?? item.aisleName;
        final isChecked = singleWasChecked
            ? true
            : (checkedByNormalizedName[key] ?? false);

        companions.add(
          LocalItemsCompanion.insert(
            id: _uuid.v4(),
            listId: listId,
            rawText: stillPending.length == 1
                ? stillPending.first.rawText
                : item.cleanName,
            cleanName: item.cleanName,
            quantity: Value(item.quantity),
            unit: Value(item.unit),
            storeCategory: store,
            aisleName: aisle,
            isChecked: Value(isChecked),
            position: Value(pos++),
            updatedAt: now,
            syncStatus: const Value('pending'),
          ),
        );

        await _ensureAisleOrderExists(store, aisle);
        if (key.isNotEmpty) {
          await _db
              .into(_db.localLearnedItems)
              .insertOnConflictUpdate(
                LocalLearnedItemsCompanion.insert(
                  normalizedName: key,
                  preferredStore: store,
                  preferredAisle: aisle,
                  useCount: Value((learned?.useCount ?? 0) + 1),
                  updatedAt: now,
                ),
              );
        }
      }

      await _db.batch((b) => b.insertAll(_db.localItems, companions));
      await _touchList(listId, now);
      replacedCount = stillPending.length;
    });

    return replacedCount;
  }

  Future<int> _nextPosition(String listId) async {
    final rows =
        await (_db.select(_db.localItems)
              ..where((t) => t.listId.equals(listId))
              ..orderBy([
                (t) => OrderingTerm(
                  expression: t.position,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(1))
            .get();
    if (rows.isEmpty) return 0;
    return rows.first.position + 1;
  }

  Future<void> _ensureAisleOrderExists(String store, String aisle) async {
    await _db
        .into(_db.localAisleOrder)
        .insert(
          LocalAisleOrderCompanion.insert(
            storeCategory: store,
            aisleName: aisle,
            sortOrder: 500,
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> _touchList(String listId, DateTime now) async {
    await (_db.update(_db.localLists)..where((t) => t.id.equals(listId))).write(
      LocalListsCompanion(updatedAt: Value(now)),
    );
  }
}
