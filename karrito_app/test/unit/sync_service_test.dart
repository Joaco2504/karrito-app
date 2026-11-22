import 'dart:async';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karrito_app/core/constants/app_strings.dart';
import 'package:karrito_app/data/local/app_database.dart';
import 'package:karrito_app/data/models/procesar_lista_response.dart';
import 'package:karrito_app/data/repositories/shopping_repository.dart';
import 'package:karrito_app/data/services/ai_classifier_service.dart';
import 'package:karrito_app/data/services/auth_service.dart';
import 'package:karrito_app/data/services/sync_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _NoopAi implements AiClassifierService {
  @override
  Future<ProcesarListaResponse> classifyText(String text) async {
    return const ProcesarListaResponse(items: <ProcessedAiItem>[]);
  }
}

class _FakeAuthService implements AuthService {
  _FakeAuthService({required this.userId, this.email});

  final String userId;
  final String? email;
  final _controller = StreamController<AuthState>.broadcast();

  @override
  Session? get currentSession => null;

  @override
  String? get currentUserId => userId;

  @override
  bool get isAnonymous => false;

  @override
  String? get currentEmail => email;

  @override
  Stream<AuthState> get onAuthStateChange => _controller.stream;

  @override
  Future<bool> ensureSignedInSilently() async => true;

  @override
  Future<GoogleLinkOutcome?> linkOrSignInWithGoogle() async => null;

  void dispose() => _controller.close();
}

class _FakeSyncRemote implements KarritoSyncRemote {
  final List<String> callOrder = <String>[];
  Map<String, dynamic>? upsertedProfile;
  bool throwOnProfileUpsert = false;
  bool cityUpdatedFallback = false;
  bool throwOnAisleFetch = false;

  /// List IDs that simulate belonging to another owner remotely -> reject with 42501.
  final Set<String> conflictingRemoteListIds = <String>{};

  final List<DateTime?> listFetchUpdatedSince = <DateTime?>[];
  final List<DateTime?> itemFetchUpdatedSince = <DateTime?>[];
  final List<DateTime?> aisleFetchUpdatedSince = <DateTime?>[];
  final List<DateTime?> learnedFetchUpdatedSince = <DateTime?>[];

  Duration simulatedFetchDelay = Duration.zero;
  int _inFlightFetches = 0;
  int maxConcurrentFetches = 0;

  final List<Map<String, dynamic>> upsertedLists = <Map<String, dynamic>>[];
  final List<Map<String, dynamic>> upsertedItems = <Map<String, dynamic>>[];
  String? aisleConflictArg;
  List<Map<String, dynamic>> upsertedAisles = <Map<String, dynamic>>[];
  String? learnedConflictArg;
  List<Map<String, dynamic>> upsertedLearned = <Map<String, dynamic>>[];

  Future<void> _trackConcurrency() async {
    if (simulatedFetchDelay <= Duration.zero) return;
    _inFlightFetches++;
    if (_inFlightFetches > maxConcurrentFetches) {
      maxConcurrentFetches = _inFlightFetches;
    }
    await Future<void>.delayed(simulatedFetchDelay);
    _inFlightFetches--;
  }

  @override
  Future<void> upsertUserProfile(Map<String, dynamic> row) async {
    callOrder.add('users_profile');
    if (throwOnProfileUpsert) {
      throw const PostgrestException(
        message: 'new row violates row-level security policy',
        code: '42501',
      );
    }
    upsertedProfile = row;
  }

