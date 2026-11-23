import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/karrito_bounce_button.dart';
import 'onboarding_screen.dart';

/// Combined interactive basic guide (3-step illustrated carousel) and expandable
/// 9-question FAQ accordion opened from the profile menu.
class GuideFaqScreen extends StatefulWidget {
  const GuideFaqScreen({super.key});

  @override
  State<GuideFaqScreen> createState() => _GuideFaqScreenState();
}

class _GuideFaqScreenState extends State<GuideFaqScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  int? _openFaqIndex = 0;

  static const List<
    ({IconData icon, String badge, String title, String body, String tip})
  >
  _steps = [
    (
      icon: Icons.auto_fix_high_rounded,
      badge: 'Paso 1 · Carga rápida',
      title: AppStrings.onboardingCard1Title,
      body: AppStrings.onboardingCard1Body,
      tip: AppStrings.onboardingCard1Example,
    ),
    (
      icon: Icons.storefront_rounded,
      badge: 'Paso 2 · Por rubro y pasillo',
      title: AppStrings.onboardingCard2Title,
      body: AppStrings.onboardingCard2Body,
      tip: AppStrings.onboardingCard2Example,
    ),
    (
      icon: Icons.restaurant_menu_rounded,
      badge: 'Paso 3 · Recetas a paquetes',
      title: AppStrings.onboardingCard3Title,
      body: AppStrings.onboardingCard3Body,
      tip: AppStrings.onboardingCard3Example,
    ),
  ];

  static const List<IconData> _faqIcons = <IconData>[
    Icons.shopping_cart_outlined,
    Icons.restaurant_menu_rounded,
    Icons.qr_code_2_rounded,
    Icons.wifi_off_rounded,
    Icons.reorder_rounded,
    Icons.location_on_outlined,
    Icons.edit_outlined,
    Icons.cleaning_services_outlined,
    Icons.workspace_premium_outlined,
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _goToStep(int index) async {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (disableAnimations) {
      _pageController.jumpToPage(index);
    } else {
      await _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final karritoColors = theme.extension<KarritoColors>()!;
    final isDark = theme.brightness == Brightness.dark;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final textScale = (MediaQuery.textScalerOf(context).scale(14) / 14).clamp(
      1.0,
      1.35,
    );

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.guideFaqTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              key: const ValueKey<String>('guide_faq_list_view'),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_stories_outlined,
                        size: 19,
                        color: karritoColors.accentSoft,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.guideTutorialSectionTitle.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                          color: karritoColors.accentSoft,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final imageWidth = (constraints.maxWidth - 40).clamp(
                      220.0,
                      560.0,
                    );
                    final imageHeight = imageWidth * (460 / 800);
                    final cardHeight = imageHeight + (215 * textScale);

                    return SizedBox(
                      height: cardHeight,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _steps.length,
                        onPageChanged: (index) {
                          setState(() => _currentStep = index);
                        },
                        itemBuilder: (context, index) {
                          final step = _steps[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? colorScheme.surfaceContainerLow
                                    : karritoColors.aisleCardSurface,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: karritoColors.border,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: karritoColors.shadowTint,
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: karritoColors.accentContainer,
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              step.icon,
                                              size: 14,
                                              color: karritoColors.accentSoft,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              step.badge,
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w800,
                                                    color: karritoColors
                                                        .onAccentContainer,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '${index + 1}/${_steps.length}',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color:
                                                  karritoColors.textSecondary,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  OnboardingVisualFrame(
                                    stepNumber: index + 1,
                                    semanticLabel: step.title,
                                    fallbackIllustration: Container(
                                      height: 92,
                                      decoration: BoxDecoration(
                                        color: karritoColors.fieldSurface,
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: karritoColors.border,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(
                                        step.icon,
                                        size: 36,
                                        color: karritoColors.accentSoft,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    step.title,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 4),
                                  Expanded(
                                    child: Text(
                                      step.body,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: karritoColors.textSecondary,
                                            height: 1.38,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: karritoColors.fieldSurface,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: karritoColors.border,
                                      ),
                                    ),
                                    child: Text(
                                      step.tip,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: colorScheme.onSurface,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    KarritoBounceButton(
                      enabled: _currentStep > 0,
                      child: IconButton(
                        tooltip: AppStrings.onboardingBackButton,
                        onPressed: _currentStep > 0
                            ? () => _goToStep(_currentStep - 1)
                            : null,
                        icon: const Icon(Icons.chevron_left_rounded),
                      ),
                    ),
                    for (var i = 0; i < _steps.length; i++)
                      GestureDetector(
                        onTap: () => _goToStep(i),
                        child: AnimatedContainer(
                          duration: disableAnimations
                              ? Duration.zero
                              : const Duration(milliseconds: 220),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentStep == i ? 28 : 10,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _currentStep == i
                                ? karritoColors.accent
                                : karritoColors.accentContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    KarritoBounceButton(
                      enabled: _currentStep < _steps.length - 1,
                      child: IconButton(
                        tooltip: AppStrings.onboardingNextButton,
                        onPressed: _currentStep < _steps.length - 1
                            ? () => _goToStep(_currentStep + 1)
                            : null,
                        icon: const Icon(Icons.chevron_right_rounded),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.quiz_outlined,
                        size: 19,
                        color: karritoColors.accentSoft,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.faqSectionTitle.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                          color: karritoColors.accentSoft,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: karritoColors.accentContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${AppStrings.faqEntries.length} temas',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: karritoColors.onAccentContainer,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                for (var i = 0; i < AppStrings.faqEntries.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  _GuideFaqCard(
                    icon: _faqIcons[i % _faqIcons.length],
                    question: AppStrings.faqEntries[i].question,
                    answer: AppStrings.faqEntries[i].answer,
                    isOpen: _openFaqIndex == i,
                    onTap: () {
                      setState(() {
                        _openFaqIndex = _openFaqIndex == i ? null : i;
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GuideFaqCard extends StatelessWidget {
  const _GuideFaqCard({
    required this.icon,
    required this.question,
    required this.answer,
    required this.isOpen,
    required this.onTap,
  });

  final IconData icon;
  final String question;
  final String answer;
  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final karritoColors = theme.extension<KarritoColors>()!;
    final isDark = theme.brightness == Brightness.dark;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final duration = disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 230);

    return AnimatedContainer(
      duration: duration,
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isDark ? karritoColors.aisleCardSurface : colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isOpen ? karritoColors.accentSoft : karritoColors.border,
          width: isOpen ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: karritoColors.shadowTint.withValues(
              alpha: isOpen ? (isDark ? 0.42 : 0.16) : (isDark ? 0.24 : 0.08),
            ),
            blurRadius: isOpen ? 18 : 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    AnimatedContainer(
                      duration: duration,
                      curve: Curves.easeOutCubic,
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOpen
                            ? karritoColors.accent
                            : karritoColors.accentContainer,
                      ),
                      child: Icon(
                        icon,
                        size: 19,
                        color: isOpen
                            ? karritoColors.onAccent
                            : karritoColors.accentSoft,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        question,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          height: 1.28,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    AnimatedContainer(
                      duration: duration,
                      curve: Curves.easeOutCubic,
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOpen
                            ? karritoColors.ctaContainer
                            : karritoColors.fieldSurface,
                      ),
                      child: AnimatedRotation(
                        turns: isOpen ? 0.5 : 0.0,
                        duration: duration,
                        curve: Curves.easeOutCubic,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 21,
                          color: isOpen
                              ? karritoColors.cta
                              : karritoColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(
                      left: 50,
                      top: 10,
                      right: 6,
                      bottom: 2,
                    ),
                    child: Text(
                      answer,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: karritoColors.textSecondary,
                        height: 1.48,
                      ),
                    ),
                  ),
                  crossFadeState: isOpen
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: duration,
                  sizeCurve: Curves.easeOutCubic,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
