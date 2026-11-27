import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../../core/constants/app_strings.dart';

class AuthActionException implements Exception {
  const AuthActionException(this.message, {this.technicalDetails});
  final String message;
  final String? technicalDetails;

  @override
  String toString() =>
      technicalDetails == null ? message : '$message ($technicalDetails)';
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

  /// Formats exact technical details from Google Sign-In, platform channel, or
  /// Supabase exceptions so testers can inspect/copy the real failure cause.
  static String formatTechnicalError(Object error) {
    if (error is GoogleSignInException) {
      final parts = <String>[
        'code=${error.code.name}',
        if (error.description != null && error.description!.trim().isNotEmpty)
          'description=${error.description!.trim()}',
        if (error.details != null) 'details=${error.details}',
      ];
      return 'GoogleSignInException(${parts.join(', ')})';
    }
    if (error is PlatformException) {
      final parts = <String>[
        'code=${error.code}',
        if (error.message != null && error.message!.trim().isNotEmpty)
          'message=${error.message!.trim()}',
        if (error.details != null) 'details=${error.details}',
      ];
      return 'PlatformException(${parts.join(', ')})';
    }
    if (error is AuthException) {
      final parts = <String>[
        if (error.code != null && error.code!.trim().isNotEmpty)
          'code=${error.code!.trim()}',
        if (error.statusCode != null && error.statusCode!.trim().isNotEmpty)
          'status=${error.statusCode!.trim()}',
        if (error.message.trim().isNotEmpty) 'message=${error.message.trim()}',
      ];
      return 'AuthException(${parts.join(', ')})';
    }
    if (error is PostgrestException) {
      final parts = <String>[
        if (error.code != null && error.code!.trim().isNotEmpty)
          'code=${error.code!.trim()}',
        if (error.message.trim().isNotEmpty) 'message=${error.message.trim()}',
        if (error.details != null) 'details=${error.details}',
        if (error.hint != null) 'hint=${error.hint}',
      ];
      return 'PostgrestException(${parts.join(', ')})';
    }
    return '${error.runtimeType}: $error';
  }

  /// Returns `true` only for a genuine user dismissal of the Google picker.
  /// Android Credential Manager occasionally surfaces SHA-1/OAuth console
  /// misconfigurations (e.g. `[28444]` or `[16] reauth failed`) under a
  /// cancellation wrapper; those must NOT be swallowed silently.
  static bool isUserCanceledGoogleSignIn(GoogleSignInException e) {
    if (e.code != GoogleSignInExceptionCode.canceled) return false;
    final desc = (e.description ?? '').trim().toLowerCase();
    if (desc.isEmpty) return true;
    const technicalErrorMarkers = <String>[
      'developer',
      'console',
      'reauth',
      '28444',
      '16:',
      '10:',
      'sha',
      'config',
      'mismatch',
      'credential',
      'token',
      'failed',
      'error',
    ];
    for (final marker in technicalErrorMarkers) {
      if (desc.contains(marker)) return false;
    }
    return true;
  }

  Future<void> _ensureGoogleInitialized() async {
    final serverClientId = SupabaseConfig.googleWebClientId.trim();
    if (serverClientId.isEmpty) {
      throw const AuthActionException(
        AppStrings.googleTokenError,
        technicalDetails:
            'Missing SupabaseConfig.googleWebClientId (client_type: 3).',
      );
    }
    _googleInitFuture ??= GoogleSignIn.instance.initialize(
      serverClientId: serverClientId,
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
      throw const AuthActionException(
        AppStrings.googleOfflineError,
        technicalDetails: 'SupabaseClient is null (not initialized).',
      );
    }

    try {
      await _ensureGoogleInitialized();

      final googleUser = await GoogleSignIn.instance.authenticate();
      final idToken = googleUser.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        debugPrint(
          'Karrito AuthService: Google returned null/empty idToken for ${googleUser.email}',
        );
        throw AuthActionException(
          AppStrings.googleTokenError,
          technicalDetails:
              'GoogleSignIn returned empty idToken for ${googleUser.email}.',
        );
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
        throw const AuthActionException(
          AppStrings.googleTokenError,
          technicalDetails:
              'Supabase auth.currentUser remained null after Google ID token exchange.',
        );
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
      if (isUserCanceledGoogleSignIn(e)) {
        return null;
      }
      final tech = formatTechnicalError(e);
      debugPrint('Karrito $tech');
      throw AuthActionException(
        AppStrings.googleTokenError,
        technicalDetails: tech,
      );
    } on PlatformException catch (e) {
      final tech = formatTechnicalError(e);
      debugPrint('Karrito Google sign-in $tech');
      throw AuthActionException(
        AppStrings.googleTokenError,
        technicalDetails: tech,
      );
    } on AuthActionException {
      rethrow;
    } on AuthException catch (e) {
      final tech = formatTechnicalError(e);
      debugPrint('Karrito Supabase Google $tech');
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
      throw AuthActionException(
        AppStrings.googleTokenError,
        technicalDetails: tech,
      );
    } catch (e) {
      final tech = formatTechnicalError(e);
      debugPrint('Karrito unexpected Google sign-in error: $tech');
      throw AuthActionException(
        AppStrings.googleTokenError,
        technicalDetails: tech,
      );
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
