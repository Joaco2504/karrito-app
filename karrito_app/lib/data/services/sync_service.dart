import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/store_hierarchy.dart';
import '../../domain/services/item_text_parser.dart';
import '../../domain/services/share_code_helper.dart';
import '../local/app_database.dart';
import '../repositories/shopping_repository.dart';
import 'auth_service.dart';

class LiveShareOutcome {
  const LiveShareOutcome.requiresPro() : requiresPro = true, shareCode = null;

  const LiveShareOutcome.ready(String code)
    : requiresPro = false,
      shareCode = code;

  final bool requiresPro;
  final String? shareCode;
}

class JoinedListResult {
  const JoinedListResult({required this.listId, required this.title});

  final String listId;
  final String title;
}

abstract interface class SyncService {
  Future<void> syncAll();
  Future<void> refreshAccountPlanAndConfig();
  Future<LiveShareOutcome> enableLiveShare(ShoppingListEntity list);
  Future<JoinedListResult> joinSharedListByCode(String rawCode);
  RealtimeChannel? subscribeToSharedList(String listId);
  Future<void> unsubscribeChannel(RealtimeChannel? channel);
}

/// Thin remote persistence abstraction so [SupabaseSyncService] can run
/// against either the real `karrito` schema in Supabase or an in-memory fake
/// in unit tests.
abstract interface class KarritoSyncRemote {
  Future<void> upsertUserProfile(Map<String, dynamic> row);
  Future<void> updateUserCity(String uid, String city, {String? email});
  Future<List<Map<String, dynamic>>> fetchShoppingLists(
    String uid, {
    DateTime? updatedSince,
  });
  Future<void> upsertShoppingList(Map<String, dynamic> row);
  Future<void> updateShoppingList(String listId, Map<String, dynamic> values);
  Future<void> deleteShoppingList(String listId);
  Future<void> deleteListMembership(String listId, String uid);
  Future<List<Map<String, dynamic>>> fetchListItems({
    DateTime? updatedSince,
    Iterable<String>? listIds,
  });
  Future<void> upsertListItem(Map<String, dynamic> row);
  Future<void> deleteListItem(String itemId);
  Future<List<Map<String, dynamic>>> fetchAislePreferences(
    String uid, {
    DateTime? updatedSince,
  });
  Future<void> upsertAislePreferences(
    List<Map<String, dynamic>> rows, {
    required String onConflict,
  });
  Future<List<Map<String, dynamic>>> fetchLearnedItems(
    String uid, {
    DateTime? updatedSince,
  });
  Future<void> upsertLearnedItems(
    List<Map<String, dynamic>> rows, {
    required String onConflict,
  });
  Future<void> deleteLearnedItem(String uid, String normalizedName);
}

class _SupabaseSyncRemote implements KarritoSyncRemote {
  const _SupabaseSyncRemote(this._client);

  final SupabaseClient _client;

  @override
  Future<void> upsertUserProfile(Map<String, dynamic> row) async {
    await _client.from('users_profile').upsert(row, onConflict: 'id');
  }

