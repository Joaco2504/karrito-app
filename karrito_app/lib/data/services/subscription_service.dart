import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../core/config/monetization_config.dart';

/// Canonical Karrito subscription tier strings stored in `karrito.users_profile.plan_tier`.
class KarritoPlanTier {
  KarritoPlanTier._();

  static const String free = 'free';
  static const String basic = 'basic_2usd';
  static const String pro = 'pro_3usd';

  static bool isPaid(String tier) => tier == basic || tier == pro;
  static bool isPro(String tier) => tier == pro;

  static String displayName(String tier) {
    switch (tier) {
      case pro:
        return 'Plan Pro';
      case basic:
        return 'Plan Básico';
      default:
        return 'Plan Gratis';
    }
  }
}

class SubscriptionPlanOffer {
  const SubscriptionPlanOffer({
    required this.planTier,
    required this.packageId,
    required this.productId,
    required this.priceLabel,
    this.storePackage,
    this.fallbackProduct,
  });

  final String planTier;
  final String packageId;
  final String productId;
  final String priceLabel;
  final Package? storePackage;
  final StoreProduct? fallbackProduct;
}

class SubscriptionActionOutcome {
  const SubscriptionActionOutcome({
    required this.planTier,
    required this.succeeded,
    this.cancelled = false,
    this.message,
  });

  final String planTier;
  final bool succeeded;
  final bool cancelled;
  final String? message;
}

abstract interface class SubscriptionService {
  bool get isConfigured;
  Future<void> configure({String? appUserId});
  Future<void> identifyUser(String? appUserId);
  Future<String?> fetchActivePlanTier();
  Future<List<SubscriptionPlanOffer>> fetchMonthlyOffers();
  Future<SubscriptionActionOutcome> purchaseMonthlyPlan(String targetTier);
  Future<SubscriptionActionOutcome> restorePurchases();
}

/// Manages Google Play monthly subscriptions (`basic_access` and `pro_access`)
/// via RevenueCat (`purchases_flutter`), safely degrading to development mode
/// while [MonetizationConfig.revenueCatGoogleApiKey] still holds its placeholder.
class RevenueCatSubscriptionService implements SubscriptionService {
  bool _sdkConfigured = false;
  String? _identifiedUserId;

  @override
  bool get isConfigured =>
      _sdkConfigured && MonetizationConfig.isRevenueCatConfigured;

  /// Pure entitlement resolver matching `supabase/functions/revenuecat-webhook`.
  static String resolveTierFromEntitlements(Iterable<String> activeKeys) {
    final set = activeKeys.map((e) => e.trim()).toSet();
    if (set.contains(MonetizationConfig.entitlementPro)) {
      return KarritoPlanTier.pro;
    }
    if (set.contains(MonetizationConfig.entitlementBasic)) {
      return KarritoPlanTier.basic;
    }
    return KarritoPlanTier.free;
  }

  static List<SubscriptionPlanOffer> defaultFallbackOffers() {
    return const <SubscriptionPlanOffer>[
      SubscriptionPlanOffer(
        planTier: KarritoPlanTier.basic,
        packageId: MonetizationConfig.packageBasicMonthly,
        productId: MonetizationConfig.productBasicId,
        priceLabel: 'USD 2 / mes',
      ),
      SubscriptionPlanOffer(
        planTier: KarritoPlanTier.pro,
        packageId: MonetizationConfig.packageProMonthly,
        productId: MonetizationConfig.productProId,
        priceLabel: 'USD 3 / mes',
      ),
    ];
  }

  @override
  Future<void> configure({String? appUserId}) async {
    if (!MonetizationConfig.isRevenueCatConfigured) {
      debugPrint(
        'Karrito RevenueCat: modo desarrollo (reemplazá REVENUECAT_GOOGLE_API_KEY en monetization_config.dart antes de subir a Google Play).',
      );
      return;
    }
    if (_sdkConfigured) {
      await identifyUser(appUserId);
      return;
    }
    try {
      final config = PurchasesConfiguration(
        MonetizationConfig.revenueCatGoogleApiKey.trim(),
      );
      if (appUserId != null && appUserId.trim().isNotEmpty) {
        config.appUserID = appUserId.trim();
        _identifiedUserId = appUserId.trim();
      }
      await Purchases.configure(config);
      _sdkConfigured = true;
    } catch (e) {
      debugPrint('Karrito RevenueCat configure skipped: $e');
    }
  }

