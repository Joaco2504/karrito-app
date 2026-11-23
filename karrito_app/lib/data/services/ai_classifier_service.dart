import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_strings.dart';
import '../../domain/services/item_text_parser.dart';
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

class AiProRequiredException extends AiClassifierException {
  const AiProRequiredException(super.userMessage);
}

class AiProcessingException extends AiClassifierException {
  const AiProcessingException(super.userMessage);
}

abstract interface class AiClassifierService {
  Future<ProcesarListaResponse> classifyText(
    String text, {
    bool isRecipe = false,
  });
  Future<ProcesarListaResponse> classifyAudio({
    required String audioBase64,
    String mimeType = 'audio/m4a',
  });
  Future<ProcesarListaResponse> classifyImage({
    required String imageBase64,
    String mimeType = 'image/jpeg',
    bool isRecipe = false,
    String? textHint,
  });
}

class _AiCacheEntry {
  const _AiCacheEntry({required this.response, required this.storedAt});

  final ProcesarListaResponse response;
  final DateTime storedAt;
}

/// In-memory LRU cache with TTL for repeated `procesar-lista` text inputs.
/// Avoids duplicate Edge Function + Gemini calls when a user pastes or retries
/// the same block within [ttl] (30 minutes by default).
class AiResponseCache {
  AiResponseCache({
    this.maxEntries = 40,
    this.ttl = const Duration(minutes: 30),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final int maxEntries;
  final Duration ttl;
  final DateTime Function() _clock;
  final LinkedHashMap<String, _AiCacheEntry> _entries =
      LinkedHashMap<String, _AiCacheEntry>();

  static String normalizeKey(String rawInput) {
    return ItemTextParser.normalizeProductName(rawInput);
  }

  ProcesarListaResponse? get(String rawInput) {
    final key = normalizeKey(rawInput);
    if (key.isEmpty) return null;

    final entry = _entries.remove(key);
    if (entry == null) return null;

    if (_clock().difference(entry.storedAt) >= ttl) {
      return null;
    }

    // Re-insert at tail to mark as most recently used.
    _entries[key] = entry;
    return entry.response;
  }

  void put(String rawInput, ProcesarListaResponse response) {
    final key = normalizeKey(rawInput);
    if (key.isEmpty || response.items.isEmpty) return;

    _entries.remove(key);
    while (_entries.length >= maxEntries) {
      _entries.remove(_entries.keys.first);
    }
    _entries[key] = _AiCacheEntry(response: response, storedAt: _clock());
  }

  void clear() => _entries.clear();

  int get length => _entries.length;
}

typedef AiFunctionInvoker = Future<dynamic> Function(String trimmedText);

class SupabaseAiClassifierService implements AiClassifierService {
  SupabaseAiClassifierService({
    required this._client,
    required this._authService,
    AiResponseCache? cache,
    this._invoker,
  }) : _cache = cache ?? AiResponseCache();

  final SupabaseClient? _client;
  final AuthService _authService;
  final AiResponseCache _cache;
  final AiFunctionInvoker? _invoker;
  final Map<String, Future<ProcesarListaResponse>> _inFlightTextRequests =
      <String, Future<ProcesarListaResponse>>{};

  @override
  Future<ProcesarListaResponse> classifyText(
    String text, {
    bool isRecipe = false,
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return Future<ProcesarListaResponse>.error(
        const AiProcessingException(AppStrings.emptyInputError),
      );
    }

    final cacheKey = isRecipe ? 'recipe::$trimmed' : trimmed;
    final cached = _cache.get(cacheKey);
    if (cached != null) {
      return Future<ProcesarListaResponse>.value(cached);
    }

    // Deduplicate identical concurrent requests while one is already in flight.
    final inFlightKey = AiResponseCache.normalizeKey(cacheKey);
    final existing = _inFlightTextRequests[inFlightKey];
    if (existing != null) {
      return existing;
    }

    final future = _executeClassifyText(
      trimmed: trimmed,
      cacheKey: cacheKey,
      inFlightKey: inFlightKey,
      isRecipe: isRecipe,
    );
    _inFlightTextRequests[inFlightKey] = future;
    return future;
  }

  Future<ProcesarListaResponse> _executeClassifyText({
    required String trimmed,
    required String cacheKey,
    required String inFlightKey,
    required bool isRecipe,
  }) async {
    try {
      // Ensure a valid anonymous JWT exists if the app first launched offline.
      final hasSession = await _authService.ensureSignedInSilently();
      if (!hasSession) {
        throw const AiOfflineOrNetworkException();
      }

      return await _invokeClassifyTextCore(
        trimmed: trimmed,
        cacheKey: cacheKey,
        isRecipe: isRecipe,
      );
    } finally {
      _inFlightTextRequests.remove(inFlightKey);
    }
  }

  Future<ProcesarListaResponse> _invokeClassifyTextCore({
    required String trimmed,
    required String cacheKey,
    required bool isRecipe,
  }) async {
    try {
      final rawData = _invoker != null
          ? await _invoker(trimmed).timeout(const Duration(seconds: 25))
          : (await _client!.functions
                    .invoke(
                      'procesar-lista',
                      body: <String, dynamic>{
                        'text': trimmed,
                        if (isRecipe) 'is_recipe': true,
                      },
                    )
                    .timeout(const Duration(seconds: 30)))
                .data;

      final payload = _normalizeJsonMap(rawData);
      final parsed = ProcesarListaResponse.fromJson(payload);
      _cache.put(cacheKey, parsed);
      return parsed;
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

      if (code == 'PRO_PLAN_REQUIRED') {
        throw AiProRequiredException(
          (serverMessage != null && serverMessage.isNotEmpty)
              ? serverMessage
              : 'El dictado por voz y el escaneo de fotos están disponibles en el plan Pro.',
        );
      }

      if (code == 'USER_BANNED' || e.status == 403) {
        throw AiUserBannedException(
          (serverMessage != null && serverMessage.isNotEmpty)
              ? serverMessage
              : 'Tu cuenta no puede usar el asistente en este momento.',
        );
      }

      if (e.status == 401 && _client != null) {
        // Attempt one silent session refresh/re-auth before failing.
        final recovered = await _recoverSessionAndRetry(
          trimmed,
          isRecipe: isRecipe,
        );
        if (recovered != null) {
          _cache.put(cacheKey, recovered);
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

  @override
  Future<ProcesarListaResponse> classifyAudio({
    required String audioBase64,
    String mimeType = 'audio/m4a',
  }) {
    return _invokeMediaPayload(<String, dynamic>{
      'audio_base64': audioBase64,
      'audio_mime_type': mimeType,
    });
  }

  @override
  Future<ProcesarListaResponse> classifyImage({
    required String imageBase64,
    String mimeType = 'image/jpeg',
    bool isRecipe = false,
    String? textHint,
  }) {
    final trimmedHint = textHint?.trim();
    return _invokeMediaPayload(<String, dynamic>{
      'image_base64': imageBase64,
      'image_mime_type': mimeType,
      if (isRecipe) 'is_recipe': true,
      if (trimmedHint != null && trimmedHint.isNotEmpty) 'text': trimmedHint,
    });
  }

  Future<ProcesarListaResponse> _invokeMediaPayload(
    Map<String, dynamic> body,
  ) async {
    final hasSession = await _authService.ensureSignedInSilently();
    if (!hasSession || _client == null) {
      throw const AiOfflineOrNetworkException();
    }

    try {
      final response = await _client.functions
          .invoke('procesar-lista', body: body)
          .timeout(const Duration(seconds: 40));
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

      if (code == 'PRO_PLAN_REQUIRED') {
        throw AiProRequiredException(
          (serverMessage != null && serverMessage.isNotEmpty)
              ? serverMessage
              : 'El dictado por voz y el escaneo de fotos están disponibles en el plan Pro.',
        );
      }
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

  Future<ProcesarListaResponse?> _recoverSessionAndRetry(
    String text, {
    bool isRecipe = false,
  }) async {
    final client = _client;
    if (client == null) return null;
    try {
      await client.auth.signInAnonymously();
      final retry = await client.functions
          .invoke(
            'procesar-lista',
            body: <String, dynamic>{
              'text': text,
              if (isRecipe) 'is_recipe': true,
            },
          )
          .timeout(const Duration(seconds: 30));
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
