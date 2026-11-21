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
  });

  final String userId;
  final String? email;
  final bool switchedUid;
}

/// Handles silent anonymous login and native Google Sign-In linking.
class AuthService {
  AuthService(this._client);

  final SupabaseClient _client;
  Future<void>? _googleInitFuture;

  Session? get currentSession => _client.auth.currentSession;
  String? get currentUserId => _client.auth.currentUser?.id;
  bool get isAnonymous => _client.auth.currentUser?.isAnonymous ?? true;
  String? get currentEmail => _client.auth.currentUser?.email;
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  /// Signs in anonymously if no session is present. Never throws on network
  /// errors so the offline-first UI stays responsive without signal.
  Future<bool> ensureSignedInSilently() async {
    final existing = _client.auth.currentSession;
    if (existing != null && !existing.isExpired) {
      return true;
    }

    try {
      if (existing != null && existing.isExpired) {
        final refreshed = await _client.auth.refreshSession();
        if (refreshed.session != null) {
          return true;
        }
      }
      final response = await _client.auth.signInAnonymously();
      return response.session != null;
    } catch (error) {
      debugPrint('Karrito AuthService silent sign-in skipped: $error');
      return _client.auth.currentSession != null;
    }
  }

  /// Launches Google account picker, extracts the ID token for Supabase, and
  /// links the anonymous account (or signs into an existing Google account
  /// while signaling `switchedUid` so local Drift data can be merged cleanly).
  /// Returns `null` if the user cancels the picker.
  Future<GoogleLinkOutcome?> linkOrSignInWithGoogle() async {
    try {
      _googleInitFuture ??= GoogleSignIn.instance.initialize(
        serverClientId: SupabaseConfig.googleWebClientId,
      );
      await _googleInitFuture;

      final googleUser = await GoogleSignIn.instance.authenticate();
      final idToken = googleUser.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AuthActionException(AppStrings.googleTokenError);
      }

      await ensureSignedInSilently();
      final previousUid = _client.auth.currentUser?.id;
      var switchedUid = false;

      if (_client.auth.currentUser?.isAnonymous == true) {
        try {
          await _client.auth.linkIdentityWithIdToken(
            provider: OAuthProvider.google,
            idToken: idToken,
          );
        } on AuthException catch (e) {
          final lower = e.message.toLowerCase();
          final isExistingIdentity =
              e.code == 'identity_already_exists' ||
              e.statusCode == '422' ||
              lower.contains('already') ||
              lower.contains('exists') ||
              lower.contains('identity');

          if (!isExistingIdentity) {
            rethrow;
          }

          await _client.auth.signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: idToken,
          );
          switchedUid = _client.auth.currentUser?.id != previousUid;
        }
      } else {
        await _client.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
        );
        switchedUid = _client.auth.currentUser?.id != previousUid;
      }

      final newUser = _client.auth.currentUser;
      if (newUser == null) {
        throw const AuthActionException(AppStrings.googleTokenError);
      }

      return GoogleLinkOutcome(
        userId: newUser.id,
        email: newUser.email ?? googleUser.email,
        switchedUid: switchedUid,
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        return null;
      }
      debugPrint('Karrito GoogleSignInException: ${e.code} ${e.description}');
      throw const AuthActionException(AppStrings.googleTokenError);
    } on AuthActionException {
      rethrow;
    } on AuthException catch (e) {
      debugPrint('Karrito Supabase Google AuthException: ${e.message}');
      throw const AuthActionException(AppStrings.googleTokenError);
    } catch (e) {
      debugPrint('Karrito unexpected Google sign-in error: $e');
      throw const AuthActionException(AppStrings.googleTokenError);
    }
  }
}