  @override
  Future<void> updateUserCity(String uid, String city, {String? email}) async {
    callOrder.add('users_profile_update_fallback');
    cityUpdatedFallback = true;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchShoppingLists(
    String uid, {
    DateTime? updatedSince,
  }) async {
    listFetchUpdatedSince.add(updatedSince);
    await _trackConcurrency();
    return const [];
  }

  @override
  Future<void> upsertShoppingList(Map<String, dynamic> row) async {
    callOrder.add('shopping_lists');
    final id = row['id']?.toString();
    if (id != null && conflictingRemoteListIds.contains(id)) {
      throw const PostgrestException(
        message:
            'new row violates row-level security policy for table "shopping_lists"',
        code: '42501',
      );
    }
    upsertedLists.add(row);
  }

  @override
  Future<void> updateShoppingList(
    String listId,
    Map<String, dynamic> values,
  ) async {}

  @override
  Future<void> deleteShoppingList(String listId) async {}

  @override
  Future<void> deleteListMembership(String listId, String uid) async {}

  @override
  Future<List<Map<String, dynamic>>> fetchListItems({
    DateTime? updatedSince,
    Iterable<String>? listIds,
  }) async {
    itemFetchUpdatedSince.add(updatedSince);
    return const [];
  }

  @override
  Future<void> upsertListItem(Map<String, dynamic> row) async {
    callOrder.add('list_items');
    upsertedItems.add(row);
  }

  @override
  Future<void> deleteListItem(String itemId) async {}

  @override
  Future<List<Map<String, dynamic>>> fetchAislePreferences(
    String uid, {
    DateTime? updatedSince,
  }) async {
    aisleFetchUpdatedSince.add(updatedSince);
    await _trackConcurrency();
    if (throwOnAisleFetch) {
      throw const PostgrestException(
        message: 'permission denied',
        code: '42501',
      );
    }
    return const [];
  }

  @override
  Future<void> upsertAislePreferences(
    List<Map<String, dynamic>> rows, {
    required String onConflict,
  }) async {
    callOrder.add('aisle_preferences');
    aisleConflictArg = onConflict;
    upsertedAisles = rows;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchLearnedItems(
    String uid, {
    DateTime? updatedSince,
  }) async {
    learnedFetchUpdatedSince.add(updatedSince);
    await _trackConcurrency();
    return const [];
  }

  @override
  Future<void> upsertLearnedItems(
    List<Map<String, dynamic>> rows, {
    required String onConflict,
  }) async {
    callOrder.add('learned_items');
    learnedConflictArg = onConflict;
    upsertedLearned = rows;
  }

  @override
  Future<void> deleteLearnedItem(String uid, String normalizedName) async {}
}

void main() {
  late AppDatabase db;
  late _FakeAuthService auth;
  late _FakeSyncRemote remote;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    auth = _FakeAuthService(
      userId: 'e6a852f7-258e-4901-a07b-612820b12c7c',
      email: 'jooako7@gmail.com',
    );
    remote = _FakeSyncRemote();
  });

  tearDown(() async {
    auth.dispose();
    await db.close();
  });

  test(
    'syncAll upserts users_profile first, rewrites stale owner_id, and uses composite onConflict keys',
    () async {
      final now = DateTime.now();
      final list = (await db.select(db.localLists).get()).first;

      await (db.update(
        db.localLists,
      )..where((t) => t.id.equals(list.id))).write(
        const LocalListsCompanion(
          ownerId: Value('old-anonymous-guest-uid'),
          syncStatus: Value('pending'),
        ),
      );

      await db
          .into(db.localItems)
          .insert(
            LocalItemsCompanion.insert(
              id: '11111111-1111-4111-8111-111111111111',
              listId: list.id,
              rawText: '2 kg papa',
              cleanName: 'Papa',
              storeCategory: 'Supermercado',
              aisleName: 'Verdulería y Frutería',
              updatedAt: now,
              syncStatus: const Value('pending'),
            ),
          );

      await db
          .into(db.localAisleOrder)
          .insertOnConflictUpdate(
            LocalAisleOrderCompanion.insert(
              storeCategory: 'Supermercado',
              aisleName: 'Bebidas',
              sortOrder: 5,
              updatedAt: Value(now),
              syncStatus: const Value('pending'),
            ),
          );

      await db
          .into(db.localLearnedItems)
          .insertOnConflictUpdate(
            LocalLearnedItemsCompanion.insert(
              normalizedName: 'papa',
              displayName: const Value('Papa'),
              preferredStore: 'Supermercado',
              preferredAisle: 'Verdulería y Frutería',
              useCount: const Value(3),
              updatedAt: now,
              syncStatus: const Value('pending'),
            ),
          );

      final service = SupabaseSyncService(
        db: db,
        client: null,
        authService: auth,
        remote: remote,
      );

      await service.syncAll();

      expect(remote.callOrder.first, 'users_profile');
      expect(
        remote.callOrder.indexOf('users_profile'),
        lessThan(remote.callOrder.indexOf('shopping_lists')),
      );
      expect(
        remote.upsertedProfile,
        equals(<String, dynamic>{
          'id': 'e6a852f7-258e-4901-a07b-612820b12c7c',
          'email': 'jooako7@gmail.com',
          'city': 'Andalgalá',
        }),
      );

      expect(remote.upsertedLists, hasLength(1));
      expect(
        remote.upsertedLists.first['owner_id'],
        'e6a852f7-258e-4901-a07b-612820b12c7c',
      );
      expect(remote.upsertedItems, hasLength(1));
      expect(remote.upsertedItems.first['clean_name'], 'Papa');
      expect(remote.aisleConflictArg, 'user_id,store_category,aisle_name');
      expect(remote.upsertedAisles, hasLength(1));
      expect(remote.learnedConflictArg, 'user_id,normalized_name');
      expect(remote.upsertedLearned, hasLength(1));

      final updatedList = await (db.select(
        db.localLists,
      )..where((t) => t.id.equals(list.id))).getSingle();
      expect(updatedList.syncStatus, 'synced');
      expect(updatedList.ownerId, 'e6a852f7-258e-4901-a07b-612820b12c7c');
    },
  );

