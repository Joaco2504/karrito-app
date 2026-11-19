import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/store_hierarchy.dart';
import '../local/app_database.dart';

class ShareService {
  /// Formats pending items grouped by store and aisle for WhatsApp/plain text.
  /// Checked items are omitted cleanly.
  static String? buildFormattedList({
    required String listTitle,
    required List<ShoppingItemEntity> items,
    required Map<(String, String), int> aisleOrders,
  }) {
    final pendingItems = items.where((item) => !item.isChecked).toList();
    if (pendingItems.isEmpty) {
      return null;
    }

    final checkedCount = items.length - pendingItems.length;
    final byStore = <String, List<ShoppingItemEntity>>{};
    for (final item in pendingItems) {
      byStore
          .putIfAbsent(item.storeCategory, () => <ShoppingItemEntity>[])
          .add(item);
    }

    final sortedStores = byStore.keys.toList()
      ..sort((a, b) {
        final idxA = StoreHierarchy.storeOrder.indexOf(a);
        final idxB = StoreHierarchy.storeOrder.indexOf(b);
        final rankA = idxA >= 0 ? idxA : 999;
        final rankB = idxB >= 0 ? idxB : 999;
        if (rankA != rankB) return rankA.compareTo(rankB);
        return a.compareTo(b);
      });

    final buffer = StringBuffer()
      ..writeln('${AppStrings.shareHeader} ($listTitle)')
      ..writeln();

    for (final store in sortedStores) {
      buffer.writeln('*$store*');
      final storeItems = byStore[store]!;
      final byAisle = <String, List<ShoppingItemEntity>>{};
      for (final item in storeItems) {
        byAisle
            .putIfAbsent(item.aisleName, () => <ShoppingItemEntity>[])
            .add(item);
      }

      final sortedAisles = byAisle.keys.toList()
        ..sort((a, b) {
          final orderA = aisleOrders[(store, a)] ?? 500;
          final orderB = aisleOrders[(store, b)] ?? 500;
          if (orderA != orderB) return orderA.compareTo(orderB);
          return a.compareTo(b);
        });

      for (final aisle in sortedAisles) {
        buffer.writeln('_${aisle}_');
        final aisleItems = byAisle[aisle]!
          ..sort((a, b) => a.position.compareTo(b.position));
        for (final item in aisleItems) {
          buffer.writeln(
            '- ${formatQuantity(item.quantity)} ${item.unit} ${item.cleanName}',
          );
        }
      }
      buffer.writeln();
    }

    if (checkedCount > 0) {
      buffer.writeln(AppStrings.shareRemainingCheckedNote);
    }

    return buffer.toString().trim();
  }

  static Future<bool> shareShoppingList({
    required String listTitle,
    required List<ShoppingItemEntity> items,
    required Map<(String, String), int> aisleOrders,
  }) async {
    final text = buildFormattedList(
      listTitle: listTitle,
      items: items,
      aisleOrders: aisleOrders,
    );
    if (text == null) {
      return false;
    }
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: '${AppStrings.shareHeader} ($listTitle)',
      ),
    );
    return true;
  }

  static String formatQuantity(double quantity) {
    if ((quantity - quantity.roundToDouble()).abs() < 0.001) {
      return quantity.round().toString();
    }
    return quantity.toStringAsFixed(1);
  }
}
