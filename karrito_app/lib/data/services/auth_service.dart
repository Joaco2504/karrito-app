import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Handles silent anonymous authentication without ever blocking offline usage.
class AuthService {
  AuthService(this._client);

  final SupabaseClient _client;

  Session? get currentSession => _client.auth.currentSession;
  String? get currentUserId => _client.auth.currentUser?.id;

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
}
