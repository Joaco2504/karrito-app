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
            soundEnabled: true,
            vibrationEnabled: true,
            remindersEnabled: false,
            avatarChoice: 'avatar_1',
            planTier: 'free',
            freeMaxLists: 3,
            basicMaxLists: 10,
            proMaxLists: 999,
          ),
    );
  }

  Stream<List<ExpenseHistoryEntity>> watchExpenseHistory() {
    final query = _db.select(_db.localExpenseHistory)
      ..orderBy([
        (t) => OrderingTerm(expression: t.recordedAt, mode: OrderingMode.desc),
      ]);
    return query.watch();
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

  Stream<List<LearnedItemEntity>> watchLearnedItems() {
    final query = _db.select(_db.localLearnedItems)
      ..orderBy([
        (t) => OrderingTerm(expression: t.useCount, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
      ]);
    return query.watch();
  }

  Stream<int> watchPendingAiCount(String listId) {
    final query = _db.select(_db.localItems)
      ..where(
        (t) => t.listId.equals(listId) & t.syncStatus.equals('pending_ai'),
      );
    return query.watch().map((rows) => rows.length);
  }

  // ---------------------------------------------------------------------------
  // Lists CRUD (Max 3 owned lists in free mode)
  // ---------------------------------------------------------------------------

  Future<String> createList(
    String rawTitle, {
    String? ownerId,
    int? maxActiveLists,
  }) async {
    final title = ItemTextParser.toSentenceCase(rawTitle);
    if (title.isEmpty) {
      throw const ShoppingActionException(AppStrings.invalidListNameError);
    }

    final existing = await _db.select(_db.localLists).get();
    final ownedCount = existing.where((l) => !l.isJoinedRemote).length;
    final effectiveLimit =
        maxActiveLists ?? StoreHierarchy.maxActiveListsPhase2;
    if (ownedCount >= effectiveLimit) {
      throw ShoppingActionException(
        AppStrings.maxListsReachedForLimit(effectiveLimit),
      );
    }

    final id = _uuid.v4();
    final now = DateTime.now();
    await _db
        .into(_db.localLists)
        .insert(
          LocalListsCompanion.insert(
            id: id,
            title: title,
            ownerId: Value(ownerId),
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

    ShoppingListEntity? target;
    for (final list in existing) {
      if (list.id == listId) {
        target = list;
        break;
      }
    }

    await _db.transaction(() async {
      if (target != null) {
        await _db
            .into(_db.localPendingDeletions)
            .insert(
              LocalPendingDeletionsCompanion.insert(
                id: _uuid.v4(),
                entityType: 'list',
                entityKey: listId,
                isLeaveOnly: Value(target.isJoinedRemote),
                deletedAt: DateTime.now(),
              ),
            );
      }
      await (_db.delete(
        _db.localLists,
      )..where((t) => t.id.equals(listId))).go();
    });
  }

  /// Unlinks the current user from a remote shared list (`isJoinedRemote`) and
  /// removes the local copy. If it was the only local list, creates a fresh
  /// personal list so the app always keeps an active list.
  Future<String?> leaveSharedList(String listId) async {
    final existing = await _db.select(_db.localLists).get();
    ShoppingListEntity? target;
    for (final list in existing) {
      if (list.id == listId) {
        target = list;
        break;
      }
    }
    if (target == null) return null;

    String? replacementListId;
    await _db.transaction(() async {
      await _db
          .into(_db.localPendingDeletions)
          .insert(
            LocalPendingDeletionsCompanion.insert(
              id: _uuid.v4(),
              entityType: 'list',
              entityKey: listId,
              isLeaveOnly: const Value(true),
              deletedAt: DateTime.now(),
            ),
          );
      await (_db.delete(
        _db.localLists,
      )..where((t) => t.id.equals(listId))).go();

      if (existing.length <= 1) {
        final now = DateTime.now();
        final freshId = _uuid.v4();
        replacementListId = freshId;
        await _db
            .into(_db.localLists)
            .insert(
              LocalListsCompanion.insert(
                id: freshId,
                title: 'Mi lista',
                createdAt: now,
                updatedAt: now,
                syncStatus: const Value('pending'),
              ),
            );
      }
    });
    return replacementListId;
  }

  // ---------------------------------------------------------------------------
  // Aisle Ordering & Frequent Items
  // ---------------------------------------------------------------------------

  Future<List<String>> getAislesForStore(String storeCategory) async {
    final normalizedStore = StoreHierarchy.normalizeStore(storeCategory);
    final orderRows = await (_db.select(
      _db.localAisleOrder,
    )..where((t) => t.storeCategory.equals(normalizedStore))).get();
    final itemRows = await (_db.select(
      _db.localItems,
    )..where((t) => t.storeCategory.equals(normalizedStore))).get();

    final orderMap = <String, int>{
      for (final row in orderRows) row.aisleName: row.sortOrder,
    };

    final candidates = <String>{
      ...(StoreHierarchy.storeAisles[normalizedStore] ?? const <String>[]),
      ...orderRows.map((r) => r.aisleName),
      ...itemRows.map((r) => r.aisleName),
    }..remove(StoreHierarchy.offlinePendingAisle);

    final sorted = candidates.toList()
      ..sort((a, b) {
        final orderA = orderMap[a] ?? 500;
        final orderB = orderMap[b] ?? 500;
        if (orderA != orderB) return orderA.compareTo(orderB);
        return a.compareTo(b);
      });

    return sorted;
  }

  Future<void> saveAisleOrder({
    required String storeCategory,
    required List<String> orderedAisles,
  }) async {
    final normalizedStore = StoreHierarchy.normalizeStore(storeCategory);
    final now = DateTime.now();

    await _db.transaction(() async {
      for (var i = 0; i < orderedAisles.length; i++) {
        final aisle = orderedAisles[i];
        await _db
            .into(_db.localAisleOrder)
            .insertOnConflictUpdate(
              LocalAisleOrderCompanion.insert(
                storeCategory: normalizedStore,
                aisleName: aisle,
                sortOrder: (i + 1) * 10,
                updatedAt: Value(now),
                syncStatus: const Value('pending'),
              ),
            );
      }
    });
  }

  /// Adds a frequent product directly from `local_learned_items` into the
  /// active list with zero Gemini / `procesar-lista` API usage.
  Future<String> addLearnedItemToList({
    required String listId,
    required LearnedItemEntity learnedItem,
  }) async {
    final displayTitle = (learnedItem.displayName?.trim().isNotEmpty ?? false)
        ? learnedItem.displayName!.trim()
        : ItemTextParser.toSentenceCase(learnedItem.normalizedName);
    final now = DateTime.now();

    await _db.transaction(() async {
      final nextPos = await _nextPosition(listId);
      await _db
          .into(_db.localItems)
          .insert(
            LocalItemsCompanion.insert(
              id: _uuid.v4(),
              listId: listId,
              rawText: displayTitle,
              cleanName: displayTitle,
              quantity: const Value(1.0),
              unit: const Value('u'),
              storeCategory: learnedItem.preferredStore,
              aisleName: learnedItem.preferredAisle,
              isChecked: const Value(false),
              position: Value(nextPos),
              updatedAt: now,
              syncStatus: const Value('pending'),
            ),
          );

      await (_db.update(_db.localLearnedItems)
            ..where((t) => t.normalizedName.equals(learnedItem.normalizedName)))
          .write(
            LocalLearnedItemsCompanion(
              useCount: Value(learnedItem.useCount + 1),
              updatedAt: Value(now),
              syncStatus: const Value('pending'),
            ),
          );

      await _touchList(listId, now);
    });

    return displayTitle;
  }

  Future<void> removeLearnedItem(String normalizedName) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.localLearnedItems,
      )..where((t) => t.normalizedName.equals(normalizedName))).go();

      await _db
          .into(_db.localPendingDeletions)
          .insert(
            LocalPendingDeletionsCompanion.insert(
              id: _uuid.v4(),
              entityType: 'learned',
              entityKey: normalizedName,
              deletedAt: DateTime.now(),
            ),
          );
    });
  }

  // ---------------------------------------------------------------------------
  // Smart Input + Learned Items Token-Saving + Offline Fallback
  // ---------------------------------------------------------------------------

  Future<AddItemsOutcome> addItemsFromInput({
    required String listId,
    required String rawInput,
    required bool isOnline,
  }) async {
    final parseResult = await ItemTextParser.parseInputAsync(rawInput);
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

  /// Processes a Pro voice recording (M4A/AAC 48 kbps base64) via `procesar-lista`
  /// and inserts + learns all returned items in Drift.
  Future<AddItemsOutcome> addItemsFromAudio({
    required String listId,
    required String audioBase64,
    String mimeType = 'audio/m4a',
  }) async {
    final response = await _aiClassifier.classifyAudio(
      audioBase64: audioBase64,
      mimeType: mimeType,
    );
    final aiAdded = await _insertAiItemsAndLearn(
      listId: listId,
      rawText: 'Dictado por voz',
      items: response.items,
    );
    return AddItemsOutcome(
      addedCount: aiAdded,
      fromLocalCount: 0,
      fromAiCount: aiAdded,
      savedOfflineCount: 0,
      quotaInfo: response.quota,
    );
  }

  /// Processes a Pro photo or WhatsApp screenshot (JPEG <= 1024 px, 75% quality)
  /// via `procesar-lista` and inserts + learns all returned items in Drift.
  Future<AddItemsOutcome> addItemsFromImage({
    required String listId,
    required String imageBase64,
    String mimeType = 'image/jpeg',
  }) async {
    final response = await _aiClassifier.classifyImage(
      imageBase64: imageBase64,
      mimeType: mimeType,
    );
    final aiAdded = await _insertAiItemsAndLearn(
      listId: listId,
      rawText: 'Lista escaneada por foto',
      items: response.items,
    );
    return AddItemsOutcome(
      addedCount: aiAdded,
      fromLocalCount: 0,
      fromAiCount: aiAdded,
      savedOfflineCount: 0,
      quotaInfo: response.quota,
    );
  }

  /// Imports a recipe or hardware/DIY project text block (Pro feature).
  /// Still consults `local_learned_items` first when the pasted lines are simple,
  /// otherwise sends to `procesar-lista` to extract ingredients/materials.
  Future<AddItemsOutcome> importRecipeOrProject({
    required String listId,
    required String rawText,
    required bool isOnline,
  }) async {
    final trimmed = rawText.trim();
    if (trimmed.isEmpty) {
      throw const ShoppingActionException(AppStrings.recipeEmptyError);
    }
    if (!isOnline) {
      throw const ShoppingActionException(AppStrings.proMediaOfflineError);
    }

    final response = await _aiClassifier.classifyText(trimmed);
    final aiAdded = await _insertAiItemsAndLearn(
      listId: listId,
      rawText: trimmed,
      items: response.items,
    );
    return AddItemsOutcome(
      addedCount: aiAdded,
      fromLocalCount: 0,
      fromAiCount: aiAdded,
      savedOfflineCount: 0,
      quotaInfo: response.quota,
    );
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
        syncStatus: item.syncStatus == 'pending_ai'
            ? const Value.absent()
            : const Value('pending'),
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
    double? price,
    bool updatePrice = false,
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
          price: updatePrice ? Value<double?>(price) : const Value.absent(),
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
                displayName: Value(trimmedName),
                preferredStore: normalizedStore,
                preferredAisle: normalizedAisle,
                useCount: Value((existingLearned?.useCount ?? 0) + 1),
                updatedAt: now,
                syncStatus: const Value('pending'),
              ),
            );
      }

      await _touchList(original.listId, now);
    });
  }

  Future<void> deleteItem(ShoppingItemEntity item) async {
    await _db.transaction(() async {
      await _db
          .into(_db.localPendingDeletions)
          .insert(
            LocalPendingDeletionsCompanion.insert(
              id: _uuid.v4(),
              entityType: 'item',
              entityKey: item.id,
              deletedAt: DateTime.now(),
            ),
          );
      await (_db.delete(
        _db.localItems,
      )..where((t) => t.id.equals(item.id))).go();
      await _touchList(item.listId, DateTime.now());
    });
  }

  /// Removes all checked items in [listId] (optionally scoped to [storeCategory])
  /// and writes tombstones to `local_pending_deletions` so Supabase deletes them
  /// on the next sync. Returns the number of deleted items.
  Future<int> clearCheckedItems({
    required String listId,
    String? storeCategory,
  }) async {
    final now = DateTime.now();
    return _db.transaction(() async {
      final query = _db.select(_db.localItems)
        ..where((t) {
          final base = t.listId.equals(listId) & t.isChecked.equals(true);
          if (storeCategory != null) {
            return base & t.storeCategory.equals(storeCategory);
          }
          return base;
        });

      final checkedRows = await query.get();
      if (checkedRows.isEmpty) return 0;

      await _db.batch((batch) {
        batch.insertAll(
          _db.localPendingDeletions,
          checkedRows.map(
            (row) => LocalPendingDeletionsCompanion.insert(
              id: _uuid.v4(),
              entityType: 'item',
              entityKey: row.id,
              deletedAt: now,
            ),
          ),
        );
      });

      final ids = checkedRows.map((row) => row.id).toList();
      await (_db.delete(_db.localItems)..where((t) => t.id.isIn(ids))).go();
      await _touchList(listId, now);
      return checkedRows.length;
    });
  }

  // ---------------------------------------------------------------------------
  // Account Migration Helper & Preferences
  // ---------------------------------------------------------------------------

  /// Migrates local owned lists and preferences when a guest session switches
  /// to an existing permanent Google account UID.
  ///
  /// Regenerates fresh UUIDs for all non-joined local lists and their items so
  /// uploading them never collides with rows owned by the previous anonymous
  /// UID in Supabase (`42501` RLS violation), and resets `lastSyncedAt` so the
  /// first sync after switching pulls all remote data for the new account.
  /// Returns a map of `oldListId -> newListId` for remapping active UI state.
  Future<Map<String, String>> prepareLocalDataForAccountSwitch(
    String? newOwnerId,
  ) async {
    final remappedListIds = <String, String>{};
    final now = DateTime.now();

    await _db.transaction(() async {
      final ownedLists = await (_db.select(
        _db.localLists,
      )..where((t) => t.isJoinedRemote.equals(false))).get();

      for (final oldList in ownedLists) {
        final newListId = _uuid.v4();
        remappedListIds[oldList.id] = newListId;

        final oldItems = await (_db.select(
          _db.localItems,
        )..where((t) => t.listId.equals(oldList.id))).get();

        await _db
            .into(_db.localLists)
            .insert(
              LocalListsCompanion.insert(
                id: newListId,
                title: oldList.title,
                ownerId: Value(newOwnerId),
                isShared: const Value(false),
                shareCode: const Value(null),
                isJoinedRemote: const Value(false),
                createdAt: oldList.createdAt,
                updatedAt: now,
                syncStatus: const Value('pending'),
              ),
            );

        if (oldItems.isNotEmpty) {
          final newItemCompanions = oldItems.map((item) {
            return LocalItemsCompanion.insert(
              id: _uuid.v4(),
              listId: newListId,
              rawText: item.rawText,
              cleanName: item.cleanName,
              quantity: Value(item.quantity),
              unit: Value(item.unit),
              storeCategory: item.storeCategory,
              aisleName: item.aisleName,
              isChecked: Value(item.isChecked),
              position: Value(item.position),
              updatedAt: now,
              syncStatus: Value(
                item.syncStatus == 'pending_ai' ? 'pending_ai' : 'pending',
              ),
            );
          }).toList();

          await _db.batch(
            (b) => b.insertAll(_db.localItems, newItemCompanions),
          );
        }

        await (_db.delete(
          _db.localLists,
        )..where((t) => t.id.equals(oldList.id))).go();
      }

      await (_db.update(_db.localAisleOrder)
            ..where((t) => t.syncStatus.equals('synced')))
          .write(const LocalAisleOrderCompanion(syncStatus: Value('pending')));

      await (_db.update(
        _db.localLearnedItems,
      )..where((t) => t.syncStatus.equals('synced'))).write(
        const LocalLearnedItemsCompanion(syncStatus: Value('pending')),
      );

      // Clear guest-session tombstones so they never attempt deletions on another account.
      await _db.delete(_db.localPendingDeletions).go();

      // Force a full initial pull on the newly signed-in account.
      await (_db.update(_db.localPreferences)..where((t) => t.id.equals(1)))
          .write(const LocalPreferencesCompanion(lastSyncedAt: Value(null)));
    });

    return remappedListIds;
  }

  Future<void> updateItemPrice({
    required ShoppingItemEntity item,
    required double? price,
  }) async {
    final now = DateTime.now();
    await (_db.update(
      _db.localItems,
    )..where((t) => t.id.equals(item.id))).write(
      LocalItemsCompanion(
        price: Value<double?>(price != null && price > 0 ? price : null),
        updatedAt: Value(now),
      ),
    );
  }

  /// Records totals per store from priced items into `local_expense_history`.
  /// Returns `(storesRecorded, totalRecorded)`.
  Future<({int storesRecorded, double totalRecorded})> recordShoppingExpenses({
    required ShoppingListEntity list,
    required List<ShoppingItemEntity> items,
  }) async {
    final totalsByStore = <String, double>{};
    final countsByStore = <String, int>{};

    for (final item in items) {
      final p = item.price;
      if (p == null || p <= 0) continue;
      totalsByStore[item.storeCategory] =
          (totalsByStore[item.storeCategory] ?? 0.0) + p;
      countsByStore[item.storeCategory] =
          (countsByStore[item.storeCategory] ?? 0) + 1;
    }

    if (totalsByStore.isEmpty) {
      throw const ShoppingActionException(AppStrings.cartNoPricesToSaveError);
    }

    final now = DateTime.now();
    var grandTotal = 0.0;
    final companions = <LocalExpenseHistoryCompanion>[];
    for (final entry in totalsByStore.entries) {
      final rounded = double.parse(entry.value.toStringAsFixed(2));
      grandTotal += rounded;
      companions.add(
        LocalExpenseHistoryCompanion.insert(
          id: _uuid.v4(),
          listId: Value(list.id),
          listTitle: list.title,
          storeCategory: entry.key,
          totalAmount: rounded,
          itemCount: Value(countsByStore[entry.key] ?? 0),
          recordedAt: now,
        ),
      );
    }

    await _db.batch((b) => b.insertAll(_db.localExpenseHistory, companions));
    return (
      storesRecorded: companions.length,
      totalRecorded: double.parse(grandTotal.toStringAsFixed(2)),
    );
  }

  Future<void> deleteExpenseRecord(String id) async {
    await (_db.delete(
      _db.localExpenseHistory,
    )..where((t) => t.id.equals(id))).go();
  }

  /// Completely wipes all user lists, items, learned products, custom aisles,
  /// expense history, and cloud sync metadata after `delete_my_account()`,
  /// then re-seeds a clean guest workspace (`Compra semanal` + default aisles).
  Future<String> wipeAllLocalDataForAccountDeletion() async {
    final freshListId = _uuid.v4();
    final now = DateTime.now();

    await _db.transaction(() async {
      await _db.delete(_db.localItems).go();
      await _db.delete(_db.localLists).go();
      await _db.delete(_db.localLearnedItems).go();
      await _db.delete(_db.localAisleOrder).go();
      await _db.delete(_db.localPendingDeletions).go();
      await _db.delete(_db.localExpenseHistory).go();

      final aisleEntries = StoreHierarchy.seedAisleOrder()
          .map(
            (entry) => LocalAisleOrderCompanion.insert(
              storeCategory: entry.store,
              aisleName: entry.aisle,
              sortOrder: entry.sortOrder,
              syncStatus: const Value('seeded'),
            ),
          )
          .toList();
      await _db.batch(
        (b) => b.insertAll(
          _db.localAisleOrder,
          aisleEntries,
          mode: InsertMode.insertOrIgnore,
        ),
      );

      await _db
          .into(_db.localLists)
          .insert(
            LocalListsCompanion.insert(
              id: freshListId,
              title: StoreHierarchy.defaultListName,
              createdAt: now,
              updatedAt: now,
              syncStatus: const Value('pending'),
            ),
          );

      await _db
          .into(_db.localPreferences)
          .insertOnConflictUpdate(
            const LocalPreferencesCompanion(
              id: Value(1),
              city: Value(StoreHierarchy.defaultCity),
              themeMode: Value('system'),
              onboardingCompleted: Value(true),
              keepScreenOn: Value(true),
              soundEnabled: Value(true),
              vibrationEnabled: Value(true),
              remindersEnabled: Value(false),
              avatarChoice: Value('avatar_1'),
              googlePhotoUrl: Value<String?>(null),
              planTier: Value('free'),
              freeMaxLists: Value(3),
              basicMaxLists: Value(10),
              proMaxLists: Value(999),
              monthlyBudgetArs: Value<double?>(null),
              lastSyncedAt: Value<DateTime?>(null),
            ),
          );
    });

    return freshListId;
  }

  Future<void> updatePreferences({
    String? city,
    String? themeMode,
    bool? onboardingCompleted,
    bool? keepScreenOn,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? remindersEnabled,
    String? avatarChoice,
    String? googlePhotoUrl,
    bool clearGooglePhotoUrl = false,
    String? planTier,
    int? freeMaxLists,
    int? basicMaxLists,
    int? proMaxLists,
    double? monthlyBudgetArs,
    bool clearMonthlyBudget = false,
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
            soundEnabled: soundEnabled != null
                ? Value(soundEnabled)
                : const Value.absent(),
            vibrationEnabled: vibrationEnabled != null
                ? Value(vibrationEnabled)
                : const Value.absent(),
            remindersEnabled: remindersEnabled != null
                ? Value(remindersEnabled)
                : const Value.absent(),
            avatarChoice: avatarChoice != null
                ? Value(avatarChoice)
                : const Value.absent(),
            googlePhotoUrl: clearGooglePhotoUrl
                ? const Value<String?>(null)
                : (googlePhotoUrl != null
                      ? Value<String?>(googlePhotoUrl)
                      : const Value.absent()),
            planTier: planTier != null ? Value(planTier) : const Value.absent(),
            freeMaxLists: freeMaxLists != null
                ? Value(freeMaxLists)
                : const Value.absent(),
            basicMaxLists: basicMaxLists != null
                ? Value(basicMaxLists)
                : const Value.absent(),
            proMaxLists: proMaxLists != null
                ? Value(proMaxLists)
                : const Value.absent(),
            monthlyBudgetArs: clearMonthlyBudget
                ? const Value<double?>(null)
                : (monthlyBudgetArs != null
                      ? Value<double?>(monthlyBudgetArs)
                      : const Value.absent()),
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
            displayName: Value(candidate.cleanName),
            useCount: Value(learned.useCount + 1),
            updatedAt: Value(now),
            syncStatus: const Value('pending'),
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
                    displayName: Value(item.cleanName),
                    preferredStore: store,
                    preferredAisle: aisle,
                    useCount: const Value(1),
                    updatedAt: now,
                    syncStatus: const Value('pending'),
                  ),
                  mode: InsertMode.insertOrIgnore,
                );
          } else {
            await (_db.update(
              _db.localLearnedItems,
            )..where((t) => t.normalizedName.equals(key))).write(
              LocalLearnedItemsCompanion(
                displayName: Value(learned.displayName ?? item.cleanName),
                useCount: Value(learned.useCount + 1),
                updatedAt: Value(now),
                syncStatus: const Value('pending'),
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
                  displayName: Value(learned?.displayName ?? item.cleanName),
                  preferredStore: store,
                  preferredAisle: aisle,
                  useCount: Value((learned?.useCount ?? 0) + 1),
                  updatedAt: now,
                  syncStatus: const Value('pending'),
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
            syncStatus: const Value('seeded'),
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
