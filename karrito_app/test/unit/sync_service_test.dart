import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karrito_app/data/local/app_database.dart';
import 'package:karrito_app/data/services/auth_service.dart';
import 'package:karrito_app/data/services/sync_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  final List<Map<String, dynamic>> upsertedLists = <Map<String, dynamic>>[];
  final List<Map<String, dynamic>> upsertedItems = <Map<String, dynamic>>[];
  String? aisleConflictArg;
  List<Map<String, dynamic>> upsertedAisles = <Map<String, dynamic>>[];
  String? learnedConflictArg;
  List<Map<String, dynamic>> upsertedLearned = <Map<String, dynamic>>[];

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
  Future<List<Map<String, dynamic>>> fetchShoppingLists() async => const [];

  @override
  Future<void> upsertShoppingList(Map<String, dynamic> row) async {
    callOrder.add('shopping_lists');
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
  Future<List<Map<String, dynamic>>> fetchListItems() async => const [];

  @override
  Future<void> upsertListItem(Map<String, dynamic> row) async {
    callOrder.add('list_items');
    upsertedItems.add(row);
  }

  @override
  Future<void> deleteListItem(String itemId) async {}

  @override
  Future<List<Map<String, dynamic>>> fetchAislePreferences(String uid) async =>
      const [];

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
  Future<List<Map<String, dynamic>>> fetchLearnedItems(String uid) async =>
      const [];

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

      // Simulate a local list still carrying an old anonymous guest ownerId.
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

      // 1. users_profile MUST run before shopping_lists, aisle_preferences, learned_items.
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

      // 2. Owned shopping_lists MUST use active authenticated uid, never stale guest uid.
      expect(remote.upsertedLists, hasLength(1));
      expect(
        remote.upsertedLists.first['owner_id'],
        'e6a852f7-258e-4901-a07b-612820b12c7c',
      );

      // 3. list_items uploaded after parent list is synced.
      expect(remote.upsertedItems, hasLength(1));
      expect(remote.upsertedItems.first['clean_name'], 'Papa');

      // 4. Composite unique constraints passed explicitly to upsert.
      expect(remote.aisleConflictArg, 'user_id,store_category,aisle_name');
      expect(remote.upsertedAisles, hasLength(1));
      expect(remote.learnedConflictArg, 'user_id,normalized_name');
      expect(remote.upsertedLearned, hasLength(1));

      // 5. Local Drift rows are marked synced cleanly.
      final updatedList = await (db.select(
        db.localLists,
      )..where((t) => t.id.equals(list.id))).getSingle();
      expect(updatedList.syncStatus, 'synced');
      expect(updatedList.ownerId, 'e6a852f7-258e-4901-a07b-612820b12c7c');
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