  @override
  Future<void> updateUserCity(String uid, String city, {String? email}) async {
    await _client
        .from('users_profile')
        .update(<String, dynamic>{
          'city': city,
          if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        })
        .eq('id', uid);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchShoppingLists(
    String uid, {
    DateTime? updatedSince,
  }) async {
    final memberships = await _client
        .from('list_members')
        .select('list_id')
        .eq('user_id', uid);
    final memberListIds = <String>{
      for (final m in memberships)
        if (m['list_id'] != null) m['list_id'].toString(),
    };

    var query = _client
        .from('shopping_lists')
        .select(
          'id, owner_id, title, is_shared, share_code, created_at, updated_at',
        );
    if (updatedSince != null) {
      query = query.gte('updated_at', updatedSince.toUtc().toIso8601String());
    }

    final rows = List<Map<String, dynamic>>.from(await query);
    // Keep only lists owned by or shared with this user so admin accounts
    // testing the mobile app never pull unrelated users' private lists.
    return rows.where((row) {
      final id = row['id']?.toString();
      final ownerId = row['owner_id']?.toString();
      return ownerId == uid || (id != null && memberListIds.contains(id));
    }).toList();
  }

  @override
  Future<void> upsertShoppingList(Map<String, dynamic> row) async {
    await _client.from('shopping_lists').upsert(row, onConflict: 'id');
  }

  @override
  Future<void> updateShoppingList(
    String listId,
    Map<String, dynamic> values,
  ) async {
    await _client.from('shopping_lists').update(values).eq('id', listId);
  }

  @override
  Future<void> deleteShoppingList(String listId) async {
    await _client.from('shopping_lists').delete().eq('id', listId);
  }

  @override
  Future<void> deleteListMembership(String listId, String uid) async {
    await _client
        .from('list_members')
        .delete()
        .eq('list_id', listId)
        .eq('user_id', uid);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchListItems({
    DateTime? updatedSince,
    Iterable<String>? listIds,
  }) async {
    final ids = listIds?.toList();
    if (ids != null && ids.isEmpty) {
      return const <Map<String, dynamic>>[];
    }

    var query = _client.from('list_items').select();
    if (ids != null) {
      query = query.inFilter('list_id', ids);
    }
    if (updatedSince != null) {
      query = query.gte('updated_at', updatedSince.toUtc().toIso8601String());
    }

    final rows = await query;
    return List<Map<String, dynamic>>.from(rows);
  }

  @override
  Future<void> upsertListItem(Map<String, dynamic> row) async {
    await _client.from('list_items').upsert(row, onConflict: 'id');
  }

  @override
  Future<void> deleteListItem(String itemId) async {
    await _client.from('list_items').delete().eq('id', itemId);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAislePreferences(
    String uid, {
    DateTime? updatedSince,
  }) async {
    var query = _client
        .from('aisle_preferences')
        .select('store_category, aisle_name, sort_order, updated_at')
        .eq('user_id', uid);
    if (updatedSince != null) {
      query = query.gte('updated_at', updatedSince.toUtc().toIso8601String());
    }
    final rows = await query;
    return List<Map<String, dynamic>>.from(rows);
  }

  @override
  Future<void> upsertAislePreferences(
    List<Map<String, dynamic>> rows, {
    required String onConflict,
  }) async {
    await _client
        .from('aisle_preferences')
        .upsert(rows, onConflict: onConflict);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchLearnedItems(
    String uid, {
    DateTime? updatedSince,
  }) async {
    var query = _client
        .from('learned_items')
        .select(
          'normalized_name, preferred_store, preferred_aisle, use_count, updated_at',
        )
        .eq('user_id', uid);
    if (updatedSince != null) {
      query = query.gte('updated_at', updatedSince.toUtc().toIso8601String());
    }
    final rows = await query;
    return List<Map<String, dynamic>>.from(rows);
  }

  @override
  Future<void> upsertLearnedItems(
    List<Map<String, dynamic>> rows, {
    required String onConflict,
  }) async {
    await _client.from('learned_items').upsert(rows, onConflict: onConflict);
  }

  @override
  Future<void> deleteLearnedItem(String uid, String normalizedName) async {
    await _client
        .from('learned_items')
        .delete()
        .eq('user_id', uid)
        .eq('normalized_name', normalizedName);
  }
}

class SupabaseSyncService implements SyncService {
  SupabaseSyncService({
    required this._db,
    required SupabaseClient? client,
    required this._authService,
    KarritoSyncRemote? remote,
    DateTime Function()? clock,
    Uuid? uuid,
  }) : _client = client,
       _remote = remote ?? _SupabaseSyncRemote(client!),
       _clock = clock ?? DateTime.now,
       _uuid = uuid ?? const Uuid();

  static const String aislePreferencesOnConflict =
      'user_id,store_category,aisle_name';
  static const String learnedItemsOnConflict = 'user_id,normalized_name';

  final AppDatabase _db;
  final SupabaseClient? _client;
  final AuthService _authService;
  final KarritoSyncRemote _remote;
  final DateTime Function() _clock;
  final Uuid _uuid;

  bool _isSyncing = false;

  /// Extracts a concise diagnostic reference code from Supabase / network
  /// exceptions so user-facing error toasts can show `(Ref: 42501)` without
  /// leaking raw SQL or stack traces.
  static String? extractDiagnosticCode(Object error) {
    if (error is PostgrestException) {
      final code = error.code?.trim();
      return (code != null && code.isNotEmpty) ? code : 'PG';
    }
    if (error is AuthException) {
      final code = error.code?.trim();
      if (code != null && code.isNotEmpty) return code;
      final status = error.statusCode?.trim();
      if (status != null && status.isNotEmpty) return 'AUTH-$status';
      return 'AUTH';
    }
    if (error is TimeoutException) return 'TIMEOUT';
    if (error is SocketException) return 'OFFLINE';
    return null;
  }

  static Map<String, dynamic> buildUserProfileUpsertPayload({
    required String uid,
    String? email,
    required String city,
  }) {
    final trimmedEmail = email?.trim();
    return <String, dynamic>{
      'id': uid,
      'city': city,
      if (trimmedEmail != null && trimmedEmail.isNotEmpty)
        'email': trimmedEmail,
    };
  }

  /// Always assigns `owner_id = currentUid` for non-joined local lists so a
  /// stale anonymous guest UID never violates `shopping_lists_insert` RLS.
  static Map<String, dynamic> buildShoppingListUpsertPayload({
    required ShoppingListEntity list,
    required String currentUid,
  }) {
    return <String, dynamic>{
      'id': list.id,
      'owner_id': currentUid,
      'title': list.title,
      'is_shared': list.isShared,
      'share_code': list.shareCode,
      'created_at': list.createdAt.toUtc().toIso8601String(),
      'updated_at': list.updatedAt.toUtc().toIso8601String(),
    };
  }

  static void _logPostgrestError(String step, PostgrestException e) {
    debugPrint(
      'Karrito sync [$step] PostgrestException: '
      'code=${e.code} message=${e.message} details=${e.details} hint=${e.hint}',
    );
  }

  static void _logAuthError(String step, AuthException e) {
    debugPrint(
      'Karrito sync [$step] AuthException: '
      'code=${e.code} status=${e.statusCode} message=${e.message}',
    );
  }

  @override
  Future<void> syncAll() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final signedIn = await _authService.ensureSignedInSilently();
      final uid = _authService.currentUserId;
      if (!signedIn || uid == null) return;

      final prefs = await (_db.select(
        _db.localPreferences,
      )..where((t) => t.id.equals(1))).getSingleOrNull();
      final lastSyncedAt = prefs?.lastSyncedAt;
      final syncStartedAt = _clock().toUtc();

      await _ensureUserProfileAndCity(uid);
      await _pushPendingDeletions(uid);

      // Run independent table sync branches concurrently to cut sync latency.
      // Lists always complete before items inside `_syncListsAndItems` to
      // satisfy the `list_items.list_id -> shopping_lists.id` foreign key.
      await Future.wait<void>(<Future<void>>[
        _syncListsAndItems(uid, updatedSince: lastSyncedAt),
        _syncAislePreferences(uid, updatedSince: lastSyncedAt),
        _syncLearnedItems(uid, updatedSince: lastSyncedAt),
        _pullPlanAndAppConfig(uid),
      ]);

      await _saveLastSyncedAt(syncStartedAt);
    } on SocketException catch (e) {
      debugPrint('Karrito sync skipped (offline): $e');
    } on TimeoutException catch (e) {
      debugPrint('Karrito sync timeout: $e');
    } on PostgrestException catch (e) {
      _logPostgrestError('syncAll', e);
      rethrow;
    } on AuthException catch (e) {
      _logAuthError('syncAll', e);
      rethrow;
    } catch (e) {
      debugPrint('Karrito sync error: $e');
      rethrow;
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncListsAndItems(String uid, {DateTime? updatedSince}) async {
    await _syncLists(uid, updatedSince: updatedSince);
    await _syncItems(updatedSince: updatedSince);
  }

  @override
  Future<void> refreshAccountPlanAndConfig() async {
    final signedIn = await _authService.ensureSignedInSilently();
    final uid = _authService.currentUserId;
    if (!signedIn || uid == null) return;
    await _pullPlanAndAppConfig(uid);
  }

  Future<void> _pullPlanAndAppConfig(String uid) async {
    final client = _client;
    if (client == null) return;

    try {
      final results = await Future.wait<dynamic>(<Future<dynamic>>[
        client
            .from('users_profile')
            .select('plan_tier')
            .eq('id', uid)
            .maybeSingle(),
        client.from('app_config').select('key, value').inFilter(
          'key',
          const <String>['free_max_lists', 'basic_max_lists', 'pro_max_lists'],
        ),
      ]);

      final profileRow = results[0] as Map<String, dynamic>?;
      final configRows = List<Map<String, dynamic>>.from(
        results[1] as List<dynamic>? ?? const <dynamic>[],
      );

      final rawPlan = profileRow?['plan_tier']?.toString().trim();
      final validPlan =
          (rawPlan == 'free' ||
              rawPlan == 'basic_2usd' ||
              rawPlan == 'pro_3usd')
          ? rawPlan
          : null;

      int? parsePositive(String key) {
        for (final row in configRows) {
          if (row['key']?.toString() == key) {
            final parsed = int.tryParse(row['value']?.toString().trim() ?? '');
            if (parsed != null && parsed > 0) return parsed;
          }
        }
        return null;
      }

      final freeMax = parsePositive('free_max_lists');
      final basicMax = parsePositive('basic_max_lists');
      final proMax = parsePositive('pro_max_lists');

      if (validPlan != null ||
          freeMax != null ||
          basicMax != null ||
          proMax != null) {
        await (_db.update(
          _db.localPreferences,
        )..where((t) => t.id.equals(1))).write(
          LocalPreferencesCompanion(
            planTier: validPlan != null
                ? Value(validPlan)
                : const Value.absent(),
            freeMaxLists: freeMax != null
                ? Value(freeMax)
                : const Value.absent(),
            basicMaxLists: basicMax != null
                ? Value(basicMax)
                : const Value.absent(),
            proMaxLists: proMax != null ? Value(proMax) : const Value.absent(),
          ),
        );
      }
    } catch (e) {
      debugPrint('Karrito _pullPlanAndAppConfig skipped: $e');
    }
  }

  Future<void> _saveLastSyncedAt(DateTime timestampUtc) async {
    await _db
        .into(_db.localPreferences)
        .insertOnConflictUpdate(
          LocalPreferencesCompanion(
            id: const Value(1),
            lastSyncedAt: Value(timestampUtc),
          ),
        );
  }

  @override
  Future<LiveShareOutcome> enableLiveShare(ShoppingListEntity list) async {
    final client = _client;
    if (client == null) {
      throw const ShoppingActionException(AppStrings.syncFailedError);
    }

    final signedIn = await _authService.ensureSignedInSilently();
    final uid = _authService.currentUserId;
    if (!signedIn || uid == null) {
      throw const ShoppingActionException(AppStrings.liveOfflineError);
    }

    try {
      await _ensureUserProfileAndCity(uid);

      final profile = await client
          .from('users_profile')
          .select('plan_tier')
          .eq('id', uid)
          .maybeSingle();
      final planTier = (profile?['plan_tier'] ?? 'free').toString();

      if (planTier != 'pro_3usd') {
        return const LiveShareOutcome.requiresPro();
      }

      if (list.isShared &&
          list.shareCode != null &&
          list.shareCode!.trim().isNotEmpty) {
        await syncAll();
        return LiveShareOutcome.ready(list.shareCode!);
      }

      // Ensure list row exists remotely before sharing code (handles UUID self-heal if needed).
      final syncedList = await _pushSingleList(list, uid);

      for (var attempt = 0; attempt < 4; attempt++) {
        final code = ShareCodeHelper.generateCode();
        try {
          await client
              .from('shopping_lists')
              .update(<String, dynamic>{
                'is_shared': true,
                'share_code': code,
                'updated_at': _clock().toUtc().toIso8601String(),
              })
              .eq('id', syncedList.id);

          await (_db.update(
            _db.localLists,
          )..where((t) => t.id.equals(syncedList.id))).write(
            LocalListsCompanion(
              ownerId: Value(uid),
              isShared: const Value(true),
              shareCode: Value(code),
              updatedAt: Value(_clock()),
              syncStatus: const Value('synced'),
            ),
          );

          await _syncItems();
          return LiveShareOutcome.ready(code);
        } on PostgrestException catch (e) {
          // 23505: share_code unique collision -> retry another 6-char code.
          if (e.code == '23505') continue;
          rethrow;
        }
      }

      throw const ShoppingActionException(AppStrings.genericProcessingError);
    } on ShoppingActionException {
      rethrow;
    } on SocketException {
      throw const ShoppingActionException(AppStrings.liveOfflineError);
    } on PostgrestException catch (e) {
      _logPostgrestError('enableLiveShare', e);
      throw ShoppingActionException(
        AppStrings.syncFailedWithRef(extractDiagnosticCode(e)),
      );
    } on AuthException catch (e) {
      _logAuthError('enableLiveShare', e);
      throw ShoppingActionException(
        AppStrings.syncFailedWithRef(extractDiagnosticCode(e)),
      );
    } catch (e) {
      final lower = e.toString().toLowerCase();
      if (lower.contains('socket') ||
          lower.contains('host') ||
          lower.contains('network')) {
        throw const ShoppingActionException(AppStrings.liveOfflineError);
      }
      throw const ShoppingActionException(AppStrings.syncFailedError);
    }
  }

  @override
  Future<JoinedListResult> joinSharedListByCode(String rawCode) async {
    final client = _client;
    if (client == null) {
      throw const ShoppingActionException(AppStrings.syncFailedError);
    }

    final code = ShareCodeHelper.normalizeAndValidate(rawCode);
    if (code == null) {
      throw const ShoppingActionException(AppStrings.invalidShareCodeError);
    }

    final signedIn = await _authService.ensureSignedInSilently();
    final uid = _authService.currentUserId;
    if (!signedIn || uid == null) {
      throw const ShoppingActionException(AppStrings.liveOfflineError);
    }

    try {
      await _ensureUserProfileAndCity(uid);

      final rawListId = await client.rpc<dynamic>(
        'join_shared_list',
        params: <String, dynamic>{'p_share_code': code},
      );
      final listId = rawListId.toString();

      final listRow = await client
          .from('shopping_lists')
          .select(
            'id, owner_id, title, is_shared, share_code, created_at, updated_at',
          )
          .eq('id', listId)
          .single();

      final remoteItems = await client
          .from('list_items')
          .select()
          .eq('list_id', listId);

      final title = (listRow['title'] ?? 'Lista compartida').toString();
      final ownerId = listRow['owner_id']?.toString();
      final shareCode = listRow['share_code']?.toString() ?? code;
      final createdAt = _parseDate(listRow['created_at']);
      final updatedAt = _parseDate(listRow['updated_at']);

      await _db.transaction(() async {
        await _db
            .into(_db.localLists)
            .insertOnConflictUpdate(
              LocalListsCompanion.insert(
                id: listId,
                title: title,
                ownerId: Value(ownerId),
                isShared: Value(listRow['is_shared'] as bool? ?? true),
                shareCode: Value(shareCode),
                isJoinedRemote: Value(ownerId != uid),
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: const Value('synced'),
              ),
            );

        for (final row in remoteItems) {
          final itemId = row['id']?.toString();
          if (itemId == null) continue;
          final store = StoreHierarchy.normalizeStore(
            row['store_category']?.toString(),
          );
          final aisle = StoreHierarchy.normalizeAisle(
            store,
            row['aisle_name']?.toString(),
          );

          await _db
              .into(_db.localItems)
              .insertOnConflictUpdate(
                LocalItemsCompanion.insert(
                  id: itemId,
                  listId: listId,
                  rawText: (row['raw_text'] ?? row['clean_name'] ?? '')
                      .toString(),
                  cleanName: (row['clean_name'] ?? 'Producto').toString(),
                  quantity: Value(_parseDouble(row['quantity'], fallback: 1.0)),
                  unit: Value((row['unit'] ?? 'u').toString()),
                  storeCategory: store,
                  aisleName: aisle,
                  isChecked: Value(row['is_checked'] as bool? ?? false),
                  position: Value((row['position'] as num?)?.toInt() ?? 0),
                  updatedAt: _parseDate(row['updated_at']),
                  syncStatus: const Value('synced'),
                ),
              );
        }
      });

      return JoinedListResult(listId: listId, title: title);
    } on ShoppingActionException {
      rethrow;
    } on PostgrestException catch (e) {
      _logPostgrestError('joinSharedListByCode', e);
      final msg = e.message.trim();
      if (msg.isNotEmpty) {
        throw ShoppingActionException(msg);
      }
      throw ShoppingActionException(
        AppStrings.syncFailedWithRef(extractDiagnosticCode(e)),
      );
    } on AuthException catch (e) {
      _logAuthError('joinSharedListByCode', e);
      throw ShoppingActionException(
        AppStrings.syncFailedWithRef(extractDiagnosticCode(e)),
      );
    } on SocketException {
      throw const ShoppingActionException(AppStrings.liveOfflineError);
    } catch (e) {
      final lower = e.toString().toLowerCase();
      if (lower.contains('socket') ||
          lower.contains('host') ||
          lower.contains('network')) {
        throw const ShoppingActionException(AppStrings.liveOfflineError);
      }
      throw const ShoppingActionException(AppStrings.syncFailedError);
    }
  }

  @override
  RealtimeChannel? subscribeToSharedList(String listId) {
    final client = _client;
    if (client == null) return null;
    try {
      final channel = client.channel('karrito_live_list_$listId');
      channel
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'karrito',
            table: 'list_items',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'list_id',
              value: listId,
            ),
            callback: (payload) {
              unawaited(_handleRealtimeItemPayload(listId, payload));
            },
          )
          .subscribe();
      return channel;
    } catch (e) {
      debugPrint('Karrito Realtime subscribe failed: $e');
      return null;
    }
  }

  @override
  Future<void> unsubscribeChannel(RealtimeChannel? channel) async {
    final client = _client;
    if (channel == null || client == null) return;
    try {
      await client.removeChannel(channel);
    } catch (e) {
      debugPrint('Karrito Realtime unsubscribe ignored: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Internal sync routines
  // ---------------------------------------------------------------------------

  /// Ensures the authenticated user's row exists in `karrito.users_profile`
  /// before any `shopping_lists`, `aisle_preferences`, or `learned_items`
  /// upsert runs (prevents Postgres FK 23503 for pre-existing `auth.users`).
  Future<void> _ensureUserProfileAndCity(String uid) async {
    final prefs = await (_db.select(
      _db.localPreferences,
    )..where((t) => t.id.equals(1))).getSingleOrNull();
    final city = prefs?.city ?? StoreHierarchy.defaultCity;
    final email = _authService.currentEmail;

    final payload = buildUserProfileUpsertPayload(
      uid: uid,
      email: email,
      city: city,
    );

    try {
      await _remote.upsertUserProfile(payload);
    } on PostgrestException catch (e) {
      _logPostgrestError('ensureUserProfile.upsert', e);
      // Fallback to UPDATE if the row already exists and INSERT RLS was strict.
      try {
        await _remote.updateUserCity(uid, city, email: email);
      } on PostgrestException catch (updateErr) {
        _logPostgrestError('ensureUserProfile.updateFallback', updateErr);
        rethrow;
      }
    }
  }

  Future<void> _pushPendingDeletions(String uid) async {
    final deletions = await _db.select(_db.localPendingDeletions).get();
    for (final deletion in deletions) {
      try {
        switch (deletion.entityType) {
          case 'item':
            await _remote.deleteListItem(deletion.entityKey);
          case 'list':
            if (deletion.isLeaveOnly) {
              await _remote.deleteListMembership(deletion.entityKey, uid);
            } else {
              await _remote.deleteShoppingList(deletion.entityKey);
            }
          case 'learned':
            await _remote.deleteLearnedItem(uid, deletion.entityKey);
        }

        await (_db.delete(
          _db.localPendingDeletions,
        )..where((t) => t.id.equals(deletion.id))).go();
      } on PostgrestException catch (e) {
        _logPostgrestError('pushPendingDeletions(${deletion.entityType})', e);
      } catch (e) {
        debugPrint('Karrito deletion push deferred (${deletion.id}): $e');
      }
    }
  }

  Future<void> _syncLists(String uid, {DateTime? updatedSince}) async {
    final isDeltaSync = updatedSince != null;
    final pendingListDeletes =
        (await (_db.select(
              _db.localPendingDeletions,
            )..where((t) => t.entityType.equals('list'))).get())
            .map((e) => e.entityKey)
            .toSet();

    final remoteRows = await _remote.fetchShoppingLists(
      uid,
      updatedSince: updatedSince,
    );
    final remoteById = <String, Map<String, dynamic>>{
      for (final r in remoteRows)
        if (r['id'] != null) r['id'].toString(): r,
    };

    final localLists = await _db.select(_db.localLists).get();
    final localById = <String, ShoppingListEntity>{
      for (final l in localLists) l.id: l,
    };

    // Merge remote -> local and push newer pending local -> remote.
    for (final entry in remoteById.entries) {
      final id = entry.key;
      if (pendingListDeletes.contains(id)) continue;

      final row = entry.value;
      final remoteUpdatedAt = _parseDate(row['updated_at']);
      final remoteCreatedAt = _parseDate(row['created_at']);
      final ownerId = row['owner_id']?.toString();
      final isJoinedRemote = ownerId != null && ownerId != uid;
      final local = localById[id];

      final localWins =
          local != null &&
          local.syncStatus == 'pending' &&
          !local.updatedAt.toUtc().isBefore(remoteUpdatedAt.toUtc());

      if (localWins) {
        await _pushSingleList(local, uid);
      } else {
        await _db
            .into(_db.localLists)
            .insertOnConflictUpdate(
              LocalListsCompanion.insert(
                id: id,
                title: (row['title'] ?? StoreHierarchy.defaultListName)
                    .toString(),
                ownerId: Value(ownerId),
                isShared: Value(row['is_shared'] as bool? ?? false),
                shareCode: Value(row['share_code']?.toString()),
                isJoinedRemote: Value(isJoinedRemote),
                createdAt: local?.createdAt ?? remoteCreatedAt,
                updatedAt: remoteUpdatedAt,
                syncStatus: const Value('synced'),
              ),
            );
      }
    }

    // Push local-only pending lists (or any owned list missing the active UID)
    // OR (on full sync only) prune remotely deleted lists.
    for (final local in localLists) {
      if (remoteById.containsKey(local.id)) continue;

      final needsOwnerRepair =
          !local.isJoinedRemote &&
          (local.ownerId == null || local.ownerId != uid);

      if ((local.syncStatus == 'pending' || needsOwnerRepair) &&
          !local.isJoinedRemote) {
        await _pushSingleList(local, uid);
      } else if (!isDeltaSync && local.syncStatus == 'synced') {
        final remaining = await _db.select(_db.localLists).get();
        if (remaining.length > 1) {
          await (_db.delete(
            _db.localLists,
          )..where((t) => t.id.equals(local.id))).go();
        }
      }
    }
  }

  /// Pushes a single local list to Supabase.
  ///
  /// If an owned local list collides on primary key with a remote row owned by
  /// another UID (e.g., an old anonymous guest session after signing into an
  /// existing Google account), Supabase rejects the conflict `DO UPDATE` with
  /// `42501` RLS violation. In that case we transparently reassign fresh UUIDs
  /// to the local list and its items and retry once as a new row owned by [uid].
  Future<ShoppingListEntity> _pushSingleList(
    ShoppingListEntity list,
    String uid,
  ) async {
    try {
      if (list.isJoinedRemote) {
        await _remote.updateShoppingList(list.id, <String, dynamic>{
          'title': list.title,
          'updated_at': list.updatedAt.toUtc().toIso8601String(),
        });
      } else {
        await _remote.upsertShoppingList(
          buildShoppingListUpsertPayload(list: list, currentUid: uid),
        );
      }

      await (_db.update(
        _db.localLists,
      )..where((t) => t.id.equals(list.id))).write(
        LocalListsCompanion(
          ownerId: Value(list.isJoinedRemote ? list.ownerId : uid),
          syncStatus: const Value('synced'),
        ),
      );
      return list.copyWith(
        ownerId: Value(list.isJoinedRemote ? list.ownerId : uid),
        syncStatus: 'synced',
      );
    } on PostgrestException catch (e) {
      _logPostgrestError('pushSingleList(${list.id})', e);

      final isOwnershipConflict =
          !list.isJoinedRemote && (e.code == '42501' || e.code == '23505');
      if (!isOwnershipConflict) {
        rethrow;
      }

      debugPrint(
        'Karrito sync: list ${list.id} collided with another owner in Supabase '
        '(code=${e.code}). Reassigning fresh local UUIDs and retrying insert.',
      );
      final cloned = await _reassignOwnedListUuids(list, uid);
      try {
        await _remote.upsertShoppingList(
          buildShoppingListUpsertPayload(list: cloned, currentUid: uid),
        );
        await (_db.update(
          _db.localLists,
        )..where((t) => t.id.equals(cloned.id))).write(
          LocalListsCompanion(
            ownerId: Value(uid),
            syncStatus: const Value('synced'),
          ),
        );
        return cloned.copyWith(ownerId: Value(uid), syncStatus: 'synced');
      } on PostgrestException catch (retryErr) {
        _logPostgrestError('pushSingleList.retry(${cloned.id})', retryErr);
        rethrow;
      }
    }
  }

  /// Replaces [oldList] and all of its local items with fresh UUIDs owned by
  /// [uid] inside a single SQLite transaction so the retry inserts clean rows.
  Future<ShoppingListEntity> _reassignOwnedListUuids(
    ShoppingListEntity oldList,
    String uid,
  ) async {
    final newListId = _uuid.v4();
    final now = _clock();

    await _db.transaction(() async {
      final oldItems = await (_db.select(
        _db.localItems,
      )..where((t) => t.listId.equals(oldList.id))).get();

      await _db
          .into(_db.localLists)
          .insert(
            LocalListsCompanion.insert(
              id: newListId,
              title: oldList.title,
              ownerId: Value(uid),
              isShared: const Value(false),
              shareCode: const Value(null),
              isJoinedRemote: const Value(false),
              createdAt: oldList.createdAt,
              updatedAt: now,
              syncStatus: const Value('pending'),
            ),
          );

      if (oldItems.isNotEmpty) {
        final newCompanions = oldItems.map((item) {
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
        await _db.batch((b) => b.insertAll(_db.localItems, newCompanions));
      }

      await (_db.delete(
        _db.localLists,
      )..where((t) => t.id.equals(oldList.id))).go();
    });

    return ShoppingListEntity(
      id: newListId,
      title: oldList.title,
      ownerId: uid,
      isShared: false,
      shareCode: null,
      isJoinedRemote: false,
      createdAt: oldList.createdAt,
      updatedAt: now,
      syncStatus: 'pending',
    );
  }

  Future<void> _syncItems({DateTime? updatedSince}) async {
    final isDeltaSync = updatedSince != null;
    final pendingItemDeletes =
        (await (_db.select(
              _db.localPendingDeletions,
            )..where((t) => t.entityType.equals('item'))).get())
            .map((e) => e.entityKey)
            .toSet();

    final lists = await _db.select(_db.localLists).get();
    final activeListIds = lists.map((l) => l.id).toSet();
    final syncedListIds = lists
        .where((l) => l.syncStatus == 'synced')
        .map((l) => l.id)
        .toSet();
    if (activeListIds.isEmpty) return;

    final remoteRows = await _remote.fetchListItems(
      updatedSince: updatedSince,
      listIds: activeListIds,
    );
    final remoteById = <String, Map<String, dynamic>>{
      for (final r in remoteRows)
        if (r['id'] != null && activeListIds.contains(r['list_id']?.toString()))
          r['id'].toString(): r,
    };

    final localItems = await _db.select(_db.localItems).get();
    final localById = <String, ShoppingItemEntity>{
      for (final item in localItems) item.id: item,
    };

    for (final entry in remoteById.entries) {
      final id = entry.key;
      if (pendingItemDeletes.contains(id)) continue;

      final row = entry.value;
      final remoteUpdatedAt = _parseDate(row['updated_at']);
      final local = localById[id];

      if (local != null && local.syncStatus == 'pending_ai') {
        continue;
      }

      final localWins =
          local != null &&
          local.syncStatus == 'pending' &&
          !local.updatedAt.toUtc().isBefore(remoteUpdatedAt.toUtc());

      if (localWins) {
        await _pushSingleItem(local);
      } else {
        final store = StoreHierarchy.normalizeStore(
          row['store_category']?.toString(),
        );
        final aisle = StoreHierarchy.normalizeAisle(
          store,
          row['aisle_name']?.toString(),
        );
        await _db
            .into(_db.localItems)
            .insertOnConflictUpdate(
              LocalItemsCompanion.insert(
                id: id,
                listId: row['list_id'].toString(),
                rawText: (row['raw_text'] ?? row['clean_name'] ?? '')
                    .toString(),
                cleanName: (row['clean_name'] ?? 'Producto').toString(),
                quantity: Value(_parseDouble(row['quantity'], fallback: 1.0)),
                unit: Value((row['unit'] ?? 'u').toString()),
                storeCategory: store,
                aisleName: aisle,
                isChecked: Value(row['is_checked'] as bool? ?? false),
                position: Value((row['position'] as num?)?.toInt() ?? 0),
                updatedAt: remoteUpdatedAt,
                syncStatus: const Value('synced'),
              ),
            );
      }
    }

    for (final local in localItems) {
      if (remoteById.containsKey(local.id)) continue;
      if (local.syncStatus == 'pending_ai') continue;

      if (local.syncStatus == 'pending') {
        if (!syncedListIds.contains(local.listId)) continue;
        await _pushSingleItem(local);
      } else if (!isDeltaSync && local.syncStatus == 'synced') {
        await (_db.delete(
          _db.localItems,
        )..where((t) => t.id.equals(local.id))).go();
      }
    }
  }

  Future<void> _pushSingleItem(ShoppingItemEntity item) async {
    try {
      await _remote.upsertListItem(<String, dynamic>{
        'id': item.id,
        'list_id': item.listId,
        'raw_text': item.rawText,
        'clean_name': item.cleanName,
        'quantity': item.quantity,
        'unit': item.unit,
        'store_category': item.storeCategory,
        'aisle_name': item.aisleName,
        'is_checked': item.isChecked,
        'position': item.position,
        'updated_at': item.updatedAt.toUtc().toIso8601String(),
      });

      await (_db.update(_db.localItems)..where((t) => t.id.equals(item.id)))
          .write(const LocalItemsCompanion(syncStatus: Value('synced')));
    } on PostgrestException catch (e) {
      _logPostgrestError('pushSingleItem(${item.id})', e);
      rethrow;
    }
  }

  Future<void> _syncAislePreferences(
    String uid, {
    DateTime? updatedSince,
  }) async {
    final remoteRows = await _remote.fetchAislePreferences(
      uid,
      updatedSince: updatedSince,
    );

    final remoteByKey = <(String, String), Map<String, dynamic>>{
      for (final row in remoteRows)
        (row['store_category'].toString(), row['aisle_name'].toString()): row,
    };

    final localRows = await _db.select(_db.localAisleOrder).get();
    final localByKey = <(String, String), AisleOrderEntity>{
      for (final row in localRows) (row.storeCategory, row.aisleName): row,
    };

    final toPush = <Map<String, dynamic>>[];

    for (final entry in remoteByKey.entries) {
      final key = entry.key;
      final row = entry.value;
      final remoteUpdated = _parseDate(row['updated_at']);
      final local = localByKey[key];

      final localPendingWins =
          local != null &&
          local.syncStatus == 'pending' &&
          local.updatedAt != null &&
          !local.updatedAt!.toUtc().isBefore(remoteUpdated.toUtc());

      if (!localPendingWins) {
        await _db
            .into(_db.localAisleOrder)
            .insertOnConflictUpdate(
              LocalAisleOrderCompanion.insert(
                storeCategory: key.$1,
                aisleName: key.$2,
                sortOrder: (row['sort_order'] as num?)?.toInt() ?? 500,
                updatedAt: Value(remoteUpdated),
                syncStatus: const Value('synced'),
              ),
            );
      }
    }

    for (final local in localRows) {
      if (local.syncStatus != 'pending') continue;
      final key = (local.storeCategory, local.aisleName);
      final remote = remoteByKey[key];
      final localUpdated = local.updatedAt ?? _clock();

      final shouldPush =
          remote == null ||
          !localUpdated.toUtc().isBefore(
            _parseDate(remote['updated_at']).toUtc(),
          );

      if (shouldPush) {
        toPush.add(<String, dynamic>{
          'user_id': uid,
          'store_category': local.storeCategory,
          'aisle_name': local.aisleName,
          'sort_order': local.sortOrder,
          'updated_at': localUpdated.toUtc().toIso8601String(),
        });
      }
    }

    if (toPush.isNotEmpty) {
      try {
        await _remote.upsertAislePreferences(
          toPush,
          onConflict: aislePreferencesOnConflict,
        );
      } on PostgrestException catch (e) {
        _logPostgrestError('syncAislePreferences.upsert', e);
        rethrow;
      }

      await _db.transaction(() async {
        for (final row in toPush) {
          await (_db.update(_db.localAisleOrder)..where(
                (t) =>
                    t.storeCategory.equals(row['store_category'] as String) &
                    t.aisleName.equals(row['aisle_name'] as String),
              ))
              .write(
                const LocalAisleOrderCompanion(syncStatus: Value('synced')),
              );
        }
      });
    }
  }

  Future<void> _syncLearnedItems(String uid, {DateTime? updatedSince}) async {
    final pendingLearnedDeletes =
        (await (_db.select(
              _db.localPendingDeletions,
            )..where((t) => t.entityType.equals('learned'))).get())
            .map((e) => e.entityKey)
            .toSet();

    final remoteRows = await _remote.fetchLearnedItems(
      uid,
      updatedSince: updatedSince,
    );

    final remoteByName = <String, Map<String, dynamic>>{
      for (final row in remoteRows)
        if (row['normalized_name'] != null)
          row['normalized_name'].toString(): row,
    };

    final localRows = await _db.select(_db.localLearnedItems).get();
    final localByName = <String, LearnedItemEntity>{
      for (final row in localRows) row.normalizedName: row,
    };

    final toPush = <Map<String, dynamic>>[];

    for (final entry in remoteByName.entries) {
      final key = entry.key;
      if (pendingLearnedDeletes.contains(key)) continue;

      final row = entry.value;
      final remoteUpdated = _parseDate(row['updated_at']);
      final remoteCount = (row['use_count'] as num?)?.toInt() ?? 1;
      final local = localByName[key];

      final localPendingWins =
          local != null &&
          local.syncStatus == 'pending' &&
          !local.updatedAt.toUtc().isBefore(remoteUpdated.toUtc());

      if (!localPendingWins) {
        final store = StoreHierarchy.normalizeStore(
          row['preferred_store']?.toString(),
        );
        final aisle = StoreHierarchy.normalizeAisle(
          store,
          row['preferred_aisle']?.toString(),
        );
        final bestCount = local != null && local.useCount > remoteCount
            ? local.useCount
            : remoteCount;
        await _db
            .into(_db.localLearnedItems)
            .insertOnConflictUpdate(
              LocalLearnedItemsCompanion.insert(
                normalizedName: key,
                displayName: Value(
                  local?.displayName ?? ItemTextParser.toSentenceCase(key),
                ),
                preferredStore: store,
                preferredAisle: aisle,
                useCount: Value(bestCount),
                updatedAt: remoteUpdated,
                syncStatus: const Value('synced'),
              ),
            );
      }
    }

    for (final local in localRows) {
      if (local.syncStatus != 'pending') continue;
      final remote = remoteByName[local.normalizedName];
      final shouldPush =
          remote == null ||
          !local.updatedAt.toUtc().isBefore(
            _parseDate(remote['updated_at']).toUtc(),
          );
      if (shouldPush) {
        toPush.add(<String, dynamic>{
          'user_id': uid,
          'normalized_name': local.normalizedName,
          'preferred_store': local.preferredStore,
          'preferred_aisle': local.preferredAisle,
          'use_count': local.useCount,
          'updated_at': local.updatedAt.toUtc().toIso8601String(),
        });
      }
    }

    if (toPush.isNotEmpty) {
      try {
        await _remote.upsertLearnedItems(
          toPush,
          onConflict: learnedItemsOnConflict,
        );
      } on PostgrestException catch (e) {
        _logPostgrestError('syncLearnedItems.upsert', e);
        rethrow;
      }

      await _db.transaction(() async {
        for (final row in toPush) {
          await (_db.update(_db.localLearnedItems)..where(
                (t) =>
                    t.normalizedName.equals(row['normalized_name'] as String),
              ))
              .write(
                const LocalLearnedItemsCompanion(syncStatus: Value('synced')),
              );
        }
      });
    }
  }

  Future<void> _handleRealtimeItemPayload(
    String listId,
    PostgresChangePayload payload,
  ) async {
    try {
      if (payload.eventType == PostgresChangeEvent.delete) {
        final deletedId = payload.oldRecord['id']?.toString();
        if (deletedId == null) return;
        await (_db.delete(
          _db.localItems,
        )..where((t) => t.id.equals(deletedId))).go();
        return;
      }

      final record = payload.newRecord;
      final itemId = record['id']?.toString();
      if (itemId == null || itemId.isEmpty) return;

      final existing = await (_db.select(
        _db.localItems,
      )..where((t) => t.id.equals(itemId))).getSingleOrNull();
      final remoteUpdatedAt = _parseDate(record['updated_at']);

      if (existing != null &&
          existing.syncStatus == 'pending' &&
          existing.updatedAt.toUtc().isAfter(remoteUpdatedAt.toUtc())) {
        return;
      }

      final store = StoreHierarchy.normalizeStore(
        record['store_category']?.toString(),
      );
      final aisle = StoreHierarchy.normalizeAisle(
        store,
        record['aisle_name']?.toString(),
      );

      await _db
          .into(_db.localItems)
          .insertOnConflictUpdate(
            LocalItemsCompanion.insert(
              id: itemId,
              listId: record['list_id']?.toString() ?? listId,
              rawText: (record['raw_text'] ?? record['clean_name'] ?? '')
                  .toString(),
              cleanName: (record['clean_name'] ?? 'Producto').toString(),
              quantity: Value(_parseDouble(record['quantity'], fallback: 1.0)),
              unit: Value((record['unit'] ?? 'u').toString()),
              storeCategory: store,
              aisleName: aisle,
              isChecked: Value(record['is_checked'] as bool? ?? false),
              position: Value((record['position'] as num?)?.toInt() ?? 0),
              updatedAt: remoteUpdatedAt,
              syncStatus: const Value('synced'),
            ),
          );
    } catch (e) {
      debugPrint('Karrito Realtime item apply skipped: $e');
    }
  }

  static DateTime _parseDate(dynamic raw) {
    if (raw is DateTime) return raw;
    if (raw is String) {
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) return parsed;
    }
    return DateTime.now();
  }

  static double _parseDouble(dynamic raw, {required double fallback}) {
    if (raw is num) return raw.toDouble();
    if (raw is String) {
      return double.tryParse(raw.replaceAll(',', '.')) ?? fallback;
    }
    return fallback;
  }
}
