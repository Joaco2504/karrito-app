import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../../core/constants/app_strings.dart';

class AuthActionException implements Exception {
  const AuthActionException(this.message);
  final String message;

  @override
  String toString() => message;
}

class GoogleLinkOutcome {
  const GoogleLinkOutcome({
    required this.userId,
    required this.email,
    required this.switchedUid,
    this.photoUrl,
    this.displayName,
  });

  final String userId;
  final String? email;
  final bool switchedUid;
  final String? photoUrl;
  final String? displayName;
}

/// Handles silent anonymous login and native Google Sign-In linking.
class AuthService {
  AuthService(this._client);

  final SupabaseClient? _client;
  Future<void>? _googleInitFuture;

  Session? get currentSession => _client?.auth.currentSession;
  String? get currentUserId => _client?.auth.currentUser?.id;
  bool get isAnonymous => _client?.auth.currentUser?.isAnonymous ?? true;
  String? get currentEmail => _client?.auth.currentUser?.email;
  String? get currentPhotoUrl =>
      extractPhotoUrlFromMetadata(_client?.auth.currentUser?.userMetadata);
  String? get currentDisplayName =>
      extractDisplayNameFromMetadata(_client?.auth.currentUser?.userMetadata);
  Stream<AuthState> get onAuthStateChange =>
      _client?.auth.onAuthStateChange ?? const Stream<AuthState>.empty();

  static String? extractPhotoUrlFromMetadata(Map<String, dynamic>? metadata) {
    if (metadata == null) return null;
    for (final key in const <String>['avatar_url', 'picture']) {
      final raw = metadata[key];
      if (raw is String && raw.trim().isNotEmpty) {
        return raw.trim();
      }
    }
    return null;
  }

  static String? extractDisplayNameFromMetadata(
    Map<String, dynamic>? metadata,
  ) {
    if (metadata == null) return null;
    for (final key in const <String>['full_name', 'name']) {
      final raw = metadata[key];
      if (raw is String && raw.trim().isNotEmpty) {
        return raw.trim();
      }
    }
    return null;
  }

  /// Returns `true` when [linkIdentityWithIdToken] rejected linking because
  /// the Google identity already belongs to an existing Supabase user or
  /// manual linking is blocked, so falling back to [signInWithIdToken] is safe.
  static bool isLinkFallbackException(AuthException e) {
    final code = (e.code ?? '').trim().toLowerCase();
    final status = (e.statusCode ?? '').trim();
    final message = e.message.toLowerCase();

    const fallbackCodes = <String>{
      'identity_already_exists',
      'email_exists',
      'user_already_exists',
      'provider_already_linked',
      'manual_linking_disabled',
      'conflict',
    };

    if (fallbackCodes.contains(code)) return true;
    if (status == '400' || status == '409' || status == '422') return true;

    return message.contains('already') ||
        message.contains('exists') ||
        message.contains('identity') ||
        message.contains('linked') ||
        message.contains('manual') ||
        message.contains('duplicate') ||
        message.contains('conflict');
  }

  /// Signs in anonymously if no session is present. Never throws on network
  /// errors so the offline-first UI stays responsive without signal.
  Future<bool> ensureSignedInSilently() async {
    final client = _client;
    if (client == null) return false;

    final existing = client.auth.currentSession;
    if (existing != null && !existing.isExpired) {
      return true;
    }

    try {
      if (existing != null && existing.isExpired) {
        final refreshed = await client.auth.refreshSession();
        if (refreshed.session != null) {
          return true;
        }
      }
      final response = await client.auth.signInAnonymously();
      return response.session != null;
    } on AuthException catch (e) {
      debugPrint(
        'Karrito AuthService silent sign-in AuthException: '
        'code=${e.code} status=${e.statusCode} message=${e.message}',
      );
      return client.auth.currentSession != null;
    } catch (error) {
      debugPrint('Karrito AuthService silent sign-in skipped: $error');
      return client.auth.currentSession != null;
    }
  }

  Future<void> _ensureGoogleInitialized() async {
    _googleInitFuture ??= GoogleSignIn.instance.initialize(
      serverClientId: SupabaseConfig.googleWebClientId,
    );
    try {
      await _googleInitFuture;
    } catch (error) {
      // Clear cached failed future so the next user attempt can retry cleanly.
      _googleInitFuture = null;
      rethrow;
    }
  }