  @override
  Future<void> identifyUser(String? appUserId) async {
    if (!isConfigured) return;
    final trimmed = appUserId?.trim();
    if (trimmed == null || trimmed.isEmpty || trimmed == _identifiedUserId) {
      return;
    }
    try {
      await Purchases.logIn(trimmed);
      _identifiedUserId = trimmed;
    } catch (e) {
      debugPrint('Karrito RevenueCat logIn skipped: $e');
    }
  }

  @override
  Future<String?> fetchActivePlanTier() async {
    if (!isConfigured) return null;
    try {
      final info = await Purchases.getCustomerInfo();
      return resolveTierFromEntitlements(info.entitlements.active.keys);
    } catch (e) {
      debugPrint('Karrito RevenueCat getCustomerInfo skipped: $e');
      return null;
    }
  }

  static String _cleanPriceLabel(StoreProduct? product, String fallback) {
    final price = product?.priceString.trim();
    if (price != null && price.isNotEmpty) {
      return price;
    }
    return fallback;
  }

  static bool _matchesPlanProduct(
    StoreProduct product, {
    required String productId,
    required String basePlanId,
  }) {
    final idLower = product.identifier.trim().toLowerCase();
    final targetProd = productId.trim().toLowerCase();
    final targetBase = basePlanId.trim().toLowerCase();

    if (idLower == targetProd ||
        idLower.startsWith('$targetProd:') ||
        idLower.contains(targetProd)) {
      return true;
    }

    final defaultOpt = product.defaultOption;
    if (defaultOpt != null) {
      final optId = defaultOpt.id.trim().toLowerCase();
      final optProd = defaultOpt.productId.trim().toLowerCase();
      final optStoreProd = defaultOpt.storeProductId.trim().toLowerCase();
      if (optId == targetBase ||
          optId.startsWith('$targetBase:') ||
          optProd == targetProd ||
          optStoreProd == targetProd ||
          optStoreProd.startsWith('$targetProd:')) {
        return true;
      }
    }

    final options = product.subscriptionOptions;
    if (options != null) {
      for (final opt in options) {
        final optId = opt.id.trim().toLowerCase();
        final optProd = opt.productId.trim().toLowerCase();
        final optStoreProd = opt.storeProductId.trim().toLowerCase();
        if (optId == targetBase ||
            optId.startsWith('$targetBase:') ||
            optProd == targetProd ||
            optStoreProd == targetProd ||
            optStoreProd.startsWith('$targetProd:')) {
          return true;
        }
      }
    }
    return false;
  }

  static bool _matchesPlanPackage(
    Package pkg, {
    required List<String> packageIds,
    required String productId,
    required String basePlanId,
  }) {
    final pkgIdLower = pkg.identifier.trim().toLowerCase();
    for (final candidate in packageIds) {
      if (pkgIdLower == candidate.toLowerCase()) {
        return true;
      }
    }
    return _matchesPlanProduct(
      pkg.storeProduct,
      productId: productId,
      basePlanId: basePlanId,
    );
  }

