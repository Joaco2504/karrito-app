/// Canonical store hierarchy, locations, and measurement units for Karrito.
class StoreHierarchy {
  StoreHierarchy._();

  static const String defaultListName = 'Compra semanal';
  static const int maxActiveListsPhase2 = 3;

  static const String defaultCity = 'Andalgalá';
  static const List<String> cities = <String>[
    'Andalgalá',
    'Belén',
    'Saujil',
    'Santa María',
    'Otra',
  ];

  static const String fallbackStore = 'Otros / Varios';
  static const String offlinePendingAisle = 'Sin clasificar (sin señal)';

  static const List<String> storeOrder = <String>[
    'Supermercado',
    'Ferretería / Corralón',
    'Farmacia',
    'Librería / Papelería',
    'Dietética / Naturista',
    'Otros / Varios',
  ];

  static const Map<String, List<String>> storeAisles = <String, List<String>>{
    'Supermercado': <String>[
      'Verdulería y Frutería',
      'Carnicería y Pescadería',
      'Fiambrería y Quesos',
      'Lácteos y Refrigerados',
      'Panadería',
      'Almacén',
      'Bebidas',
      'Limpieza',
      'Perfumería e Higiene',
      'Congelados',
      'Mascotas',
    ],
    'Ferretería / Corralón': <String>[
      'Fijaciones',
      'Electricidad e Iluminación',
      'Plomería y Gas',
      'Pinturería',
      'Herramientas',
      'Adhesivos y Selladores',
    ],
    'Farmacia': <String>[
      'Medicamentos',
      'Primeros Auxilios',
      'Cuidado Personal y Dermocosmética',
      'Bebés y Maternidad',
    ],
    'Librería / Papelería': <String>[
      'Útiles Escolares',
      'Oficina',
      'Artística',
    ],
    'Dietética / Naturista': <String>[
      'Frutos Secos y Semillas',
      'Harinas y Cereales',
      'Suplementos',
      'Sin TACC',
    ],
    'Otros / Varios': <String>[
      'Bazar',
      'Indumentaria',
      'Juguetería',
      offlinePendingAisle,
    ],
  };

  static const List<String> commonUnits = <String>[
    'u',
    'kg',
    'g',
    'l',
    'ml',
    'paquete',
    'caja',
    'lata',
    'botella',
    'docena',
    'metro',
    'blíster',
  ];

  /// Returns the canonical store name if it matches (case/accent tolerant),
  /// or [fallbackStore] when unknown.
  static String normalizeStore(String? rawStore) {
    if (rawStore == null || rawStore.trim().isEmpty) {
      return fallbackStore;
    }
    final cleaned = _foldForComparison(rawStore);
    for (final canonical in storeOrder) {
      if (_foldForComparison(canonical) == cleaned) {
        return canonical;
      }
    }
    if (cleaned.contains('super')) return 'Supermercado';
    if (cleaned.contains('ferret') || cleaned.contains('corralon')) {
      return 'Ferretería / Corralón';
    }
    if (cleaned.contains('farmac')) return 'Farmacia';
    if (cleaned.contains('librer') || cleaned.contains('papeler')) {
      return 'Librería / Papelería';
    }
    if (cleaned.contains('dietet') || cleaned.contains('naturist')) {
      return 'Dietética / Naturista';
    }
    return fallbackStore;
  }

  /// Resolves an aisle name against the canonical list for [store], preserving
  /// custom/dynamic aisle names under "Otros / Varios" when appropriate.
  static String normalizeAisle(String store, String? rawAisle) {
    final normalizedStore = normalizeStore(store);
    final trimmed = rawAisle?.trim() ?? '';
    if (trimmed.isEmpty) {
      final list = storeAisles[normalizedStore];
      if (list != null && list.isNotEmpty) {
        return list.first;
      }
      return 'Varios';
    }
    final folded = _foldForComparison(trimmed);
    final candidates = storeAisles[normalizedStore] ?? const <String>[];
    for (final canonical in candidates) {
      if (_foldForComparison(canonical) == folded) {
        return canonical;
      }
    }
    return trimmed;
  }

  /// Seed entries for `local_aisle_order`.
  static List<({String store, String aisle, int sortOrder})> seedAisleOrder() {
    final result = <({String store, String aisle, int sortOrder})>[];
    for (final store in storeOrder) {
      final aisles = storeAisles[store] ?? const <String>[];
      for (var i = 0; i < aisles.length; i++) {
        final aisle = aisles[i];
        final order = aisle == offlinePendingAisle ? 999 : (i + 1) * 10;
        result.add((store: store, aisle: aisle, sortOrder: order));
      }
    }
    return result;
  }

  static String _foldForComparison(String value) {
    const accents = 'áéíóúüñÁÉÍÓÚÜÑ';
    const plain = 'aeiouunAEIOUUN';
    final buffer = StringBuffer();
    for (final rune in value.trim().runes) {
      final ch = String.fromCharCode(rune);
      final idx = accents.indexOf(ch);
      buffer.write(idx >= 0 ? plain[idx] : ch);
    }
    return buffer.toString().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }
}
