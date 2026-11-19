/// Result of splitting a free-text user input before checking `local_learned_items`
/// or invoking the `procesar-lista` Edge Function.
class TextParseResult {
  const TextParseResult({
    required this.isComplex,
    required this.candidates,
    required this.originalText,
  });

  /// True when the input appears conversational, is a recipe/request sentence,
  /// or uses connectors like " y " / " para " that benefit from full AI context.
  final bool isComplex;
  final List<ParsedCandidate> candidates;
  final String originalText;
}

class ParsedCandidate {
  const ParsedCandidate({
    required this.rawText,
    required this.cleanName,
    required this.normalizedName,
    required this.quantity,
    required this.unit,
  });

  final String rawText;
  final String cleanName;
  final String normalizedName;
  final double quantity;
  final String unit;
}

class ItemTextParser {
  ItemTextParser._();

  static final RegExp _splitPattern = RegExp(r'(?:\r?\n|;|(?<!\d),(?!\d))+');
  static final RegExp _leadingBulletPattern = RegExp(r'^(?:[-*•]+|\d+[.)])\s+');
  static final RegExp _complexHintPattern = RegExp(
    r'\b(?:necesito|quiero|falta|faltan|comprame|decime|hacer|preparar|armar|algo\s+para|sin\s+que|para\s+(?:hacer|preparar|armar|destapar|arreglar|limpiar|pintar|el|la|los|las|un|una))\b',
    caseSensitive: false,
  );
  static final RegExp _conjunctionPattern = RegExp(
    r'\s+(?:y|e|o|u)\s+',
    caseSensitive: false,
  );

  static final RegExp _verbalHalfKilo = RegExp(
    r'^medi[oa]\s+(?:kilo|kg)(?:\s+de)?\s+(.+)$',
    caseSensitive: false,
  );
  static final RegExp _verbalQuarterKilo = RegExp(
    r'^(?:un\s+)?cuarto(?:\s+(?:de\s+)?(?:kilo|kg))?(?:\s+de)?\s+(.+)$',
    caseSensitive: false,
  );
  static final RegExp _verbalHalfDozen = RegExp(
    r'^medi[oa]\s+docena(?:\s+de)?\s+(.+)$',
    caseSensitive: false,
  );
  static final RegExp _fractionQtyPattern = RegExp(
    r'^(\d+)\s*/\s*(\d+)(?:\s*(kg|kilos?|k|g|grs?|gramos?|l|lts?|litros?|ml|cc|docena|doc|paquetes?|paq))?(?:\s+de)?\s+(.+)$',
    caseSensitive: false,
  );
  static final RegExp _numericQtyUnitPattern = RegExp(
    r'^(\d+(?:[.,]\d+)?)\s*(?:x\s+)?(kg|kgs|kilos?|k|grs?|gramos?|g|lts?|litros?|l|ml|cc|u|un|uds?|unidades?|paquetes?|paq|atados?|cajas?|latas?|botellas?|bot|docenas?|doc|metros?|mts?|m|bl[ií]ster|tiras?)?\b(?:\s+de)?\s+(.+)$',
    caseSensitive: false,
  );
  static final RegExp _trailingXQtyPattern = RegExp(
    r'^(.+?)\s*[x×]\s*(\d+(?:[.,]\d+)?)$',
    caseSensitive: false,
  );

