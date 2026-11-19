import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/store_hierarchy.dart';
import '../../providers/shopping_providers.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(preferencesProvider);
    final prefs = prefsAsync.value;
    final controller = ref.read(shoppingControllerProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final currentCity =
        (prefs != null && StoreHierarchy.cities.contains(prefs.city))
        ? prefs.city
        : StoreHierarchy.defaultCity;
    final currentTheme = prefs?.themeMode ?? 'system';
    final keepScreenOn = prefs?.keepScreenOn ?? true;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settingsTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                Text(
                  AppStrings.settingsGeneralSection,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DropdownButtonFormField<String>(
                          key: ValueKey<String>('city_$currentCity'),
                          initialValue: currentCity,
                          decoration: const InputDecoration(
                            labelText: AppStrings.cityLabel,
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                          items: StoreHierarchy.cities
                              .map(
                                (city) => DropdownMenuItem<String>(
                                  value: city,
                                  child: Text(city),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.setCity(value);
                            }
                          },
                        ),
                        const SizedBox(height: 18),
                        Text(
                          AppStrings.settingsAppearanceLabel,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<String>(
                          showSelectedIcon: false,
                          segments: const [
                            ButtonSegment<String>(
                              value: 'system',
                              label: Text(AppStrings.themeSystemLabel),
                            ),
                            ButtonSegment<String>(
                              value: 'light',
                              label: Text(AppStrings.themeLightLabel),
                            ),
                            ButtonSegment<String>(
                              value: 'dark',
                              label: Text(AppStrings.themeDarkLabel),
                            ),
                          ],
                          selected: <String>{currentTheme},
                          onSelectionChanged: (selection) {
                            if (selection.isNotEmpty) {
                              controller.setThemeMode(selection.first);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      SwitchListTile.adaptive(
                        value: keepScreenOn,
                        onChanged: (val) =>
                            controller.setKeepScreenOn(val, notify: false),
                        secondary: const Icon(
                          Icons.stay_current_portrait_rounded,
                        ),
                        title: const Text(AppStrings.settingsKeepScreenOnTitle),
                        subtitle: const Text(
                          AppStrings.settingsKeepScreenOnSubtitle,
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.menu_book_outlined),
                        title: const Text(AppStrings.settingsGuideTitle),
                        subtitle: const Text(AppStrings.settingsGuideSubtitle),
                        trailing: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    const OnboardingScreen(isReviewMode: true),
                              ),
                            );
                          },
                          child: const Text(AppStrings.settingsViewGuideButton),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppStrings.faqSectionTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (
                        var i = 0;
                        i < AppStrings.faqEntries.length;
                        i++
                      ) ...[
                        if (i > 0) const Divider(height: 1),
                        ExpansionTile(
                          shape: const Border(),
                          collapsedShape: const Border(),
                          title: Text(
                            AppStrings.faqEntries[i].question,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          childrenPadding: const EdgeInsets.fromLTRB(
                            16,
                            0,
                            16,
                            14,
                          ),
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                AppStrings.faqEntries[i].answer,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
