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
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
                  child: Row(
                    children: [
                      if (!widget.isReviewMode)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: karritoColors.accent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.shopping_cart_rounded,
                                size: 16,
                                color: karritoColors.lime,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                AppStrings.appName,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: karritoColors.onAccent,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Spacer(),
                      if (!isLastPage)
                        TextButton(
                          onPressed: _handleFinish,
                          child: const Text(AppStrings.onboardingSkipButton),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                  child: Text(
                    AppStrings.onboardingHeadline,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text(
                    AppStrings.onboardingSubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
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
                        title: AppStrings.onboardingCard1Title,
                        body: AppStrings.onboardingCard1Body,
                        example: AppStrings.onboardingCard1Example,
                        illustration: _MixedInputIllustration(),
                      ),
                      _OnboardingStepSlide(
                        stepNumber: 2,
                        title: AppStrings.onboardingCard2Title,
                        body: AppStrings.onboardingCard2Body,
                        example: AppStrings.onboardingCard2Example,
                        illustration: _StoreGroupingIllustration(),
                      ),
                      _OnboardingStepSlide(
                        stepNumber: 3,
                        title: AppStrings.onboardingCard3Title,
                        body: AppStrings.onboardingCard3Body,
                        example: AppStrings.onboardingCard3Example,
                        illustration: _OfflineChecklistIllustration(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
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
                        width: active ? 28 : 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: active
                              ? karritoColors.accent
                              : karritoColors.border,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    );
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
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
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  child: Row(
                    children: [
                      if (_currentPage > 0) ...[
                        KarritoBounceButton(
                          child: OutlinedButton(
                            onPressed: () => _goToPage(_currentPage - 1),
                            child: const Text(AppStrings.onboardingBackButton),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: KarritoBounceButton(
                          child: FilledButton(
                            onPressed: isLastPage
                                ? _handleFinish
                                : () => _goToPage(_currentPage + 1),
                            child: AnimatedSwitcher(
                              duration: disableAnimations
                                  ? Duration.zero
                                  : const Duration(milliseconds: 180),
                              child: Text(
                                isLastPage
                                    ? (widget.isReviewMode
                                          ? AppStrings.saveGuideButton
                                          : AppStrings.startShoppingButton)
                                    : AppStrings.onboardingNextButton,
                                key: ValueKey<bool>(isLastPage),
                              ),
                            ),
                          ),
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

class _OnboardingStepSlide extends StatelessWidget {
  const _OnboardingStepSlide({
    required this.stepNumber,
    required this.title,
    required this.body,
    required this.example,
    required this.illustration,
  });

  final int stepNumber;
  final String title;
  final String body;
  final String example;
  final Widget illustration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final karritoColors = theme.extension<KarritoColors>()!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: karritoColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: karritoColors.shadowTint,
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            illustration,
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: karritoColors.lime,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Paso $stepNumber de 3',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: karritoColors.onLime,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.25,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.42,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: karritoColors.fieldSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: karritoColors.border, width: 1),
              ),
              child: Text(
                example,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MixedInputIllustration extends StatelessWidget {
  const _MixedInputIllustration();

  @override
  Widget build(BuildContext context) {
    final karritoColors = Theme.of(context).extension<KarritoColors>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: karritoColors.fieldSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: karritoColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: karritoColors.accent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.edit_note_rounded,
              size: 30,
              color: karritoColors.lime,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _MiniTag(
                  'Papa 2 kg',
                  colorScheme.surface,
                  karritoColors.border,
                ),
                _MiniTag('Leche', colorScheme.surface, karritoColors.border),
                _MiniTag(
                  'Tornillos',
                  colorScheme.surface,
                  karritoColors.border,
                ),
                _MiniTag(
                  'Ibuprofeno',
                  colorScheme.surface,
                  karritoColors.border,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreGroupingIllustration extends StatelessWidget {
  const _StoreGroupingIllustration();

  @override
  Widget build(BuildContext context) {
    final karritoColors = Theme.of(context).extension<KarritoColors>()!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: karritoColors.fieldSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: karritoColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: karritoColors.accent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.storefront_rounded,
                    size: 20,
                    color: karritoColors.lime,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Supermercado',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: karritoColors.onAccent,
                    ),
                  ),
                  Text(
                    'Verdulería · Lácteos',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: karritoColors.onAccent.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: karritoColors.ctaContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: karritoColors.cta.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.handyman_outlined,
                    size: 20,
                    color: karritoColors.onCtaContainer,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ferretería',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: karritoColors.onCtaContainer,
                    ),
                  ),
                  Text(
                    'Fijaciones',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: karritoColors.onCtaContainer.withValues(
                        alpha: 0.85,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfflineChecklistIllustration extends StatelessWidget {
  const _OfflineChecklistIllustration();

  @override
  Widget build(BuildContext context) {
    final karritoColors = Theme.of(context).extension<KarritoColors>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: karritoColors.fieldSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: karritoColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: karritoColors.lime,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 15,
                  color: karritoColors.onLime,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Papa 2 kg',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
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
                    fontWeight: FontWeight.w700,
                    color: karritoColors.onCtaContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
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
                    fontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag(this.label, this.bgColor, this.borderColor);

  final String label;
  final Color bgColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