  /// Lowercase key without Spanish vowel accents (`áéíóúü` -> `aeiouu`) and
  /// collapsed spaces. Matches `local_learned_items.normalizedName`.
  static String normalizeProductName(String input) {
    const accents = 'áéíóúüÁÉÍÓÚÜàèìòùÀÈÌÒÙâêîôûÂÊÎÔÛ';
    const plain = 'aeiouuAEIOUUaeiouAEIOUaeiouAEIOU';
    final buffer = StringBuffer();
    for (final rune in input.trim().runes) {
      final ch = String.fromCharCode(rune);
      final idx = accents.indexOf(ch);
      buffer.write(idx >= 0 ? plain[idx] : ch);
    }
    return buffer
        .toString()
        .toLowerCase()
        .replaceAll(RegExp(r'^[,.;:\-_]+|[,.;:\-_]+$'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String normalizeUnit(String? rawUnit) {
    if (rawUnit == null || rawUnit.trim().isEmpty) {
      return 'u';
    }
    final folded = normalizeProductName(rawUnit);
    switch (folded) {
      case 'k':
      case 'kg':
      case 'kgs':
      case 'kilo':
      case 'kilos':
      case 'kilogramo':
      case 'kilogramos':
        return 'kg';
      case 'g':
      case 'gr':
      case 'grs':
      case 'gramo':
      case 'gramos':
        return 'g';
      case 'l':
      case 'lt':
      case 'lts':
      case 'litro':
      case 'litros':
        return 'l';
      case 'ml':
      case 'cc':
      case 'mililitro':
      case 'mililitros':
        return 'ml';
      case 'u':
      case 'un':
      case 'ud':
      case 'uds':
      case 'unidad':
      case 'unidades':
        return 'u';
      case 'paq':
      case 'paquete':
      case 'paquetes':
      case 'atado':
      case 'atados':
        return 'paquete';
      case 'caja':
      case 'cajas':
        return 'caja';
      case 'lata':
      case 'latas':
        return 'lata';
      case 'bot':
      case 'botella':
      case 'botellas':
        return 'botella';
      case 'doc':
      case 'docena':
      case 'docenas':
        return 'docena';
      case 'm':
      case 'mt':
      case 'mts':
      case 'metro':
      case 'metros':
        return 'metro';
      case 'blister':
      case 'tira':
      case 'tiras':
        return 'blíster';
      default:
        return folded;
    }
  }

  /// Splits input by newlines/commas into candidates and indicates whether
  /// full-text AI parsing should be preferred (`isComplex`).
  static TextParseResult parseInput(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return const TextParseResult(
        isComplex: false,
        candidates: <ParsedCandidate>[],
        originalText: '',
      );
    }

    final rawSegments = trimmed
        .split(_splitPattern)
        .map((s) => s.replaceFirst(_leadingBulletPattern, '').trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (rawSegments.isEmpty) {
      return TextParseResult(
        isComplex: true,
        candidates: const <ParsedCandidate>[],
        originalText: trimmed,
      );
    }

    var isComplex = false;
    final candidates = <ParsedCandidate>[];

    for (final segment in rawSegments) {
      final wordCount = segment.split(RegExp(r'\s+')).length;
      if (wordCount > 6 ||
          _complexHintPattern.hasMatch(segment) ||
          _conjunctionPattern.hasMatch(segment) ||
          segment.contains('?') ||
          segment.contains('!')) {
        isComplex = true;
      }
      candidates.add(parseSingleSegment(segment));
    }

    return TextParseResult(
      isComplex: isComplex,
      candidates: candidates,
      originalText: trimmed,
    );
  }

  static ParsedCandidate parseSingleSegment(String segment) {
    final cleanedRaw = segment.trim();
    var qty = 1.0;
    var unit = 'u';
    var namePart = cleanedRaw;

    final halfKiloMatch = _verbalHalfKilo.firstMatch(cleanedRaw);
    final quarterKiloMatch = _verbalQuarterKilo.firstMatch(cleanedRaw);
    final halfDozenMatch = _verbalHalfDozen.firstMatch(cleanedRaw);
    final fractionMatch = _fractionQtyPattern.firstMatch(cleanedRaw);
    final numericMatch = _numericQtyUnitPattern.firstMatch(cleanedRaw);
    final trailingMatch = _trailingXQtyPattern.firstMatch(cleanedRaw);

    if (halfKiloMatch != null) {
      qty = 0.5;
      unit = 'kg';
      namePart = halfKiloMatch.group(1)!.trim();
    } else if (quarterKiloMatch != null) {
      qty = 0.25;
      unit = 'kg';
      namePart = quarterKiloMatch.group(1)!.trim();
    } else if (halfDozenMatch != null) {
      qty = 0.5;
      unit = 'docena';
      namePart = halfDozenMatch.group(1)!.trim();
    } else if (fractionMatch != null) {
      final numPart = double.tryParse(fractionMatch.group(1)!) ?? 1;
      final denPart = double.tryParse(fractionMatch.group(2)!) ?? 1;
      qty = denPart == 0 ? 1.0 : numPart / denPart;
      unit = normalizeUnit(fractionMatch.group(3));
      namePart = fractionMatch.group(4)!.trim();
    } else if (numericMatch != null) {
      final rawNumber = numericMatch.group(1)!.replaceAll(',', '.');
      qty = double.tryParse(rawNumber) ?? 1.0;
      if (qty <= 0) qty = 1.0;
      unit = normalizeUnit(numericMatch.group(2));
      namePart = numericMatch.group(3)!.trim();
    } else if (trailingMatch != null) {
      final rawNumber = trailingMatch.group(2)!.replaceAll(',', '.');
      qty = double.tryParse(rawNumber) ?? 1.0;
      if (qty <= 0) qty = 1.0;
      namePart = trailingMatch.group(1)!.trim();
    }

    // Strip leftover leading "de " if quantity didn't have a unit (e.g. "medio de ...")
    namePart = namePart.replaceFirst(
      RegExp(r'^de\s+', caseSensitive: false),
      '',
    );

    final formattedName = toSentenceCase(
      namePart.isEmpty ? cleanedRaw : namePart,
    );
    return ParsedCandidate(
      rawText: cleanedRaw,
      cleanName: formattedName,
      normalizedName: normalizeProductName(formattedName),
      quantity: qty,
      unit: unit,
    );
  }

  static String toSentenceCase(String value) {
    final trimmed = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (trimmed.isEmpty) return '';
    return '${trimmed[0].toUpperCase()}${trimmed.substring(1)}';
  }
}
