import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/store_hierarchy.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/shopping_providers.dart';
import '../widgets/karrito_selector_field.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(preferencesProvider);
    final prefs = prefsAsync.value;
    final uiState = ref.watch(shoppingControllerProvider);
    final account = ref.watch(accountStatusProvider);
    final controller = ref.read(shoppingControllerProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final karritoColors = theme.extension<KarritoColors>()!;

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
                  AppStrings.cloudBackupSection,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: account.isAnonymous
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.cloud_off_outlined,
                                    color: karritoColors.textSecondary,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      AppStrings.guestAccountTitle,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppStrings.guestAccountSubtitle,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: karritoColors.textSecondary,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 14),
                              FilledButton.icon(
                                onPressed: uiState.isLinkingGoogle
                                    ? null
                                    : controller.linkGoogleAccount,
                                icon: uiState.isLinkingGoogle
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.login_rounded, size: 18),
                                label: Text(
                                  uiState.isLinkingGoogle
                                      ? AppStrings.linkingGoogleLabel
                                      : AppStrings.linkGoogleButton,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: karritoColors.completedContainer,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.cloud_done_outlined,
                                      color: karritoColors.completed,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppStrings.linkedAccountTitle,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        if (account.email != null &&
                                            account.email!.isNotEmpty)
                                          Text(
                                            account.email!,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: karritoColors
                                                      .textSecondary,
                                                ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              OutlinedButton.icon(
                                onPressed: uiState.isSyncing
                                    ? null
                                    : () => controller.syncNow(
                                        userTriggered: true,
                                      ),
                                icon: uiState.isSyncing
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.sync_rounded, size: 18),
                                label: Text(
                                  uiState.isSyncing
                                      ? AppStrings.syncingNowLabel
                                      : AppStrings.syncNowButton,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),
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
                        KarritoSelectorField<String>(
                          label: AppStrings.cityLabel,
                          sheetTitle: AppStrings.selectCityTitle,
                          leadingIcon: Icons.location_on_outlined,
                          value: currentCity,
                          options: StoreHierarchy.cities,
                          onChanged: controller.setCity,
                        ),
                        const SizedBox(height: 18),
                        const KarritoFieldLabel(
                          AppStrings.settingsAppearanceLabel,
                        ),
                        const SizedBox(height: 6),
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
                      SwitchListTile(
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