  /// Resolves both monthly plans from RevenueCat [Offerings].
  ///
  /// Searches `offerings.current` first, then `offerings.getOffering('default')`,
  /// and finally all other offerings in `offerings.all.values` so that both
  /// `karrito_basic_2usd` (`basic-monthly`) and `karrito_pro_3usd` (`pro-monthly`)
  /// always read their localized Google Play `storeProduct.priceString` (e.g. ARS)
  /// even if RevenueCat dashboard has them split across separate offerings.
  static List<SubscriptionPlanOffer> resolveMonthlyOffersFromOfferings(
    Offerings offerings,
  ) {
    final orderedPackages = <Package>[];
    final seenOfferingIds = <String>{};

    void addOfferingPackages(Offering? offering) {
      if (offering == null) return;
      if (!seenOfferingIds.add(offering.identifier)) return;
      orderedPackages.addAll(offering.availablePackages);
    }

    addOfferingPackages(offerings.current);
    addOfferingPackages(
      offerings.getOffering(MonetizationConfig.revenueCatOfferingId),
    );
    for (final offering in offerings.all.values) {
      addOfferingPackages(offering);
    }

    Package? findMatching({
      required List<String> packageIds,
      required String productId,
      required String basePlanId,
    }) {
      for (final pkg in orderedPackages) {
        if (_matchesPlanPackage(
          pkg,
          packageIds: packageIds,
          productId: productId,
          basePlanId: basePlanId,
        )) {
          return pkg;
        }
      }
      return null;
    }

    final basicPkg = findMatching(
      packageIds: const <String>[
        MonetizationConfig.packageBasicMonthly,
        MonetizationConfig.basePlanBasicMonthly,
        MonetizationConfig.productBasicId,
      ],
      productId: MonetizationConfig.productBasicId,
      basePlanId: MonetizationConfig.basePlanBasicMonthly,
    );
    final proPkg = findMatching(
      packageIds: const <String>[
        MonetizationConfig.packageProMonthly,
        MonetizationConfig.basePlanProMonthly,
        MonetizationConfig.productProId,
      ],
      productId: MonetizationConfig.productProId,
      basePlanId: MonetizationConfig.basePlanProMonthly,
    );

    return <SubscriptionPlanOffer>[
      SubscriptionPlanOffer(
        planTier: KarritoPlanTier.basic,
        packageId:
            basicPkg?.identifier ?? MonetizationConfig.packageBasicMonthly,
        productId: MonetizationConfig.productBasicId,
        priceLabel: _cleanPriceLabel(basicPkg?.storeProduct, 'USD 2 / mes'),
        storePackage: basicPkg,
      ),
      SubscriptionPlanOffer(
        planTier: KarritoPlanTier.pro,
        packageId: proPkg?.identifier ?? MonetizationConfig.packageProMonthly,
        productId: MonetizationConfig.productProId,
        priceLabel: _cleanPriceLabel(proPkg?.storeProduct, 'USD 3 / mes'),
        storePackage: proPkg,
      ),
    ];
  }

  @override
  Future<List<SubscriptionPlanOffer>> fetchMonthlyOffers() async {
    final fallback = defaultFallbackOffers();
    if (!isConfigured && MonetizationConfig.isRevenueCatConfigured) {
      await configure();
    }
    if (!isConfigured) return fallback;

    try {
      final offerings = await Purchases.getOfferings();
      var resolved = resolveMonthlyOffersFromOfferings(offerings);

      final missingProductIds = <String>[
        for (final offer in resolved)
          if (offer.storePackage == null) offer.productId,
      ];

      if (missingProductIds.isNotEmpty) {
        debugPrint(
          'Karrito RevenueCat: missing packages in offerings ($missingProductIds); '
          'current=${offerings.current?.identifier}, all=${offerings.all.keys.toList()}. '
          'Querying Google Play products directly.',
        );
        try {
          final storeProducts = await Purchases.getProducts(
            missingProductIds,
            productCategory: ProductCategory.subscription,
          );
          resolved = resolved.map((offer) {
            if (offer.storePackage != null) return offer;
            final basePlanId = offer.planTier == KarritoPlanTier.pro
                ? MonetizationConfig.basePlanProMonthly
                : MonetizationConfig.basePlanBasicMonthly;
            StoreProduct? matched;
            for (final prod in storeProducts) {
              if (_matchesPlanProduct(
                prod,
                productId: offer.productId,
                basePlanId: basePlanId,
              )) {
                matched = prod;
                break;
              }
            }
            if (matched == null) return offer;
            return SubscriptionPlanOffer(
              planTier: offer.planTier,
              packageId: offer.packageId,
              productId: offer.productId,
              priceLabel: _cleanPriceLabel(matched, offer.priceLabel),
              fallbackProduct: matched,
            );
          }).toList();
        } catch (e) {
          debugPrint('Karrito RevenueCat getProducts fallback skipped: $e');
        }
      }

      return resolved;
    } catch (e) {
      debugPrint('Karrito RevenueCat getOfferings fallback: $e');
      return fallback;
    }
  }

