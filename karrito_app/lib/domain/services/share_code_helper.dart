import 'dart:math';

/// Validation, normalization, QR payload parsing, and generation helpers for
/// 6-character live collaborative list share codes
/// (`karrito.shopping_lists.share_code`).
class ShareCodeHelper {
  ShareCodeHelper._();

  /// Excludes visually ambiguous characters (`0`, `O`, `1`, `I`, `L`).
  static const String _alphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  static const int codeLength = 6;
  static const String joinUriPrefix = 'karrito://join/';
  static final RegExp _validPattern = RegExp(r'^[A-Z0-9]{6}$');

  /// Builds the canonical QR / deep-link payload for joining a live list.
  static String buildJoinUri(String code) {
    final normalized = normalizeAndValidate(code);
    return '$joinUriPrefix${normalized ?? code.trim().toUpperCase()}';
  }

  /// Normalizes user input (trims whitespace, removes dashes/spaces, uppercases)
  /// and returns the 6-character code, or `null` when invalid.
  static String? normalizeAndValidate(String rawInput) {
    final cleaned = rawInput
        .trim()
        .replaceAll(RegExp(r'[\s\-]+'), '')
        .toUpperCase();
    if (!_validPattern.hasMatch(cleaned)) {
      return null;
    }
    return cleaned;
  }

  /// Extracts a valid 6-character code from either plain text (`K7M4P9`,
  /// `k7m-4p9`), a Karrito QR URI (`karrito://join/K7M4P9`), or an HTTP join
  /// link (`https://.../join/K7M4P9` or `?code=K7M4P9`). Returns `null` if no
  /// valid 6-character code is found.
  static String? extractCodeFromQrOrText(String rawInput) {
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) return null;

    final direct = normalizeAndValidate(trimmed);
    if (direct != null) return direct;

    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.scheme.isNotEmpty) {
      final queryCode = uri.queryParameters['code'];
      if (queryCode != null) {
        final parsed = normalizeAndValidate(queryCode);
        if (parsed != null) return parsed;
      }

      if (uri.scheme.toLowerCase() == 'karrito' &&
          uri.host.toLowerCase() == 'join' &&
          uri.pathSegments.isNotEmpty) {
        final parsed = normalizeAndValidate(uri.pathSegments.first);
        if (parsed != null) return parsed;
      }

      for (var i = 0; i < uri.pathSegments.length; i++) {
        if (uri.pathSegments[i].toLowerCase() == 'join' &&
            i + 1 < uri.pathSegments.length) {
          final parsed = normalizeAndValidate(uri.pathSegments[i + 1]);
          if (parsed != null) return parsed;
        }
      }
    }

    final prefixMatch = RegExp(
      r'karrito://join/([A-Za-z0-9\-\s]{6,10})',
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (prefixMatch != null) {
      final parsed = normalizeAndValidate(prefixMatch.group(1) ?? '');
      if (parsed != null) return parsed;
    }

    return null;
  }

  /// Generates a random 6-character uppercase code.
  static String generateCode([Random? random]) {
    final rng = random ?? Random.secure();
    final buffer = StringBuffer();
    for (var i = 0; i < codeLength; i++) {
      buffer.write(_alphabet[rng.nextInt(_alphabet.length)]);
    }
    return buffer.toString();
  }
}
