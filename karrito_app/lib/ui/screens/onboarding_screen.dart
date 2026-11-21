import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/store_hierarchy.dart';
import '../../providers/shopping_providers.dart';
import '../widgets/karrito_selector_field.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({this.isReviewMode = false, super.key});

  final bool isReviewMode;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late String _selectedCity;

  @override
  void initState() {
    super.initState();
    _selectedCity =
        ref.read(preferencesProvider).value?.city ?? StoreHierarchy.defaultCity;
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

    return Scaffold(
      appBar: widget.isReviewMode
          ? AppBar(title: const Text(AppStrings.settingsGuideTitle))
          : null,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!widget.isReviewMode) ...[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                AppStrings.appName,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Text(
                          AppStrings.onboardingHeadline,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.onboardingSubtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 20),
                        KarritoSelectorField<String>(
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
                        const SizedBox(height: 20),
                        const _OnboardingStepCard(
                          icon: Icons.edit_note_rounded,
                          title: AppStrings.onboardingCard1Title,
                          body: AppStrings.onboardingCard1Body,
                        ),
                        const SizedBox(height: 12),
                        const _OnboardingStepCard(
                          icon: Icons.storefront_outlined,
                          title: AppStrings.onboardingCard2Title,
                          body: AppStrings.onboardingCard2Body,
                        ),
                        const SizedBox(height: 12),
                        const _OnboardingStepCard(
                          icon: Icons.check_circle_outline_rounded,
                          title: AppStrings.onboardingCard3Title,
                          body: AppStrings.onboardingCard3Body,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: FilledButton(
                    onPressed: _handleFinish,
                    child: Text(
                      widget.isReviewMode
                          ? AppStrings.saveGuideButton
                          : AppStrings.startShoppingButton,
                    ),
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

class _OnboardingStepCard extends StatelessWidget {
  const _OnboardingStepCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: colorScheme.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
