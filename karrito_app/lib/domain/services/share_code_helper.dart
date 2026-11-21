import 'dart:math';

/// Validation, normalization, and generation helpers for 6-character live
/// collaborative list share codes (`karrito.shopping_lists.share_code`).
class ShareCodeHelper {
  ShareCodeHelper._();

  /// Excludes visually ambiguous characters (`0`, `O`, `1`, `I`, `L`).
  static const String _alphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  static const int codeLength = 6;
  static final RegExp _validPattern = RegExp(r'^[A-Z0-9]{6}$');

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
