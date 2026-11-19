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

  @override
  Set<Column<Object>> get primaryKey => {storeCategory, aisleName};
}

@DataClassName('LearnedItemEntity')
class LocalLearnedItems extends Table {
  @override
  String get tableName => 'local_learned_items';

  TextColumn get normalizedName => text()();
  TextColumn get preferredStore => text()();
  TextColumn get preferredAisle => text()();
  IntColumn get useCount => integer().withDefault(const Constant(1))();
  DateTimeColumn get updatedAt => dateTime()();

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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _seedInitialData();
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _seedInitialData() async {
    final aisleEntries = StoreHierarchy.seedAisleOrder()
        .map(
          (entry) => LocalAisleOrderCompanion.insert(
            storeCategory: entry.store,
            aisleName: entry.aisle,
            sortOrder: entry.sortOrder,
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
