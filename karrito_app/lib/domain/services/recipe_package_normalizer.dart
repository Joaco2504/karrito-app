import '../../data/models/procesar_lista_response.dart';
import 'item_text_parser.dart';

/// Deterministic client-side safety net ensuring recipe micro-quantities
/// (e.g. `100 g azúcar`, `150 ml aceite`, `200 g harina`) are normalized into
/// real Argentine retail packages while preserving the original culinary note
/// (`"100 g para la receta"`) so the user never buys too little or loses track
/// of how much the dish calls for.
class RecipePackageNormalizer {
  RecipePackageNormalizer._();

  static const String notePrefix = 'Receta: ';

  /// Formats a recipe note for storage in `local_items.raw_text` (which also
  /// syncs to `karrito.list_items.raw_text` without extra schema migrations).
  static String encodeRawText({
    required String fallbackRawText,
    String? recipeNote,
  }) {
    final trimmed = recipeNote?.trim() ?? '';
    if (trimmed.isEmpty) return fallbackRawText;
    return '$notePrefix$trimmed';
  }

  /// Extracts the visible recipe note if [rawText] was stored with [notePrefix].
  static String? extractRecipeNote(String rawText) {
    if (!rawText.startsWith(notePrefix)) return null;
    final extracted = rawText.substring(notePrefix.length).trim();
    return extracted.isEmpty ? null : extracted;
  }

  /// Normalizes a list of recipe items returned by Gemini (`is_recipe: true`).
  /// Items that already come normalized with a `recipeNote` from Gemini are
  /// preserved verbatim; raw micro-quantities are converted to standard
  /// Argentine supermarket packages.
  static List<ProcessedAiItem> normalizeRecipeItems(
    List<ProcessedAiItem> items, {
    String? dishLabel,
  }) {
    final cleanDish = _extractShortDishLabel(dishLabel);
    return items
        .map((item) => normalizeSingleItem(item, shortDishLabel: cleanDish))
        .toList();
  }

