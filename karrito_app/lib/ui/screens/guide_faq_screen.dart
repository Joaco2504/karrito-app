import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/karrito_bounce_button.dart';

/// Combined interactive basic guide (3-step carousel) and expandable FAQ
/// accordion opened from the profile menu.
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
      icon: Icons.wifi_off_rounded,
      badge: 'Paso 3 · Sin señal',
      title: AppStrings.onboardingCard3Title,
      body: AppStrings.onboardingCard3Body,
      tip: AppStrings.onboardingCard3Example,
    ),
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
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.guideFaqTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
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
                SizedBox(
                  height: 224,
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
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: karritoColors.aisleCardSurface,
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: karritoColors.border,
                              width: 1,
                            ),
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
                                      borderRadius: BorderRadius.circular(999),
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
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: karritoColors.textSecondary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                step.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Expanded(
                                child: Text(
                                  step.body,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: karritoColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
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
                                  style: theme.textTheme.labelSmall?.copyWith(
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
                const SizedBox(height: 20),
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
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                for (var i = 0; i < AppStrings.faqEntries.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  _GuideFaqCard(
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
    required this.question,
    required this.answer,
    required this.isOpen,
    required this.onTap,
  });

  final String question;
  final String answer;
  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final karritoColors = theme.extension<KarritoColors>()!;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final duration = disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 220);

    return AnimatedContainer(
      duration: duration,
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isOpen ? karritoColors.accentSoft : karritoColors.border,
          width: isOpen ? 1.5 : 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    AnimatedContainer(
                      duration: duration,
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOpen
                            ? karritoColors.lime
                            : karritoColors.border,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        question,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: isOpen ? 0.5 : 0.0,
                      duration: duration,
                      curve: Curves.easeOutCubic,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 22,
                        color: isOpen
                            ? karritoColors.accentSoft
                            : karritoColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(left: 21, top: 10, right: 4),
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
