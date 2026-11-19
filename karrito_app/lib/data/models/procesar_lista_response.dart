import '../../core/constants/store_hierarchy.dart';
import '../../domain/services/item_text_parser.dart';

class ProcessedAiItem {
  const ProcessedAiItem({
    required this.cleanName,
    required this.quantity,
    required this.unit,
    required this.storeCategory,
    required this.aisleName,
  });

  final String cleanName;
  final double quantity;
  final String unit;
  final String storeCategory;
  final String aisleName;

  factory ProcessedAiItem.fromJson(Map<String, dynamic> json) {
    final rawName = (json['clean_name'] ?? '').toString().trim();
    final cleanName = rawName.isEmpty
        ? 'Producto'
        : ItemTextParser.toSentenceCase(rawName);

    final rawQty = json['quantity'];
    final parsedQty = rawQty is num
        ? rawQty.toDouble()
        : double.tryParse(rawQty?.toString().replaceAll(',', '.') ?? '') ?? 1.0;
    final quantity = parsedQty > 0 ? parsedQty : 1.0;

    final rawUnit = json['unit']?.toString();
    final unit = ItemTextParser.normalizeUnit(rawUnit);

    final storeCategory = StoreHierarchy.normalizeStore(
      json['store_category']?.toString(),
    );
    final aisleName = StoreHierarchy.normalizeAisle(
      storeCategory,
      json['aisle_name']?.toString(),
    );

    return ProcessedAiItem(
      cleanName: cleanName,
      quantity: quantity,
      unit: unit,
      storeCategory: storeCategory,
      aisleName: aisleName,
    );
  }
}

class AiQuotaInfo {
  const AiQuotaInfo({
    required this.planTier,
    required this.dailyAiCount,
    this.dailyAiLimit,
    this.remaining,
  });

  final String planTier;
  final int dailyAiCount;
  final int? dailyAiLimit;
  final int? remaining;

  factory AiQuotaInfo.fromJson(Map<String, dynamic> json) {
    return AiQuotaInfo(
      planTier: (json['plan_tier'] ?? 'free').toString(),
      dailyAiCount: (json['daily_ai_count'] as num?)?.toInt() ?? 0,
      dailyAiLimit: (json['daily_ai_limit'] as num?)?.toInt(),
      remaining: (json['remaining'] as num?)?.toInt(),
    );
  }
}

class ProcesarListaResponse {
  const ProcesarListaResponse({required this.items, this.quota});

  final List<ProcessedAiItem> items;
  final AiQuotaInfo? quota;

  factory ProcesarListaResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    if (rawItems is! List) {
      throw const FormatException(
        'La respuesta del servidor no incluyó el arreglo items.',
      );
    }

    final parsedItems = rawItems
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (item) => ProcessedAiItem.fromJson(Map<String, dynamic>.from(item)),
        )
        .where((item) => item.cleanName.isNotEmpty)
        .toList();

    final rawQuota = json['quota'];
    final quota = rawQuota is Map<dynamic, dynamic>
        ? AiQuotaInfo.fromJson(Map<String, dynamic>.from(rawQuota))
        : null;

    return ProcesarListaResponse(items: parsedItems, quota: quota);
  }
}