  test(
    'syncAll self-heals 42501 ownership conflict by reassigning fresh UUIDs to owned list and items',
    () async {
      final now = DateTime.now();
      final conflictingList = (await db.select(db.localLists).get()).first;
      remote.conflictingRemoteListIds.add(conflictingList.id);

      await db
          .into(db.localItems)
          .insert(
            LocalItemsCompanion.insert(
              id: '22222222-2222-4222-8222-222222222222',
              listId: conflictingList.id,
              rawText: '1 l leche',
              cleanName: 'Leche',
              storeCategory: 'Supermercado',
              aisleName: 'Lácteos y Refrigerados',
              updatedAt: now,
              syncStatus: const Value('pending'),
            ),
          );

      final service = SupabaseSyncService(
        db: db,
        client: null,
        authService: auth,
        remote: remote,
      );

      await service.syncAll();

      // List was cloned to a new UUID, uploaded cleanly, and its item followed under the new listId.
      final listsAfter = await db.select(db.localLists).get();
      expect(listsAfter, hasLength(1));
      expect(listsAfter.single.id, isNot(conflictingList.id));
      expect(listsAfter.single.syncStatus, 'synced');
      expect(listsAfter.single.ownerId, auth.userId);

      expect(remote.upsertedLists, hasLength(1));
      expect(remote.upsertedLists.single['id'], listsAfter.single.id);

      expect(remote.upsertedItems, hasLength(1));
      expect(remote.upsertedItems.single['list_id'], listsAfter.single.id);
      expect(
        remote.upsertedItems.single['id'],
        isNot('22222222-2222-4222-8222-222222222222'),
      );
      expect(remote.upsertedItems.single['clean_name'], 'Leche');
    },
  );

