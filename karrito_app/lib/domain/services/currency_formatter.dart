import '../../data/local/app_database.dart';

/// Argentine Peso (ARS) formatting and parsing helpers following
/// `.agents/textos-app-es-ar.md` (`$ 12.500` / `$ 12.500,50`).
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Formats [amount] using Argentine thousands `.` and decimal `,` separators.
  static String formatArs(double amount, {bool includeSymbol = true}) {
    final isNegative = amount < 0;
    final abs = amount.abs();
    final isWhole = (abs - abs.roundToDouble()).abs() < 0.005;
    final fixed = isWhole ? abs.round().toString() : abs.toStringAsFixed(2);
    final parts = fixed.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? parts[1] : null;

    final buffer = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      final remaining = intPart.length - i;
      if (i > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(intPart[i]);
    }

    final formattedNumber = decPart != null
        ? '${buffer.toString()},$decPart'
        : buffer.toString();
    final sign = isNegative ? '-' : '';
    return includeSymbol ? '$sign\$ $formattedNumber' : '$sign$formattedNumber';
  }

  /// Parses flexible Argentine numeric inputs (`3800`, `3.800`, `3.800,50`,
  /// `$ 12.500,50`, `3800.50`) into a positive [double], or `null` if invalid.
  static double? parseArs(String raw) {
    var cleaned = raw.trim().replaceAll(r'$', '').replaceAll(' ', '');
    if (cleaned.isEmpty) return null;

    final hasComma = cleaned.contains(',');
    final hasDot = cleaned.contains('.');

    if (hasComma && hasDot) {
      // Standard Argentine: dots are thousands, comma is decimal (`12.500,50`).
      cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
    } else if (hasComma) {
      // Comma decimal (`12500,50`).
      cleaned = cleaned.replaceAll(',', '.');
    } else if (hasDot) {
      // Distinguish thousands separator (`12.500`) from decimal (`12.5` / `12.50`).
      final parts = cleaned.split('.');
      final looksLikeThousands =
          parts.length > 1 &&
          parts.skip(1).every((segment) => segment.length == 3);
      if (looksLikeThousands) {
        cleaned = cleaned.replaceAll('.', '');
      }
    }

    final parsed = double.tryParse(cleaned);
    if (parsed == null || parsed <= 0 || parsed.isNaN || parsed.isInfinite) {
      return null;
    }
    return double.parse(parsed.toStringAsFixed(2));
  }
}

/// Aggregated cart price summary for the Pro Cart Calculator.
class CartPriceSummary {
  const CartPriceSummary({
    required this.totalAmount,
    required this.checkedAmount,
    required this.storeAmount,
    required this.storeCheckedAmount,
    required this.pricedCount,
    required this.unpricedCount,
    required this.totalByStore,
    required this.itemCountByStore,
  });

  final double totalAmount;
  final double checkedAmount;
  final double storeAmount;
  final double storeCheckedAmount;
  final int pricedCount;
  final int unpricedCount;
  final Map<String, double> totalByStore;
  final Map<String, int> itemCountByStore;

  bool get hasAnyPrice => pricedCount > 0;
}

/// Pure calculator for real-time store subtotals and cart totals.
class CartPriceCalculator {
  CartPriceCalculator._();

  static CartPriceSummary summarize({
    required List<ShoppingItemEntity> items,
    String? activeStore,
  }) {
    var totalAmount = 0.0;
    var checkedAmount = 0.0;
    var storeAmount = 0.0;
    var storeCheckedAmount = 0.0;
    var pricedCount = 0;
    var unpricedCount = 0;
    final totalByStore = <String, double>{};
    final itemCountByStore = <String, int>{};

    for (final item in items) {
      final price = item.price;
      if (price != null && price > 0) {
        pricedCount++;
        totalAmount += price;
        if (item.isChecked) {
          checkedAmount += price;
        }
        totalByStore[item.storeCategory] =
            (totalByStore[item.storeCategory] ?? 0.0) + price;
        itemCountByStore[item.storeCategory] =
            (itemCountByStore[item.storeCategory] ?? 0) + 1;

        if (activeStore != null && item.storeCategory == activeStore) {
          storeAmount += price;
          if (item.isChecked) {
            storeCheckedAmount += price;
          }
        }
      } else {
        unpricedCount++;
      }
    }

    return CartPriceSummary(
      totalAmount: double.parse(totalAmount.toStringAsFixed(2)),
      checkedAmount: double.parse(checkedAmount.toStringAsFixed(2)),
      storeAmount: double.parse(storeAmount.toStringAsFixed(2)),
      storeCheckedAmount: double.parse(storeCheckedAmount.toStringAsFixed(2)),
      pricedCount: pricedCount,
      unpricedCount: unpricedCount,
      totalByStore: totalByStore,
      itemCountByStore: itemCountByStore,
    );
  }
}