  static ProcessedAiItem normalizeSingleItem(
    ProcessedAiItem item, {
    String? shortDishLabel,
  }) {
    final existingNote = item.recipeNote?.trim();
    final normalizedKey = ItemTextParser.normalizeProductName(item.cleanName);
    final unit = item.unit.toLowerCase();
    final qty = item.quantity;
    final suffix = shortDishLabel != null && shortDishLabel.isNotEmpty
        ? ' para $shortDishLabel'
        : ' para la receta';

    String formatOrig(double q, String u) {
      if (existingNote != null && existingNote.isNotEmpty) {
        return existingNote;
      }
      final numStr = q == q.roundToDouble()
          ? q.toInt().toString()
          : q.toStringAsFixed(1).replaceAll('.', ',');
      return '$numStr $u$suffix';
    }

    // Dry staples sold in 1 kg packs in Argentina (azúcar, harina, arroz, polenta, sal).
    if (_matchesAny(normalizedKey, const <String>[
      'azucar',
      'harina',
      'arroz',
      'polenta',
      'yerba',
    ])) {
      if ((unit == 'g' && qty > 0 && qty < 1000) ||
          (unit == 'kg' && qty > 0 && qty < 0.5)) {
        return ProcessedAiItem(
          cleanName: item.cleanName,
          quantity: 1,
          unit: 'kg',
          storeCategory: item.storeCategory,
          aisleName: item.aisleName,
          recipeNote: formatOrig(qty, unit),
        );
      }
    }

    // Cooking oils & vinegar sold in 900 ml / 1 L bottles in Argentina.
    if (_matchesAny(normalizedKey, const <String>[
      'aceite',
      'vinagre',
      'aceto',
    ])) {
      if ((unit == 'ml' && qty > 0 && qty < 900) ||
          (unit == 'l' && qty > 0 && qty < 0.9)) {
        return ProcessedAiItem(
          cleanName: item.cleanName,
          quantity: 1,
          unit: 'l',
          storeCategory: item.storeCategory,
          aisleName: item.aisleName,
          recipeNote: formatOrig(qty, unit),
        );
      }
    }

    // Milk sold in 1 L sachet / carton.
    if (_matchesAny(normalizedKey, const <String>['leche']) &&
        !normalizedKey.contains('condensada') &&
        !normalizedKey.contains('polvo')) {
      if ((unit == 'ml' && qty > 0 && qty < 1000) ||
          (unit == 'l' && qty > 0 && qty < 1.0)) {
        return ProcessedAiItem(
          cleanName: item.cleanName,
          quantity: 1,
          unit: 'l',
          storeCategory: item.storeCategory,
          aisleName: item.aisleName,
          recipeNote: formatOrig(qty, unit),
        );
      }
    }

    // Butter / margarine sold in 100 g or 200 g panes.
    if (_matchesAny(normalizedKey, const <String>['manteca', 'margarina'])) {
      if (unit == 'g' && qty > 0 && qty < 100) {
        return ProcessedAiItem(
          cleanName: item.cleanName,
          quantity: 100,
          unit: 'g',
          storeCategory: item.storeCategory,
          aisleName: item.aisleName,
          recipeNote: formatOrig(qty, unit),
        );
      }
      if (unit == 'g' && qty > 100 && qty < 200) {
        return ProcessedAiItem(
          cleanName: item.cleanName,
          quantity: 200,
          unit: 'g',
          storeCategory: item.storeCategory,
          aisleName: item.aisleName,
          recipeNote: formatOrig(qty, unit),
        );
      }
    }

    // Cream / dulce de leche sold in 200 g / 250 g / 400 g tubs.
    if (_matchesAny(normalizedKey, const <String>['crema de leche', 'crema']) &&
        !normalizedKey.contains('dental') &&
        !normalizedKey.contains('corporal')) {
      if ((unit == 'ml' || unit == 'g') && qty > 0 && qty < 200) {
        return ProcessedAiItem(
          cleanName: item.cleanName,
          quantity: 200,
          unit: 'ml',
          storeCategory: item.storeCategory,
          aisleName: item.aisleName,
          recipeNote: formatOrig(qty, unit),
        );
      }
    }

    // Eggs sold in half-dozen (6) or dozen (12) cartons.
    if (_matchesAny(normalizedKey, const <String>['huevo', 'huevos'])) {
      if (unit == 'u' && qty > 0 && qty < 6) {
        return ProcessedAiItem(
          cleanName: item.cleanName,
          quantity: 6,
          unit: 'u',
          storeCategory: item.storeCategory,
          aisleName: item.aisleName,
          recipeNote: formatOrig(qty, 'u'),
        );
      }
      if (unit == 'u' && qty > 6 && qty < 12) {
        return ProcessedAiItem(
          cleanName: item.cleanName,
          quantity: 12,
          unit: 'u',
          storeCategory: item.storeCategory,
          aisleName: item.aisleName,
          recipeNote: formatOrig(qty, 'u'),
        );
      }
    }

    // Salt sold in 500 g packet.
    if (normalizedKey == 'sal' ||
        normalizedKey.startsWith('sal fina') ||
        normalizedKey.startsWith('sal gruesa')) {
      if (unit == 'g' && qty > 0 && qty < 500) {
        return ProcessedAiItem(
          cleanName: item.cleanName,
          quantity: 500,
          unit: 'g',
          storeCategory: item.storeCategory,
          aisleName: item.aisleName,
          recipeNote: formatOrig(qty, unit),
        );
      }
    }

    // Vanilla essence / baking powder / spices sold as 1 bottle / sachet.
    if (_matchesAny(normalizedKey, const <String>[
      'esencia de vainilla',
      'vainilla',
      'polvo de hornear',
      'levadura',
      'comino',
      'pimenton',
      'oregano',
      'canela',
      'pimienta',
    ])) {
      const spoonUnits = <String>{
        'cdita',
        'cditas',
        'cda',
        'cdas',
        'cucharadita',
        'cucharaditas',
        'cucharada',
        'cucharadas',
        'pizca',
        'gotas',
      };
      if (((unit == 'g' || unit == 'ml') && qty > 0 && qty <= 50) ||
          spoonUnits.contains(unit)) {
        return ProcessedAiItem(
          cleanName: item.cleanName,
          quantity: 1,
          unit: 'u',
          storeCategory: item.storeCategory,
          aisleName: item.aisleName,
          recipeNote: formatOrig(qty, unit),
        );
      }
    }

    return item;
  }

  static bool _matchesAny(String normalized, List<String> keywords) {
    for (final k in keywords) {
      if (normalized == k ||
          normalized.startsWith('$k ') ||
          normalized.contains(' $k')) {
        return true;
      }
    }
    return false;
  }

  static String? _extractShortDishLabel(String? raw) {
    final trimmed = raw?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    final firstLine = trimmed.split(RegExp(r'[\n\r:,.]')).first.trim();
    if (firstLine.isEmpty || firstLine.length > 36) return null;
    return firstLine.toLowerCase();
  }
}