  @override
  Future<SubscriptionActionOutcome> purchaseMonthlyPlan(
    String targetTier,
  ) async {
    if (!MonetizationConfig.isRevenueCatConfigured) {
      return const SubscriptionActionOutcome(
        planTier: KarritoPlanTier.free,
        succeeded: false,
        message:
            'Las compras con Google Play se habilitan al cargar la clave real de RevenueCat antes de publicar en la tienda.',
      );
    }

    try {
      final offers = await fetchMonthlyOffers();
      final selected = offers.firstWhere(
        (o) => o.planTier == targetTier,
        orElse: () => offers.last,
      );
      final pkg = selected.storePackage;
      final fallbackProduct = selected.fallbackProduct;
      if (pkg == null && fallbackProduct == null) {
        return const SubscriptionActionOutcome(
          planTier: KarritoPlanTier.free,
          succeeded: false,
          message:
              'No encontramos este plan disponible en Google Play ahora. Probá de nuevo en unos minutos.',
        );
      }

      final params = pkg != null
          ? PurchaseParams.package(pkg)
          : PurchaseParams.storeProduct(fallbackProduct!);
      final result = await Purchases.purchase(params);
      final resolvedTier = resolveTierFromEntitlements(
        result.customerInfo.entitlements.active.keys,
      );
      return SubscriptionActionOutcome(
        planTier: resolvedTier,
        succeeded: resolvedTier != KarritoPlanTier.free,
        message: resolvedTier == KarritoPlanTier.pro
            ? 'Plan Pro activado. Ya tenés todas las herramientas desbloqueadas.'
            : (resolvedTier == KarritoPlanTier.basic
                  ? 'Plan Básico activado. Ya podés comprar sin anuncios y hasta 10 listas.'
                  : 'La compra quedó pendiente de confirmación en Google Play.'),
      );
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        return const SubscriptionActionOutcome(
          planTier: KarritoPlanTier.free,
          succeeded: false,
          cancelled: true,
        );
      }
      return const SubscriptionActionOutcome(
        planTier: KarritoPlanTier.free,
        succeeded: false,
        message:
            'No pudimos completar la suscripción con Google Play. Revisá tu medio de pago e intentá de nuevo.',
      );
    } catch (e) {
      debugPrint('Karrito RevenueCat purchase error: $e');
      return const SubscriptionActionOutcome(
        planTier: KarritoPlanTier.free,
        succeeded: false,
        message:
            'No pudimos conectar con Google Play en este momento. Probá de nuevo en unos segundos.',
      );
    }
  }

  @override
  Future<SubscriptionActionOutcome> restorePurchases() async {
    if (!MonetizationConfig.isRevenueCatConfigured) {
      return const SubscriptionActionOutcome(
        planTier: KarritoPlanTier.free,
        succeeded: false,
        message:
            'La restauración de compras se activa cuando la app está conectada a Google Play y RevenueCat.',
      );
    }

    try {
      final info = await Purchases.restorePurchases();
      final tier = resolveTierFromEntitlements(info.entitlements.active.keys);
      return SubscriptionActionOutcome(
        planTier: tier,
        succeeded: true,
        message: tier == KarritoPlanTier.free
            ? 'No encontramos una suscripción activa en esta cuenta de Google Play.'
            : 'Restauramos tu suscripción correctamente.',
      );
    } catch (e) {
      debugPrint('Karrito RevenueCat restore error: $e');
      return const SubscriptionActionOutcome(
        planTier: KarritoPlanTier.free,
        succeeded: false,
        message:
            'No pudimos revisar tus compras en Google Play ahora. Probá de nuevo cuando tengas mejor señal.',
      );
    }
  }
}
