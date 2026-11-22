import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karrito_app/core/constants/store_hierarchy.dart';
import 'package:karrito_app/data/local/app_database.dart';
import 'package:karrito_app/data/models/procesar_lista_response.dart';
import 'package:karrito_app/data/repositories/shopping_repository.dart';
import 'package:karrito_app/data/services/ai_classifier_service.dart';

class _FakeAiClassifier implements AiClassifierService {
  int callCount = 0;
  final List<String> sentTexts = <String>[];
  bool shouldThrowOffline = false;
  late ProcesarListaResponse Function(String text) handler;

  @override
  Future<ProcesarListaResponse> classifyText(String text) async {
    callCount++;
    sentTexts.add(text);
    if (shouldThrowOffline) {
      throw const AiOfflineOrNetworkException();
    }
    return handler(text);
  }
}

void main() {
  late AppDatabase db;
  late _FakeAiClassifier fakeAi;
  late ShoppingRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    fakeAi = _FakeAiClassifier()
      ..handler = (text) {
        final lower = text.toLowerCase();
        final items = <ProcessedAiItem>[];
        if (lower.contains('papa')) {
          items.add(
            const ProcessedAiItem(
              cleanName: 'Papa',
              quantity: 2,
              unit: 'kg',
              storeCategory: 'Supermercado',
              aisleName: 'Verdulería y Frutería',
            ),
          );
        }
        if (lower.contains('tornill')) {
          items.add(
            const ProcessedAiItem(
              cleanName: 'Tornillos',
              quantity: 10,
              unit: 'u',
              storeCategory: 'Ferretería / Corralón',
              aisleName: 'Fijaciones',
            ),
          );
        }
        if (lower.contains('ibuprofeno')) {
          items.add(
            const ProcessedAiItem(
              cleanName: 'Ibuprofeno',
              quantity: 1,
              unit: 'caja',
              storeCategory: 'Farmacia',
              aisleName: 'Medicamentos',
            ),
          );
        }
        if (items.isEmpty) {
          items.add(
            ProcessedAiItem(
              cleanName: text,
              quantity: 1,
              unit: 'u',
              storeCategory: 'Supermercado',
              aisleName: 'Almacén',
            ),
          );
        }
        return ProcesarListaResponse(items: items);
      };
    repo = ShoppingRepository(db: db, aiClassifier: fakeAi);
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'seeds Compra semanal, Andalgalá defaults, and canonical aisle order',
    () async {
      final lists = await repo.watchLists().first;
      final prefs = await repo.watchPreferences().first;
      final aisleOrder = await repo.getAisleOrderMap();

      expect(lists, hasLength(1));
      expect(lists.first.title, StoreHierarchy.defaultListName);
      expect(prefs.city, StoreHierarchy.defaultCity);
      expect(prefs.themeMode, 'system');
      expect(prefs.onboardingCompleted, isFalse);
      expect(prefs.keepScreenOn, isTrue);

      expect(aisleOrder[('Supermercado', 'Verdulería y Frutería')], 10);
      expect(aisleOrder[('Ferretería / Corralón', 'Fijaciones')], 10);
      expect(
        aisleOrder[(
          StoreHierarchy.fallbackStore,
          StoreHierarchy.offlinePendingAisle,
        )],
        999,
      );
    },
  );

  test(
    'saves AI results in learned_items and skips AI on repeat input',
    () async {
      final listId = (await repo.watchLists().first).first.id;

      // 1st call hits AI and populates learned_items.
      final firstOutcome = await repo.addItemsFromInput(
        listId: listId,
        rawInput: '2 kg de papa, 10 tornillos',
        isOnline: true,
      );
      expect(firstOutcome.fromAiCount, 2);
      expect(fakeAi.callCount, 1);

      // 2nd call uses learned_items locally with ZERO AI invocations.
      final secondOutcome = await repo.addItemsFromInput(
        listId: listId,
        rawInput: '5 kg de Papá, 20 tornillos',
        isOnline: true,
      );
      expect(secondOutcome.fromLocalCount, 2);
      expect(secondOutcome.fromAiCount, 0);
      expect(fakeAi.callCount, 1);

      // Mixed known + unknown: only unknown is forwarded to AI.
      final mixedOutcome = await repo.addItemsFromInput(
        listId: listId,
        rawInput: '1 kg papa, 1 caja ibuprofeno',
        isOnline: true,
      );
      expect(mixedOutcome.fromLocalCount, 1);
      expect(mixedOutcome.fromAiCount, 1);
      expect(fakeAi.callCount, 2);
      expect(fakeAi.sentTexts.last.toLowerCase(), contains('ibuprofeno'));
      expect(fakeAi.sentTexts.last.toLowerCase(), isNot(contains('papa')));
    },
  );

  test(
    'stores offline items cleanly and reprocesses them when online returns',
    () async {
      final listId = (await repo.watchLists().first).first.id;

      final offlineOutcome = await repo.addItemsFromInput(
        listId: listId,
        rawInput: '10 tornillos\nibuprofeno',
        isOnline: false,
      );
      expect(offlineOutcome.savedOfflineCount, 2);
      expect(fakeAi.callCount, 0);

      var items = await repo.watchItemsForList(listId).first;
      expect(items, hasLength(2));
      expect(
        items.every(
          (i) =>
              i.storeCategory == StoreHierarchy.fallbackStore &&
              i.aisleName == StoreHierarchy.offlinePendingAisle &&
              i.syncStatus == 'pending_ai',
        ),
        isTrue,
      );

      // Simulate user checking one offline item before signal returns.
      final checkedTarget = items.firstWhere(
        (i) => i.cleanName == 'Ibuprofeno',
      );
      await repo.toggleItemChecked(checkedTarget);

      final resolved = await repo.reprocessPendingAiItems();
      expect(resolved, 2);
      expect(fakeAi.callCount, 1);

      items = await repo.watchItemsForList(listId).first;
      expect(items.any((i) => i.syncStatus == 'pending_ai'), isFalse);

      final tornillos = items.firstWhere((i) => i.cleanName == 'Tornillos');
      expect(tornillos.storeCategory, 'Ferretería / Corralón');
      expect(tornillos.aisleName, 'Fijaciones');
      expect(tornillos.isChecked, isFalse);

      final ibuprofeno = items.firstWhere((i) => i.cleanName == 'Ibuprofeno');
      expect(ibuprofeno.storeCategory, 'Farmacia');
      expect(ibuprofeno.aisleName, 'Medicamentos');
      expect(ibuprofeno.isChecked, isTrue);
    },
  );

  test('re-learns store and aisle when user manually edits an item', () async {
    final listId = (await repo.watchLists().first).first.id;

    await repo.addItemsFromInput(
      listId: listId,
      rawInput: '2 kg de papa',
      isOnline: true,
    );
    var items = await repo.watchItemsForList(listId).first;
    final original = items.first;

    await repo.updateItemAndLearn(
      original: original,
      cleanName: 'Papa',
      quantity: 3,
      unit: 'kg',
      storeCategory: 'Dietética / Naturista',
      aisleName: 'Sin TACC',
    );

    // Clear items to check next insert uses manual correction without AI call.
    await repo.deleteItem(original);
    final previousAiCount = fakeAi.callCount;

    await repo.addItemsFromInput(
      listId: listId,
      rawInput: '1 kg de papa',
      isOnline: true,
    );
    expect(fakeAi.callCount, previousAiCount);

    items = await repo.watchItemsForList(listId).first;
    expect(items.single.storeCategory, 'Dietética / Naturista');
    expect(items.single.aisleName, 'Sin TACC');
  });

  test('enforces max 3 lists and prevents deleting last list', () async {
    final lists1 = await repo.watchLists().first;
    final id1 = lists1.first.id;

    await expectLater(
      repo.deleteList(id1),
      throwsA(isA<ShoppingActionException>()),
    );

    await repo.createList('Ferretería');
    await repo.createList('Farmacia');

    await expectLater(
      repo.createList('Cuarta lista'),
      throwsA(isA<ShoppingActionException>()),
    );
  });

  test('saves custom aisle order per store and marks pending sync', () async {
    final initialAisles = await repo.getAislesForStore('Supermercado');
    expect(initialAisles.first, 'Verdulería y Frutería');
    expect(initialAisles, isNot(contains(StoreHierarchy.offlinePendingAisle)));

    final reordered = List<String>.from(initialAisles);
    reordered.remove('Bebidas');
    reordered.insert(0, 'Bebidas');

    await repo.saveAisleOrder(
      storeCategory: 'Supermercado',
      orderedAisles: reordered,
    );

    final updatedMap = await repo.watchAisleOrderMap().first;
    expect(updatedMap[('Supermercado', 'Bebidas')], 10);
    expect(updatedMap[('Supermercado', 'Verdulería y Frutería')], 20);

    final updatedList = await repo.getAislesForStore('Supermercado');
    expect(updatedList.first, 'Bebidas');
  });

  test(
    'adds frequent products from learned_items with zero AI calls and deletes cleanly',
    () async {
      final listId = (await repo.watchLists().first).first.id;
      await repo.addItemsFromInput(
        listId: listId,
        rawInput: '2 kg de papa, 1 caja ibuprofeno',
        isOnline: true,
      );
      final aiCallsAfterSeed = fakeAi.callCount;

      var learned = await repo.watchLearnedItems().first;
      expect(learned, hasLength(2));

      final papaLearned = learned.firstWhere((e) => e.normalizedName == 'papa');
      final addedName = await repo.addLearnedItemToList(
        listId: listId,
        learnedItem: papaLearned,
      );
      expect(addedName, 'Papa');
      expect(fakeAi.callCount, aiCallsAfterSeed);

      learned = await repo.watchLearnedItems().first;
      expect(learned.first.normalizedName, 'papa');
      expect(learned.first.useCount, 2);

      await repo.removeLearnedItem('papa');
      learned = await repo.watchLearnedItems().first;
      expect(learned.any((e) => e.normalizedName == 'papa'), isFalse);

      final tombstones = await db.select(db.localPendingDeletions).get();
      expect(
        tombstones.any(
          (t) => t.entityType == 'learned' && t.entityKey == 'papa',
        ),
        isTrue,
      );
    },
  );

  test(
    'creates all 4 SQLite performance indexes in Drift schemaVersion 3',
    () async {
      // Trigger database open/create first.
      await repo.watchPreferences().first;

      Future<Set<String>> indexNamesFor(String table) async {
        final rows = await db.customSelect("PRAGMA index_list('$table')").get();
        return rows.map((r) => r.read<String>('name')).toSet();
      }

      final itemIndexes = await indexNamesFor('local_items');
      final learnedIndexes = await indexNamesFor('local_learned_items');
      final aisleIndexes = await indexNamesFor('local_aisle_order');

      expect(itemIndexes, contains('idx_local_items_list_store_aisle'));
      expect(itemIndexes, contains('idx_local_items_sync_status'));
      expect(learnedIndexes, contains('idx_local_learned_use_count'));
      expect(aisleIndexes, contains('idx_local_aisle_order_lookup'));
    },
  );
}
