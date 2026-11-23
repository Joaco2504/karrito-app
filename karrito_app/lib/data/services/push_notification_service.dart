import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class PushNotificationService {
  Future<void> initializeSafely();
  Future<String?> requestPermissionAndRegisterToken(String? userId);
  Future<void> dispose();
}

/// Manages Firebase Cloud Messaging initialization, permission prompting on
/// live collaborative list usage, and persisting `fcm_token` into
/// `karrito.users_profile`. Safe in headless tests or devices without GMS.
class FirebasePushNotificationService implements PushNotificationService {
  FirebasePushNotificationService(this._client);

  final SupabaseClient? _client;
  bool _firebaseReady = false;
  String? _lastRegisteredToken;
  StreamSubscription<String>? _tokenRefreshSub;

  @override
  Future<void> initializeSafely() async {
    if (_firebaseReady) return;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _firebaseReady = true;
    } catch (e) {
      debugPrint('Karrito Firebase init skipped in current environment: $e');
      _firebaseReady = false;
    }
  }

  @override
  Future<String?> requestPermissionAndRegisterToken(String? userId) async {
    if (userId == null || userId.trim().isEmpty) return null;
    await initializeSafely();
    if (!_firebaseReady) return null;

    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final authorized =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      if (!authorized) {
        return null;
      }

      _tokenRefreshSub ??= messaging.onRegistered.listen((registeredToken) {
        final trimmed = registeredToken.trim();
        if (trimmed.isEmpty) return;
        _lastRegisteredToken = trimmed;
        final activeUid = _client?.auth.currentUser?.id ?? userId.trim();
        unawaited(_saveToken(activeUid, trimmed));
      });

      final firstTokenFuture = _lastRegisteredToken != null
          ? Future<String?>.value(_lastRegisteredToken)
          : messaging.onRegistered.first.timeout(
              const Duration(seconds: 4),
              onTimeout: () => '',
            );
      await messaging.register();
      final token = (await firstTokenFuture)?.trim();
      if (token != null && token.isNotEmpty) {
        _lastRegisteredToken = token;
        await _saveToken(userId.trim(), token);
        return token;
      }
      return _lastRegisteredToken;
    } catch (e) {
      debugPrint('Karrito FCM token registration skipped: $e');
      return null;
    }
  }

  Future<void> _saveToken(String userId, String token) async {
    final client = _client;
    if (client == null) return;
    try {
      await client
          .from('users_profile')
          .update(<String, dynamic>{'fcm_token': token})
          .eq('id', userId);
    } catch (e) {
      debugPrint('Karrito FCM token save skipped: $e');
    }
  }

  @override
  Future<void> dispose() async {
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;
  }
}
