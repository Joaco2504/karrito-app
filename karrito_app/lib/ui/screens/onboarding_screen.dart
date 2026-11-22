import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/store_hierarchy.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/shopping_providers.dart';
import '../widgets/karrito_bounce_button.dart';
import '../widgets/karrito_selector_field.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({this.isReviewMode = false, super.key});

  final bool isReviewMode;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  late String _selectedCity;
  int _currentPage = 0;

  static const int _totalSteps = 3;

  @override
  void initState() {
    super.initState();
    _selectedCity =
        ref.read(preferencesProvider).value?.city ?? StoreHierarchy.defaultCity;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _goToPage(int index) async {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (disableAnimations) {
      _pageController.jumpToPage(index);
    } else {
      await _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _handleFinish() async {
    final controller = ref.read(shoppingControllerProvider.notifier);
    if (widget.isReviewMode) {
      await controller.setCity(_selectedCity);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      await controller.completeOnboarding(city: _selectedCity);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final karritoColors = theme.extension<KarritoColors>()!;
    final isDark = theme.brightness == Brightness.dark;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final isLastPage = _currentPage == _totalSteps - 1;

    return Scaffold(
      appBar: widget.isReviewMode
          ? AppBar(title: const Text(AppStrings.settingsGuideTitle))
          : null,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!widget.isReviewMode)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 16, 4),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: karritoColors.accent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: karritoColors.accent.withValues(
                                  alpha: isDark ? 0.45 : 0.25,
                                ),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.shopping_cart_rounded,
                            size: 21,
                            color: karritoColors.onAccent,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          AppStrings.appName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Spacer(),
                        if (!isLastPage)
                          TextButton(
                            onPressed: _handleFinish,
                            child: Text(
                              AppStrings.onboardingSkipButton,
                              style: TextStyle(
                                color: karritoColors.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_totalSteps, (index) {
                      final active = index == _currentPage;
                      return GestureDetector(
                        onTap: () => _goToPage(index),
                        child: AnimatedContainer(
                          duration: disableAnimations
                              ? Duration.zero
                              : const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 36 : 12,
                          height: 6,
                          decoration: BoxDecoration(
                            color: active
                                ? karritoColors.accent
                                : karritoColors.accentContainer,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: active && isDark
                                ? [
                                    BoxShadow(
                                      color: karritoColors.accent.withValues(
                                        alpha: 0.55,
                                      ),
                                      blurRadius: 10,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 2),
                  child: Text(
                    AppStrings.onboardingHeadline,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.45,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  child: Text(
                    AppStrings.onboardingSubtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    children: const [
                      _OnboardingStepSlide(
                        stepNumber: 1,
                        badgeLabel: 'Orden automático',
                        badgeIcon: Icons.auto_fix_high_rounded,
                        title: AppStrings.onboardingCard1Title,
                        body: AppStrings.onboardingCard1Body,
                        illustration: _MixedInputFlowIllustration(),
                      ),
                      _OnboardingStepSlide(
                        stepNumber: 2,
                        badgeLabel: 'Por comercio y pasillo',
                        badgeIcon: Icons.storefront_rounded,
                        title: AppStrings.onboardingCard2Title,
                        body: AppStrings.onboardingCard2Body,
                        illustration: _StoreGroupingFlowIllustration(),
                      ),
                      _OnboardingStepSlide(
                        stepNumber: 3,
                        badgeLabel: 'Modo sin señal',
                        badgeIcon: Icons.wifi_off_rounded,
                        title: AppStrings.onboardingCard3Title,
                        body: AppStrings.onboardingCard3Body,
                        illustration: _OfflineChecklistFlowIllustration(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StepArrowButton(
                        icon: Icons.chevron_left_rounded,
                        tooltip: AppStrings.onboardingBackButton,
                        enabled: _currentPage > 0,
                        onTap: () => _goToPage(_currentPage - 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          'Paso ${_currentPage + 1} de $_totalSteps',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: karritoColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _StepArrowButton(
                        icon: Icons.chevron_right_rounded,
                        tooltip: AppStrings.onboardingNextButton,
                        enabled: !isLastPage,
                        onTap: () => _goToPage(_currentPage + 1),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: KarritoSelectorField<String>(
                    label: AppStrings.cityLabel,
                    sheetTitle: AppStrings.selectCityTitle,
                    leadingIcon: Icons.location_on_outlined,
                    value: StoreHierarchy.cities.contains(_selectedCity)
                        ? _selectedCity
                        : StoreHierarchy.defaultCity,
                    options: StoreHierarchy.cities,
                    onChanged: (value) {
                      setState(() => _selectedCity = value);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 8),
                  child: Row(
                    children: [
                      if (_currentPage > 0) ...[
                        KarritoBounceButton(
                          child: OutlinedButton(
                            onPressed: () => _goToPage(_currentPage - 1),
                            child: const Text(AppStrings.onboardingBackButton),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: KarritoBounceButton(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(
                                  color: karritoColors.accent.withValues(
                                    alpha: isDark ? 0.42 : 0.25,
                                  ),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: FilledButton(
                              onPressed: isLastPage
                                  ? _handleFinish
                                  : () => _goToPage(_currentPage + 1),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(54),
                              ),
                              child: AnimatedSwitcher(
                                duration: disableAnimations
                                    ? Duration.zero
                                    : const Duration(milliseconds: 180),
                                child: Row(
                                  key: ValueKey<bool>(isLastPage),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      isLastPage
                                          ? (widget.isReviewMode
                                                ? AppStrings.saveGuideButton
                                                : AppStrings
                                                      .startShoppingButton)
                                          : AppStrings.onboardingNextButton,
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        size: 15,
                        color: karritoColors.accentSoft,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppStrings.onboardingFooterNote,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: karritoColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepArrowButton extends StatelessWidget {
  const _StepArrowButton({
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final karritoColors = Theme.of(context).extension<KarritoColors>()!;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: karritoColors.fieldSurface,
        shape: CircleBorder(
          side: BorderSide(color: karritoColors.border, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: SizedBox(
            width: 34,
            height: 34,
            child: Icon(
              icon,
              size: 20,
              color: enabled
                  ? karritoColors.accentSoft
                  : karritoColors.textSecondary.withValues(alpha: 0.35),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingStepSlide extends StatelessWidget {
  const _OnboardingStepSlide({
    required this.stepNumber,
    required this.badgeLabel,
    required this.badgeIcon,
    required this.title,
    required this.body,
    required this.illustration,
  });

  final int stepNumber;
  final String badgeLabel;
  final IconData badgeIcon;
  final String title;
  final String body;
  final Widget illustration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final karritoColors = theme.extension<KarritoColors>()!;
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surfaceContainerLow
                  : karritoColors.aisleCardSurface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: karritoColors.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: karritoColors.shadowTint,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: karritoColors.accentContainer,
                        borderRadius: BorderRadius.circular(999),
                        border: isDark
                            ? Border.all(
                                color: karritoColors.accent.withValues(
                                  alpha: 0.4,
                                ),
                              )
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            badgeIcon,
                            size: 14,
                            color: karritoColors.accentSoft,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            badgeLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: karritoColors.onAccentContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$stepNumber / 3',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: karritoColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                illustration,
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.35,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.42,
            ),
          ),
        ],
      ),
    );
  }
}

class _MixedInputFlowIllustration extends StatelessWidget {
  const _MixedInputFlowIllustration();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final karritoColors = theme.extension<KarritoColors>()!;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? karritoColors.fieldSurface : colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: karritoColors.border, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: karritoColors.accentContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 18,
                  color: karritoColors.accentSoft,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pegaste del chat:',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: karritoColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '"${AppStrings.onboardingCard1Example}"',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: karritoColors.lime,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: karritoColors.lime.withValues(alpha: 0.4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_downward_rounded,
            size: 18,
            color: karritoColors.onLime,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _PreviewChipCard(
                icon: Icons.eco_rounded,
                iconBg: karritoColors.lime,
                iconColor: karritoColors.onLime,
                title: 'Papa negra',
                subtitle: '2 kg · Verdulería',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _PreviewChipCard(
                icon: Icons.handyman_rounded,
                iconBg: karritoColors.ctaContainer,
                iconColor: karritoColors.cta,
                title: 'Tornillos',
                subtitle: '10 u · Ferretería',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StoreGroupingFlowIllustration extends StatelessWidget {
  const _StoreGroupingFlowIllustration();

  @override
  Widget build(BuildContext context) {
    final karritoColors = Theme.of(context).extension<KarritoColors>()!;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: karritoColors.accent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.storefront_rounded,
                      size: 16,
                      color: karritoColors.onAccent,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Supermercado',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: karritoColors.onAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: karritoColors.ctaContainer,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: karritoColors.cta.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.handyman_rounded,
                      size: 16,
                      color: karritoColors.cta,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Ferretería',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: karritoColors.onCtaContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _PreviewChipCard(
                icon: Icons.kitchen_rounded,
                iconBg: karritoColors.accentContainer,
                iconColor: karritoColors.accentSoft,
                title: 'Lácteos',
                subtitle: 'Pasillo #1',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _PreviewChipCard(
                icon: Icons.cleaning_services_rounded,
                iconBg: karritoColors.completedContainer,
                iconColor: karritoColors.completed,
                title: 'Limpieza',
                subtitle: 'Pasillo #2',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OfflineChecklistFlowIllustration extends StatelessWidget {
  const _OfflineChecklistFlowIllustration();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final karritoColors = theme.extension<KarritoColors>()!;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: karritoColors.checkedTileSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: karritoColors.checkedTileBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: karritoColors.accent,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 15,
                  color: karritoColors.onAccent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Papa 2 kg',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.lineThrough,
                    color: karritoColors.textSecondary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: karritoColors.ctaContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Sin señal',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: karritoColors.onCtaContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? karritoColors.fieldSurface : colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: karritoColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: karritoColors.accentSoft, width: 2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Leche descremada 1 l',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.stay_current_portrait_rounded,
                size: 18,
                color: karritoColors.accentSoft,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreviewChipCard extends StatelessWidget {
  const _PreviewChipCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final karritoColors = theme.extension<KarritoColors>()!;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? karritoColors.fieldSurface : colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: karritoColors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: karritoColors.textSecondary,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