  /// Launches Google account picker, extracts the ID token for Supabase, and
  /// links the anonymous account (or signs into an existing Google account
  /// while signaling `switchedUid` so local Drift data can be merged cleanly).
  /// Returns `null` if the user cancels the picker.
  Future<GoogleLinkOutcome?> linkOrSignInWithGoogle() async {
    final client = _client;
    if (client == null) {
      throw const AuthActionException(AppStrings.googleOfflineError);
    }

    try {
      await _ensureGoogleInitialized();

      final googleUser = await GoogleSignIn.instance.authenticate();
      final idToken = googleUser.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        debugPrint(
          'Karrito AuthService: Google returned null/empty idToken for ${googleUser.email}',
        );
        throw const AuthActionException(AppStrings.googleTokenError);
      }

      await ensureSignedInSilently();
      final previousUser = client.auth.currentUser;
      final previousUid = previousUser?.id;
      var switchedUid = false;

      if (previousUser != null && previousUser.isAnonymous) {
        try {
          await client.auth.linkIdentityWithIdToken(
            provider: OAuthProvider.google,
            idToken: idToken,
          );
          debugPrint(
            'Karrito AuthService: linkIdentityWithIdToken succeeded for uid=${client.auth.currentUser?.id}',
          );
        } on AuthException catch (e) {
          debugPrint(
            'Karrito AuthService linkIdentityWithIdToken AuthException: '
            'code=${e.code} status=${e.statusCode} message=${e.message}',
          );

          if (!isLinkFallbackException(e)) {
            rethrow;
          }

          // Account already exists in auth.users: sign in directly and flag
          // `switchedUid` so local Drift lists/preferences are migrated cleanly.
          await client.auth.signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: idToken,
          );
          switchedUid = client.auth.currentUser?.id != previousUid;
          debugPrint(
            'Karrito AuthService: fallback signInWithIdToken succeeded '
            'uid=${client.auth.currentUser?.id} switchedUid=$switchedUid',
          );
        }
      } else {
        await client.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
        );
        switchedUid = client.auth.currentUser?.id != previousUid;
        debugPrint(
          'Karrito AuthService: direct signInWithIdToken succeeded '
          'uid=${client.auth.currentUser?.id} switchedUid=$switchedUid',
        );
      }

      final newUser = client.auth.currentUser;
      if (newUser == null) {
        throw const AuthActionException(AppStrings.googleTokenError);
      }

      final resolvedPhotoUrl =
          extractPhotoUrlFromMetadata(newUser.userMetadata) ??
          googleUser.photoUrl;
      final resolvedName =
          extractDisplayNameFromMetadata(newUser.userMetadata) ??
          googleUser.displayName;

      return GoogleLinkOutcome(
        userId: newUser.id,
        email: newUser.email ?? googleUser.email,
        switchedUid: switchedUid,
        photoUrl: resolvedPhotoUrl,
        displayName: resolvedName,
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        return null;
      }
      debugPrint(
        'Karrito GoogleSignInException: code=${e.code} '
        'description=${e.description} details=${e.details}',
      );
      throw const AuthActionException(AppStrings.googleTokenError);
    } on AuthActionException {
      rethrow;
    } on AuthException catch (e) {
      debugPrint(
        'Karrito Supabase Google AuthException: '
        'code=${e.code} status=${e.statusCode} message=${e.message}',
      );
      // Avoid a false error if the session actually linked before a secondary exception.
      final activeUser = client.auth.currentUser;
      if (activeUser != null && !activeUser.isAnonymous) {
        return GoogleLinkOutcome(
          userId: activeUser.id,
          email: activeUser.email,
          switchedUid: false,
          photoUrl: extractPhotoUrlFromMetadata(activeUser.userMetadata),
          displayName: extractDisplayNameFromMetadata(activeUser.userMetadata),
        );
      }
      throw const AuthActionException(AppStrings.googleTokenError);
    } catch (e) {
      debugPrint('Karrito unexpected Google sign-in error: $e');
      throw const AuthActionException(AppStrings.googleTokenError);
    }
  }

  /// Signs out from Google and Supabase and quietly restores an anonymous guest
  /// session so the user keeps working locally without losing any Drift lists.
  Future<void> signOutToGuest() async {
    try {
      await _ensureGoogleInitialized();
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      debugPrint('Karrito Google signOut skipped: $e');
    }

    try {
      await _client?.auth.signOut();
    } catch (e) {
      debugPrint('Karrito Supabase signOut warning: $e');
    }

    await ensureSignedInSilently();
  }

  /// Calls the `karrito.delete_my_account()` SECURITY DEFINER RPC to delete all
  /// cloud records and the `auth.users` account, then signs out cleanly into a
  /// fresh anonymous guest session.
  Future<void> deleteAccountPermanently() async {
    final client = _client;
    if (client == null) {
      throw const AuthActionException(
        'No pudimos conectarnos al servidor para eliminar la cuenta. Revisá tu conexión e intentá de nuevo.',
      );
    }

    final hasSession = await ensureSignedInSilently();
    if (!hasSession || client.auth.currentUser == null) {
      throw const AuthActionException(
        'No pudimos validar tu sesión para eliminar la cuenta. Revisá tu conexión e intentá de nuevo.',
      );
    }

    try {
      await client.rpc('delete_my_account');
    } on PostgrestException catch (e) {
      debugPrint(
        'Karrito delete_my_account RPC error: code=${e.code} message=${e.message}',
      );
      throw const AuthActionException(
        'No pudimos eliminar tu cuenta en el servidor ahora. Revisá tu conexión e intentá de nuevo.',
      );
    } catch (e) {
      debugPrint('Karrito delete_my_account unexpected error: $e');
      throw const AuthActionException(
        'No pudimos eliminar tu cuenta en este momento. Probá de nuevo cuando mejore la señal.',
      );
    }

    await signOutToGuest();
  }
}
