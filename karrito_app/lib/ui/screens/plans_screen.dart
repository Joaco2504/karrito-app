import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/subscription_service.dart';
import '../../providers/core_providers.dart';
import '../../providers/shopping_providers.dart';
import '../widgets/karrito_bounce_button.dart';

/// Monthly subscription plans screen following
/// `.agents/figma_ref/5._planes_y_suscripciones_modo_oscuro` and Karrito's
/// strict monthly-only business rules (no annual option).
class PlansScreen extends ConsumerStatefulWidget {
  const PlansScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(
      context,
    ).push<void>(MaterialPageRoute<void>(builder: (_) => const PlansScreen()));
  }

  @override
  ConsumerState<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends ConsumerState<PlansScreen> {
  List<SubscriptionPlanOffer> _offers =
      RevenueCatSubscriptionService.defaultFallbackOffers();

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    final loaded = await ref
        .read(subscriptionServiceProvider)
        .fetchMonthlyOffers();
    if (mounted) {
      setState(() => _offers = loaded);
    }
  }

  SubscriptionPlanOffer _offerFor(String tier) {
    for (final offer in _offers) {
      if (offer.planTier == tier) return offer;
    }
    return RevenueCatSubscriptionService.defaultFallbackOffers().firstWhere(
      (o) => o.planTier == tier,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTier = ref.watch(effectivePlanTierProvider);
    final prefs = ref.watch(preferencesProvider).value;
    final uiState = ref.watch(shoppingControllerProvider);
    final controller = ref.read(shoppingControllerProvider.notifier);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final karritoColors = theme.extension<KarritoColors>()!;
    final isDark = theme.brightness == Brightness.dark;

    final basicOffer = _offerFor(KarritoPlanTier.basic);
    final proOffer = _offerFor(KarritoPlanTier.pro);
    final freeMax = prefs?.freeMaxLists ?? 3;
    final basicMax = prefs?.basicMaxLists ?? 10;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.plansTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                Text(
                  AppStrings.plansSubtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: karritoColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),

                // 1. PLAN PRO (DESTACADO / MÁS ELEGIDO)
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark
                          ? const [
                              Color(0xFF211838),
                              Color(0xFF1A162B),
                              Color(0xFF161422),
                            ]
                          : const [Color(0xFFF7F1FF), Color(0xFFFFFFFF)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: karritoColors.accent, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: karritoColors.accent.withValues(
                          alpha: isDark ? 0.28 : 0.16,
                        ),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -36,
                        right: -36,
                        child: Container(
                          width: 132,
                          height: 132,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: karritoColors.accent.withValues(
                              alpha: isDark ? 0.22 : 0.10,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -36,
                        left: -36,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: karritoColors.cta.withValues(
                              alpha: isDark ? 0.16 : 0.08,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: karritoColors.accentContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.star_rounded,
                                    size: 20,
                                    color: karritoColors.accentSoft,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  AppStrings.planProName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: karritoColors.accentSoft,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: currentTier == KarritoPlanTier.pro
                                        ? karritoColors.lime
                                        : karritoColors.cta,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    currentTier == KarritoPlanTier.pro
                                        ? AppStrings.planCurrentBadge
                                        : AppStrings.planMostChosenBadge,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: currentTier == KarritoPlanTier.pro
                                          ? karritoColors.onLime
                                          : karritoColors.onCta,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  proOffer.priceLabel,
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.5,
                                      ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Mensual',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: karritoColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Todas las herramientas para armar listas por voz o foto, compartir en vivo y controlar el gasto en caja.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: karritoColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const _PlanBenefitRow(
                              icon: Icons.check_circle_rounded,
                              text: 'Sin publicidad y listas ilimitadas',
                              highlight: true,
                            ),
                            const _PlanBenefitRow(
                              icon: Icons.mic_rounded,
                              text:
                                  'Dictado por voz con IA (armás tu lista hablando)',
                            ),
                            const _PlanBenefitRow(
                              icon: Icons.document_scanner_rounded,
                              text:
                                  'Escaneo de listas en papel o capturas de WhatsApp',
                            ),
                            const _PlanBenefitRow(
                              icon: Icons.sensors_rounded,
                              text:
                                  'Listas compartidas en vivo con código y QR',
                            ),
                            const _PlanBenefitRow(
                              icon: Icons.shopping_cart_checkout_rounded,
                              text:
                                  'Calculadora de changuito e historial de gastos del mes',
                            ),
                            const _PlanBenefitRow(
                              icon: Icons.receipt_long_rounded,
                              text:
                                  'Importador de recetas y proyectos por comercio',
                            ),
                            const SizedBox(height: 16),
                            if (currentTier == KarritoPlanTier.pro)
                              _CurrentPlanBanner(
                                label: AppStrings.planCurrentBadge,
                              )
                            else
                              KarritoBounceButton(
                                enabled: !uiState.isProcessingSubscription,
                                child: FilledButton.icon(
                                  onPressed: uiState.isProcessingSubscription
                                      ? null
                                      : () => controller.purchaseMonthlyPlan(
                                          KarritoPlanTier.pro,
                                        ),
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size.fromHeight(52),
                                  ),
                                  icon: uiState.isProcessingSubscription
                                      ? SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: colorScheme.onPrimary,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 20,
                                        ),
                                  iconAlignment: IconAlignment.end,
                                  label: const Text(AppStrings.chooseProButton),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 2. PLAN BÁSICO
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: currentTier == KarritoPlanTier.basic
                          ? karritoColors.accentSoft
                          : karritoColors.border,
                      width: currentTier == KarritoPlanTier.basic ? 1.8 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: karritoColors.fieldSurface,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.shopping_bag_outlined,
                              size: 19,
                              color: karritoColors.accentSoft,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            AppStrings.planBasicName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          if (currentTier == KarritoPlanTier.basic)
                            _SmallStatusChip(
                              label: AppStrings.planCurrentBadge,
                              bg: karritoColors.lime,
                              fg: karritoColors.onLime,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            basicOffer.priceLabel,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Mensual',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: karritoColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Para comprar sin anuncios y guardar más listas activas.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: karritoColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const _PlanBenefitRow(
                        icon: Icons.check_rounded,
                        text: 'Sin publicidad en toda la app',
                      ),
                      _PlanBenefitRow(
                        icon: Icons.check_rounded,
                        text: 'Hasta $basicMax listas activas simultáneas',
                      ),
                      const _PlanBenefitRow(
                        icon: Icons.check_rounded,
                        text: 'Todo lo incluido en el Plan Gratis',
                      ),
                      const SizedBox(height: 14),
                      if (currentTier == KarritoPlanTier.basic)
                        _CurrentPlanBanner(label: AppStrings.planCurrentBadge)
                      else
                        KarritoBounceButton(
                          enabled: !uiState.isProcessingSubscription,
                          child: OutlinedButton(
                            onPressed: uiState.isProcessingSubscription
                                ? null
                                : () => controller.purchaseMonthlyPlan(
                                    KarritoPlanTier.basic,
                                  ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                            child: const Text(AppStrings.chooseBasicButton),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 3. PLAN GRATIS
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: karritoColors.aisleCardSurface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: karritoColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: karritoColors.fieldSurface,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.eco_outlined,
                              size: 19,
                              color: karritoColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            AppStrings.planFreeName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          if (currentTier == KarritoPlanTier.free)
                            _SmallStatusChip(
                              label: AppStrings.planCurrentBadge,
                              bg: karritoColors.fieldSurface,
                              fg: karritoColors.textSecondary,
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '\$ 0 / mes',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _PlanBenefitRow(
                        icon: Icons.check_rounded,
                        text:
                            'Hasta $freeMax listas activas y carga por texto con IA',
                      ),
                      const _PlanBenefitRow(
                        icon: Icons.check_rounded,
                        text:
                            'Modo sin señal en el comercio y orden de pasillos',
                      ),
                      const _PlanBenefitRow(
                        icon: Icons.check_rounded,
                        text:
                            'Compartir por WhatsApp y unirte gratis a listas en vivo',
                      ),
                      const _PlanBenefitRow(
                        icon: Icons.close_rounded,
                        text: 'Muestra anuncios locales y de AdMob',
                        muted: true,
                      ),
                      if (currentTier == KarritoPlanTier.free) ...[
                        const SizedBox(height: 12),
                        const _CurrentPlanBanner(
                          label: AppStrings.planActiveOnDevice,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Restore purchases button + Google Play trust footer
                Center(
                  child: TextButton.icon(
                    onPressed: uiState.isProcessingSubscription
                        ? null
                        : controller.restorePurchases,
                    icon: const Icon(Icons.restore_rounded, size: 18),
                    label: const Text(AppStrings.restorePurchasesButton),
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 22,
                      color: karritoColors.accentSoft,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.plansTrustNote,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: karritoColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanBenefitRow extends StatelessWidget {
  const _PlanBenefitRow({
    required this.icon,
    required this.text,
    this.highlight = false,
    this.muted = false,
  });

  final IconData icon;
  final String text;
  final bool highlight;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final karritoColors = theme.extension<KarritoColors>()!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 19,
            color: muted
                ? karritoColors.textSecondary.withValues(alpha: 0.6)
                : karritoColors.accentSoft,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                color: muted
                    ? karritoColors.textSecondary.withValues(alpha: 0.72)
                    : theme.colorScheme.onSurface,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallStatusChip extends StatelessWidget {
  const _SmallStatusChip({
    required this.label,
    required this.bg,
    required this.fg,
  });

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }
}

class _CurrentPlanBanner extends StatelessWidget {
  const _CurrentPlanBanner({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final karritoColors = Theme.of(context).extension<KarritoColors>()!;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: karritoColors.fieldSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: karritoColors.border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: karritoColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
