import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/store_hierarchy.dart';

part 'app_database.g.dart';

@DataClassName('ShoppingListEntity')
class LocalLists extends Table {
  @override
  String get tableName => 'local_lists';

  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get ownerId => text().nullable()();
  BoolColumn get isShared => boolean().withDefault(const Constant(false))();
  TextColumn get shareCode => text().nullable()();
  BoolColumn get isJoinedRemote =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ShoppingItemEntity')
class LocalItems extends Table {
  @override
  String get tableName => 'local_items';

  TextColumn get id => text()();
  TextColumn get listId =>
      text().references(LocalLists, #id, onDelete: KeyAction.cascade)();
  TextColumn get rawText => text()();
  TextColumn get cleanName => text()();
  RealColumn get quantity => real().withDefault(const Constant(1.0))();
  TextColumn get unit => text().withDefault(const Constant('u'))();
  TextColumn get storeCategory => text()();
  TextColumn get aisleName => text()();
  BoolColumn get isChecked => boolean().withDefault(const Constant(false))();
  IntColumn get position => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('AisleOrderEntity')
class LocalAisleOrder extends Table {
  @override
  String get tableName => 'local_aisle_order';

  TextColumn get storeCategory => text()();
  TextColumn get aisleName => text()();
  IntColumn get sortOrder => integer()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('seeded'))();

  @override
  Set<Column<Object>> get primaryKey => {storeCategory, aisleName};
}

@DataClassName('LearnedItemEntity')
class LocalLearnedItems extends Table {
  @override
  String get tableName => 'local_learned_items';

  TextColumn get normalizedName => text()();
  TextColumn get displayName => text().nullable()();
  TextColumn get preferredStore => text()();
  TextColumn get preferredAisle => text()();
  IntColumn get useCount => integer().withDefault(const Constant(1))();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column<Object>> get primaryKey => {normalizedName};
}

@DataClassName('UserPreferencesEntity')
class LocalPreferences extends Table {
  @override
  String get tableName => 'local_preferences';

  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get city =>
      text().withDefault(const Constant(StoreHierarchy.defaultCity))();
  TextColumn get themeMode => text().withDefault(const Constant('system'))();
  BoolColumn get onboardingCompleted =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get keepScreenOn => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PendingDeletionEntity')
class LocalPendingDeletions extends Table {
  @override
  String get tableName => 'local_pending_deletions';

  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityKey => text()();
  BoolColumn get isLeaveOnly => boolean().withDefault(const Constant(false))();
  DateTimeColumn get deletedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    LocalLists,
    LocalItems,
    LocalAisleOrder,
    LocalLearnedItems,
    LocalPreferences,
    LocalPendingDeletions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _createPerformanceIndexes();
        await _seedInitialData();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(localLists, localLists.ownerId);
          await m.addColumn(localLists, localLists.isShared);
          await m.addColumn(localLists, localLists.shareCode);
          await m.addColumn(localLists, localLists.isJoinedRemote);
          await m.addColumn(localAisleOrder, localAisleOrder.updatedAt);
          await m.addColumn(localAisleOrder, localAisleOrder.syncStatus);
          await m.addColumn(localLearnedItems, localLearnedItems.displayName);
          await m.addColumn(localLearnedItems, localLearnedItems.syncStatus);
          await m.createTable(localPendingDeletions);
        }
        if (from < 3) {
          await m.addColumn(localPreferences, localPreferences.lastSyncedAt);
          await _createPerformanceIndexes();
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _createPerformanceIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_local_items_list_store_aisle '
      'ON local_items (list_id, store_category, aisle_name, is_checked, position)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_local_items_sync_status '
      'ON local_items (sync_status, updated_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_local_learned_use_count '
      'ON local_learned_items (use_count DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_local_aisle_order_lookup '
      'ON local_aisle_order (store_category, sort_order)',
    );
  }

  Future<void> _seedInitialData() async {
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

    await batch((b) {
      b.insertAll(
        localAisleOrder,
        aisleEntries,
        mode: InsertMode.insertOrIgnore,
      );
    });

    final now = DateTime.now();
    await into(localLists).insert(
      LocalListsCompanion.insert(
        id: const Uuid().v4(),
        title: StoreHierarchy.defaultListName,
        createdAt: now,
        updatedAt: now,
        syncStatus: const Value('pending'),
      ),
      mode: InsertMode.insertOrIgnore,
    );

    await into(localPreferences).insert(
      LocalPreferencesCompanion.insert(
        id: const Value(1),
        city: const Value(StoreHierarchy.defaultCity),
        themeMode: const Value('system'),
        onboardingCompleted: const Value(false),
        keepScreenOn: const Value(true),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'karrito_db',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
