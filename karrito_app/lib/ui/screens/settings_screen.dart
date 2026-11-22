import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/store_hierarchy.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/shopping_providers.dart';
import '../widgets/karrito_bounce_button.dart';
import '../widgets/karrito_selector_field.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int? _openFaqIndex;

  @override
  Widget build(BuildContext context) {
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
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: account.isAnonymous
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: karritoColors.accentContainer,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      Icons.cloud_off_outlined,
                                      color: karritoColors.accentSoft,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      AppStrings.guestAccountTitle,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                AppStrings.guestAccountSubtitle,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: karritoColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 16),
                              KarritoBounceButton(
                                enabled: !uiState.isLinkingGoogle,
                                child: FilledButton.icon(
                                  onPressed: uiState.isLinkingGoogle
                                      ? null
                                      : controller.linkGoogleAccount,
                                  icon: uiState.isLinkingGoogle
                                      ? SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: colorScheme.onPrimary,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.login_rounded,
                                          size: 18,
                                        ),
                                  label: Text(
                                    uiState.isLinkingGoogle
                                        ? AppStrings.linkingGoogleLabel
                                        : AppStrings.linkGoogleButton,
                                  ),
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
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: karritoColors.lime,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      Icons.cloud_done_outlined,
                                      color: karritoColors.onLime,
                                      size: 21,
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
                                                fontWeight: FontWeight.w800,
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
                              const SizedBox(height: 16),
                              KarritoBounceButton(
                                enabled: !uiState.isSyncing,
                                child: OutlinedButton.icon(
                                  onPressed: uiState.isSyncing
                                      ? null
                                      : () => controller.syncNow(
                                          userTriggered: true,
                                        ),
                                  icon: uiState.isSyncing
                                      ? SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: karritoColors.accentSoft,
                                          ),
                                        )
                                      : Icon(
                                          Icons.sync_rounded,
                                          size: 18,
                                          color: karritoColors.accentSoft,
                                        ),
                                  label: Text(
                                    uiState.isSyncing
                                        ? AppStrings.syncingNowLabel
                                        : AppStrings.syncNowButton,
                                  ),
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
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
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
                      SwitchListTile(
                        value: keepScreenOn,
                        onChanged: (val) =>
                            controller.setKeepScreenOn(val, notify: false),
                        secondary: Icon(
                          Icons.stay_current_portrait_rounded,
                          color: keepScreenOn
                              ? karritoColors.accentSoft
                              : karritoColors.textSecondary,
                        ),
                        title: const Text(AppStrings.settingsKeepScreenOnTitle),
                        subtitle: const Text(
                          AppStrings.settingsKeepScreenOnSubtitle,
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.menu_book_outlined,
                          color: karritoColors.accentSoft,
                        ),
                        title: const Text(AppStrings.settingsGuideTitle),
                        subtitle: const Text(AppStrings.settingsGuideSubtitle),
                        trailing: KarritoBounceButton(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const OnboardingScreen(
                                    isReviewMode: true,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              AppStrings.settingsViewGuideButton,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppStrings.faqSectionTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                for (var i = 0; i < AppStrings.faqEntries.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  _FaqAccordionCard(
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

class _FaqAccordionCard extends StatelessWidget {
  const _FaqAccordionCard({
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
        borderRadius: BorderRadius.circular(20),
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
                    padding: const EdgeInsets.only(top: 12, left: 21, right: 4),
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
                  sizeCurve: Curves.easeInOutCubic,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
