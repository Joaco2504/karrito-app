import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../core/constants/app_strings.dart';

abstract interface class PushNotificationService {
  Future<void> initializeSafely();
  Future<String?> requestPermissionAndRegisterToken(String? userId);
  Future<bool> requestLocalNotificationPermission();
  Future<void> schedulePendingItemsReminder({
    required int pendingCount,
    required String listTitle,
    Duration delay = const Duration(hours: 24),
  });
  Future<void> cancelPendingItemsReminder();
  Future<void> dispose();
}

/// Manages Firebase Cloud Messaging and local scheduled reminders for pending
/// shopping items. Every native SDK call is isolated inside `try / catch` so
/// neither startup nor headless tests can ever crash.
class FirebasePushNotificationService implements PushNotificationService {
  FirebasePushNotificationService(
    this._client, {
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin();

  static const int pendingReminderNotificationId = 5301;
  static const String _reminderChannelId = 'karrito_pending_reminders';
  static const String _reminderChannelName = 'Recordatorios de compras';
  static const String _reminderChannelDescription =
      'Avisos cuando te quedan productos pendientes sin tachar en tu lista.';

  final SupabaseClient? _client;
  final FlutterLocalNotificationsPlugin _localNotifications;
  bool _firebaseReady = false;
  bool _localNotificationsReady = false;
  bool _timezonesInitialized = false;
  String? _lastRegisteredToken;
  StreamSubscription<String>? _tokenRefreshSub;

  @override
  Future<void> initializeSafely() async {
    await Future.wait<void>(<Future<void>>[
      _initializeFirebaseSafely(),
      _initializeLocalNotificationsSafely(),
    ]);
  }

  Future<void> _initializeFirebaseSafely() async {
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

  Future<void> _initializeLocalNotificationsSafely() async {
    if (!_timezonesInitialized) {
      try {
        tz_data.initializeTimeZones();
        _timezonesInitialized = true;
      } catch (e) {
        debugPrint('Karrito timezone init skipped: $e');
      }
    }

    if (_localNotificationsReady) return;
    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const settings = InitializationSettings(android: androidSettings);
      await _localNotifications.initialize(settings: settings);
      _localNotificationsReady = true;
    } catch (e) {
      debugPrint('Karrito local notifications init skipped: $e');
      _localNotificationsReady = false;
    }
  }

  @override
  Future<bool> requestLocalNotificationPermission() async {
    await _initializeLocalNotificationsSafely();
    if (!_localNotificationsReady) return false;

    try {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        if (granted != null) return granted;
        final enabled = await androidPlugin.areNotificationsEnabled();
        return enabled ?? true;
      }
      return true;
    } catch (e) {
      debugPrint('Karrito local notification permission request skipped: $e');
      return false;
    }
  }

  @override
  Future<void> schedulePendingItemsReminder({
    required int pendingCount,
    required String listTitle,
    Duration delay = const Duration(hours: 24),
  }) async {
    if (pendingCount <= 0) {
      await cancelPendingItemsReminder();
      return;
    }

    await _initializeLocalNotificationsSafely();
    if (!_localNotificationsReady || !_timezonesInitialized) return;

    try {
      await _localNotifications.cancel(id: pendingReminderNotificationId);
      final scheduledAt = tz.TZDateTime.now(tz.UTC).add(delay);
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          _reminderChannelId,
          _reminderChannelName,
          channelDescription: _reminderChannelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
      );

      await _localNotifications.zonedSchedule(
        id: pendingReminderNotificationId,
        title: AppStrings.reminderNotificationTitle,
        body: AppStrings.reminderNotificationBody(pendingCount, listTitle),
        scheduledDate: scheduledAt,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Karrito local reminder schedule skipped: $e');
    }
  }

  @override
  Future<void> cancelPendingItemsReminder() async {
    if (!_localNotificationsReady) return;
    try {
      await _localNotifications.cancel(id: pendingReminderNotificationId);
    } catch (e) {
      debugPrint('Karrito local reminder cancel skipped: $e');
    }
  }

  @override
  Future<String?> requestPermissionAndRegisterToken(String? userId) async {
    if (userId == null || userId.trim().isEmpty) return null;
    await _initializeFirebaseSafely();
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