  test(
    'delta sync persists lastSyncedAt only on success, filters next pull, preserves synced rows, and resets on account switch',
    () async {
      var clockNow = DateTime.utc(2026, 11, 22, 15, 0, 0);
      final service = SupabaseSyncService(
        db: db,
        client: null,
        authService: auth,
        remote: remote,
        clock: () => clockNow,
      );

      final initialList = (await db.select(db.localLists).get()).first;
      await db
          .into(db.localItems)
          .insert(
            LocalItemsCompanion.insert(
              id: '33333333-3333-4333-8333-333333333333',
              listId: initialList.id,
              rawText: 'yerba',
              cleanName: 'Yerba',
              storeCategory: 'Supermercado',
              aisleName: 'Almacén',
              updatedAt: clockNow,
              syncStatus: const Value('pending'),
            ),
          );

      // 1st sync: full pull (updatedSince == null), stores watermark at clockNow.
      await service.syncAll();
      expect(remote.listFetchUpdatedSince.last, isNull);
      expect(remote.itemFetchUpdatedSince.last, isNull);
      expect(remote.aisleFetchUpdatedSince.last, isNull);
      expect(remote.learnedFetchUpdatedSince.last, isNull);

      var prefs = await (db.select(
        db.localPreferences,
      )..where((t) => t.id.equals(1))).getSingle();
      expect(prefs.lastSyncedAt?.toUtc(), clockNow);

      // 2nd sync fails mid-way -> lastSyncedAt must NOT advance!
      final failedTime = clockNow.add(const Duration(minutes: 5));
      clockNow = failedTime;
      remote.throwOnAisleFetch = true;
      await expectLater(service.syncAll(), throwsA(isA<PostgrestException>()));

      prefs = await (db.select(
        db.localPreferences,
      )..where((t) => t.id.equals(1))).getSingle();
      expect(prefs.lastSyncedAt?.toUtc(), DateTime.utc(2026, 11, 22, 15, 0, 0));

      // 3rd sync succeeds as delta sync -> passes previous watermark AND keeps previously synced item!
      remote.throwOnAisleFetch = false;
      final thirdSyncTime = DateTime.utc(2026, 11, 22, 15, 10, 0);
      clockNow = thirdSyncTime;
      await service.syncAll();

      expect(
        remote.listFetchUpdatedSince.last?.toUtc(),
        DateTime.utc(2026, 11, 22, 15, 0, 0),
      );
      expect(
        remote.itemFetchUpdatedSince.last?.toUtc(),
        DateTime.utc(2026, 11, 22, 15, 0, 0),
      );
      expect(
        remote.aisleFetchUpdatedSince.last?.toUtc(),
        DateTime.utc(2026, 11, 22, 15, 0, 0),
      );
      expect(
        remote.learnedFetchUpdatedSince.last?.toUtc(),
        DateTime.utc(2026, 11, 22, 15, 0, 0),
      );

      final itemsAfterDelta = await db.select(db.localItems).get();
      expect(itemsAfterDelta, hasLength(1));
      expect(itemsAfterDelta.single.cleanName, 'Yerba');

      prefs = await (db.select(
        db.localPreferences,
      )..where((t) => t.id.equals(1))).getSingle();
      expect(prefs.lastSyncedAt?.toUtc(), thirdSyncTime);

      // Switching account remaps owned list UUIDs and resets lastSyncedAt to null!
      final repo = ShoppingRepository(db: db, aiClassifier: _NoopAi());
      final remapped = await repo.prepareLocalDataForAccountSwitch(
        'new-google-uid',
      );
      expect(remapped.containsKey(initialList.id), isTrue);
      expect(remapped[initialList.id], isNot(initialList.id));

      prefs = await (db.select(
        db.localPreferences,
      )..where((t) => t.id.equals(1))).getSingle();
      expect(prefs.lastSyncedAt, isNull);
    },
  );

  test(
    'syncAll runs independent table sync branches concurrently via Future.wait',
    () async {
      remote.simulatedFetchDelay = const Duration(milliseconds: 40);

      final service = SupabaseSyncService(
        db: db,
        client: null,
        authService: auth,
        remote: remote,
      );

      await service.syncAll();

      // lists, aisle_preferences, and learned_items all fetch concurrently (3 in flight).
      expect(remote.maxConcurrentFetches, greaterThanOrEqualTo(3));
    },
  );

  test(
    'syncAll falls back to updateUserCity when users_profile upsert returns 42501',
    () async {
      remote.throwOnProfileUpsert = true;

      final service = SupabaseSyncService(
        db: db,
        client: null,
        authService: auth,
        remote: remote,
      );

      await service.syncAll();
      expect(remote.cityUpdatedFallback, isTrue);
      expect(
        remote.callOrder,
        containsAllInOrder(<String>[
          'users_profile',
          'users_profile_update_fallback',
          'shopping_lists',
        ]),
      );
    },
  );

  test('extractDiagnosticCode formats concise reference codes cleanly', () {
    expect(
      SupabaseSyncService.extractDiagnosticCode(
        const PostgrestException(message: 'rls', code: '42501'),
      ),
      '42501',
    );
    expect(AppStrings.syncFailedWithRef('42501'), endsWith('(Ref: 42501)'));
    expect(AppStrings.syncFailedWithRef(null), AppStrings.syncFailedError);
  });

  test('AuthService.isLinkFallbackException detects existing identities', () {
    expect(
      AuthService.isLinkFallbackException(
        const AuthException(
          'Identity is already linked to another user',
          statusCode: '422',
          code: 'identity_already_exists',
        ),
      ),
      isTrue,
    );
    expect(
      AuthService.isLinkFallbackException(
        const AuthException(
          'Manual linking is disabled',
          statusCode: '400',
          code: 'manual_linking_disabled',
        ),
      ),
      isTrue,
    );
    expect(
      AuthService.isLinkFallbackException(
        const AuthException(
          'Internal server timeout',
          statusCode: '503',
          code: 'unexpected_failure',
        ),
      ),
      isFalse,
    );
  });
}
