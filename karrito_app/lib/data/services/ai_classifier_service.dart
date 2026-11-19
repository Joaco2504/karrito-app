import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_strings.dart';
import '../models/procesar_lista_response.dart';
import 'auth_service.dart';

sealed class AiClassifierException implements Exception {
  const AiClassifierException(this.userMessage);
  final String userMessage;

  @override
  String toString() => userMessage;
}

class AiOfflineOrNetworkException extends AiClassifierException {
  const AiOfflineOrNetworkException([
    super.userMessage = AppStrings.networkFallbackError,
  ]);
}

class AiQuotaExceededException extends AiClassifierException {
  const AiQuotaExceededException([
    super.userMessage = AppStrings.dailyLimitError,
  ]);
}

class AiUserBannedException extends AiClassifierException {
  const AiUserBannedException(super.userMessage);
}

class AiProcessingException extends AiClassifierException {
  const AiProcessingException(super.userMessage);
}

abstract interface class AiClassifierService {
  Future<ProcesarListaResponse> classifyText(String text);
}

class SupabaseAiClassifierService implements AiClassifierService {
  SupabaseAiClassifierService({
    required this._client,
    required this._authService,
  });

  final SupabaseClient _client;
  final AuthService _authService;

  @override
  Future<ProcesarListaResponse> classifyText(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw const AiProcessingException(AppStrings.emptyInputError);
    }

    // Ensure a valid anonymous JWT exists if the app first launched offline.
    final hasSession = await _authService.ensureSignedInSilently();
    if (!hasSession) {
      throw const AiOfflineOrNetworkException();
    }

    try {
      final response = await _client.functions
          .invoke('procesar-lista', body: <String, dynamic>{'text': trimmed})
          .timeout(const Duration(seconds: 25));

      final payload = _normalizeJsonMap(response.data);
      return ProcesarListaResponse.fromJson(payload);
    } on TimeoutException {
      throw const AiOfflineOrNetworkException();
    } on SocketException {
      throw const AiOfflineOrNetworkException();
    } on FunctionException catch (e) {
      if (e.status == 0) {
        throw const AiOfflineOrNetworkException();
      }
      final details = _tryNormalizeJsonMap(e.details);
      final code = details?['code']?.toString();
      final serverMessage = details?['error']?.toString().trim();

      if (code == 'DAILY_LIMIT_REACHED' || e.status == 429) {
        throw AiQuotaExceededException(
          (serverMessage != null && serverMessage.isNotEmpty)
              ? serverMessage
              : AppStrings.dailyLimitError,
        );
      }

      if (code == 'USER_BANNED' || e.status == 403) {
        throw AiUserBannedException(
          (serverMessage != null && serverMessage.isNotEmpty)
              ? serverMessage
              : 'Tu cuenta no puede usar el asistente en este momento.',
        );
      }

      if (e.status == 401) {
        // Attempt one silent session refresh/re-auth before failing.
        final recovered = await _recoverSessionAndRetry(trimmed);
        if (recovered != null) {
          return recovered;
        }
      }

      throw AiProcessingException(
        (serverMessage != null && serverMessage.isNotEmpty)
            ? serverMessage
            : AppStrings.genericProcessingError,
      );
    } on FormatException {
      throw const AiProcessingException(AppStrings.genericProcessingError);
    } catch (e) {
      final lower = e.toString().toLowerCase();
      if (lower.contains('socket') ||
          lower.contains('host lookup') ||
          lower.contains('network') ||
          lower.contains('connection') ||
          lower.contains('clientexception')) {
        throw const AiOfflineOrNetworkException();
      }
      throw const AiProcessingException(AppStrings.genericProcessingError);
    }
  }

  Future<ProcesarListaResponse?> _recoverSessionAndRetry(String text) async {
    try {
      await _client.auth.signInAnonymously();
      final retry = await _client.functions
          .invoke('procesar-lista', body: <String, dynamic>{'text': text})
          .timeout(const Duration(seconds: 25));
      return ProcesarListaResponse.fromJson(_normalizeJsonMap(retry.data));
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _normalizeJsonMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    if (raw is String && raw.trim().isNotEmpty) {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    }
    throw const FormatException('Respuesta JSON inesperada.');
  }

  Map<String, dynamic>? _tryNormalizeJsonMap(dynamic raw) {
    if (raw == null) return null;
    try {
      return _normalizeJsonMap(raw);
    } catch (_) {
      return null;
    }
  }
}
