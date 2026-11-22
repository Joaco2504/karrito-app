import 'package:flutter/material.dart';

/// Semantic Material icons and accent hues for Karrito store categories and
/// aisles (strictly emoji-free per `.agents/textos-app-es-ar.md`).
@immutable
class CategoryVisual {
  const CategoryVisual({required this.icon, required this.color});

  final IconData icon;
  final Color color;
}

class StoreVisuals {
  StoreVisuals._();

  static CategoryVisual forStore(String storeCategory) {
    final key = storeCategory.toLowerCase();
    if (key.contains('super')) {
      return const CategoryVisual(
        icon: Icons.storefront_rounded,
        color: Color(0xFF8B5CF6),
      );
    }
    if (key.contains('ferret') || key.contains('corral')) {
      return const CategoryVisual(
        icon: Icons.handyman_rounded,
        color: Color(0xFFFF6238),
      );
    }
    if (key.contains('farmac')) {
      return const CategoryVisual(
        icon: Icons.local_pharmacy_rounded,
        color: Color(0xFF10B981),
      );
    }
    if (key.contains('librer') || key.contains('papeler')) {
      return const CategoryVisual(
        icon: Icons.menu_book_rounded,
        color: Color(0xFF3B82F6),
      );
    }
    if (key.contains('diet') || key.contains('natur')) {
      return const CategoryVisual(
        icon: Icons.eco_rounded,
        color: Color(0xFF84CC16),
      );
    }
    return const CategoryVisual(
      icon: Icons.category_rounded,
      color: Color(0xFF94A3B8),
    );
  }

  static CategoryVisual forAisle(String aisleName) {
    final key = aisleName.toLowerCase();
    if (key.contains('verdul') || key.contains('frut')) {
      return const CategoryVisual(
        icon: Icons.eco_rounded,
        color: Color(0xFF84CC16),
      );
    }
    if (key.contains('carnic') || key.contains('pescad')) {
      return const CategoryVisual(
        icon: Icons.set_meal_rounded,
        color: Color(0xFFFF6238),
      );
    }
    if (key.contains('fiambr') || key.contains('queso')) {
      return const CategoryVisual(
        icon: Icons.lunch_dining_rounded,
        color: Color(0xFFF59E0B),
      );
    }
    if (key.contains('lácte') ||
        key.contains('lacte') ||
        key.contains('refrig')) {
      return const CategoryVisual(
        icon: Icons.kitchen_rounded,
        color: Color(0xFF8B5CF6),
      );
    }
    if (key.contains('panad')) {
      return const CategoryVisual(
        icon: Icons.bakery_dining_rounded,
        color: Color(0xFFEA580C),
      );
    }
    if (key.contains('almac') ||
        key.contains('seco') ||
        key.contains('harin')) {
      return const CategoryVisual(
        icon: Icons.inventory_2_rounded,
        color: Color(0xFF65A30D),
      );
    }
    if (key.contains('bebid')) {
      return const CategoryVisual(
        icon: Icons.local_drink_rounded,
        color: Color(0xFF0EA5E9),
      );
    }
    if (key.contains('limpiez')) {
      return const CategoryVisual(
        icon: Icons.cleaning_services_rounded,
        color: Color(0xFF06B6D4),
      );
    }
    if (key.contains('perfum') ||
        key.contains('higiene') ||
        key.contains('cuidado')) {
      return const CategoryVisual(
        icon: Icons.spa_rounded,
        color: Color(0xFFA855F7),
      );
    }
    if (key.contains('congel')) {
      return const CategoryVisual(
        icon: Icons.ac_unit_rounded,
        color: Color(0xFF38BDF8),
      );
    }
    if (key.contains('mascot')) {
      return const CategoryVisual(
        icon: Icons.pets_rounded,
        color: Color(0xFFF97316),
      );
    }
    if (key.contains('fijac') || key.contains('herram')) {
      return const CategoryVisual(
        icon: Icons.construction_rounded,
        color: Color(0xFFFF6238),
      );
    }
    if (key.contains('electr') || key.contains('ilumin')) {
      return const CategoryVisual(
        icon: Icons.bolt_rounded,
        color: Color(0xFFEAB308),
      );
    }
    if (key.contains('plom') || key.contains('gas')) {
      return const CategoryVisual(
        icon: Icons.plumbing_rounded,
        color: Color(0xFF0284C7),
      );
    }
    if (key.contains('pintur')) {
      return const CategoryVisual(
        icon: Icons.format_paint_rounded,
        color: Color(0xFFEC4899),
      );
    }
    if (key.contains('medic') || key.contains('auxil')) {
      return const CategoryVisual(
        icon: Icons.medication_rounded,
        color: Color(0xFF10B981),
      );
    }
    if (key.contains('sin señal') || key.contains('sin clasificar')) {
      return const CategoryVisual(
        icon: Icons.cloud_off_rounded,
        color: Color(0xFFFF6238),
      );
    }
    return const CategoryVisual(
      icon: Icons.shopping_basket_rounded,
      color: Color(0xFF8B5CF6),
    );
  }
}
