import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/store_hierarchy.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/subscription_service.dart';
import '../../providers/shopping_providers.dart';
import '../widgets/karrito_bounce_button.dart';
import '../widgets/karrito_selector_field.dart';
import '../widgets/profile_avatar_widget.dart';
import 'guide_faq_screen.dart';
import 'monthly_expenses_screen.dart';
import 'plans_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Future<void> _confirmAndDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final karritoColors = theme.extension<KarritoColors>()!;
        return AlertDialog(
          title: const Text(AppStrings.deleteAccountDialogTitle),
          content: const Text(AppStrings.deleteAccountDialogBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(AppStrings.cancelButton),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: karritoColors.softDestructive,
                foregroundColor: Colors.white,
              ),
              child: const Text(AppStrings.deleteAccountConfirmButton),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;
    final deleted = await ref
        .read(shoppingControllerProvider.notifier)
        .deleteAccountAndWipeData();
    if (deleted && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefsAsync = ref.watch(preferencesProvider);
    final prefs = prefsAsync.value;
    final planTier = ref.watch(effectivePlanTierProvider);
    final isPro = KarritoPlanTier.isPro(planTier);
    final uiState = ref.watch(shoppingControllerProvider);
    final account = ref.watch(accountStatusProvider);
    final controller = ref.read(shoppingControllerProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final karritoColors = theme.extension<KarritoColors>()!;
    final isDark = theme.brightness == Brightness.dark;

    final currentCity =
        (prefs != null && StoreHierarchy.cities.contains(prefs.city))
        ? prefs.city
        : StoreHierarchy.defaultCity;
    final currentTheme = prefs?.themeMode ?? 'system';
    final keepScreenOn = prefs?.keepScreenOn ?? true;
    final soundEnabled = prefs?.soundEnabled ?? true;
    final vibrationEnabled = prefs?.vibrationEnabled ?? true;
    final remindersEnabled = prefs?.remindersEnabled ?? false;
    final avatarChoice = prefs?.avatarChoice ?? KarritoAvatars.defaultChoice;
    final googlePhotoUrl = prefs?.googlePhotoUrl ?? account.photoUrl;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settingsTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
              children: [
                // Profile & Cloud Sync Hero Card (matches Figma 9._ajustes_y_configuraci_n)
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: isDark
                        ? colorScheme.surface
                        : karritoColors.aisleCardSurface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: karritoColors.border, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: karritoColors.shadowTint,
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -24,
                        bottom: -24,
                        child: Container(
                          width: 112,
                          height: 112,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: karritoColors.accent.withValues(
                              alpha: isDark ? 0.16 : 0.08,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                KarritoProfileAvatar(
                                  avatarChoice: avatarChoice,
                                  googlePhotoUrl: googlePhotoUrl,
                                  size: 48,
                                  showLinkedDot: !account.isAnonymous,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          Text(
                                            account.isAnonymous
                                                ? AppStrings.guestAccountTitle
                                                : AppStrings.linkedAccountTitle,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                          ),
                                          if (account.isAnonymous)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    karritoColors.fieldSurface,
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                              ),
                                              child: Text(
                                                AppStrings.settingsLocalBadge,
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: karritoColors
                                                      .textSecondary,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        account.isAnonymous
                                            ? AppStrings.cloudBackupSection
                                            : (account.email ??
                                                  AppStrings
                                                      .linkedAccountTitle),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color:
                                                  karritoColors.textSecondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: account.isAnonymous
                                        ? karritoColors.ctaContainer
                                        : karritoColors.completedContainer,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: account.isAnonymous
                                          ? karritoColors.cta.withValues(
                                              alpha: 0.35,
                                            )
                                          : karritoColors.completed.withValues(
                                              alpha: 0.35,
                                            ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 7,
                                        height: 7,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: account.isAnonymous
                                              ? karritoColors.cta
                                              : karritoColors.completed,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        account.isAnonymous
                                            ? AppStrings.settingsNoBackupBadge
                                            : AppStrings.settingsBackedUpBadge,
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          color: account.isAnonymous
                                              ? karritoColors.onCtaContainer
                                              : karritoColors
                                                    .onCompletedContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? karritoColors.fieldSurface
                                    : colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: karritoColors.border.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (account.isAnonymous) ...[
                                    Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color:
                                                karritoColors.accentContainer,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.cloud_sync_rounded,
                                            size: 17,
                                            color: karritoColors.accentSoft,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            AppStrings.guestAccountSubtitle,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: colorScheme.onSurface,
                                                  height: 1.35,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
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
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color:
                                                          colorScheme.onPrimary,
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
                                  ] else ...[
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
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: karritoColors
                                                          .accentSoft,
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
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: karritoColors.accentContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.workspace_premium_rounded,
                                size: 21,
                                color: karritoColors.accentSoft,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.plansTitle,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Tu plan actual: ${KarritoPlanTier.displayName(planTier)}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: karritoColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            KarritoBounceButton(
                              child: FilledButton(
                                onPressed: () => PlansScreen.open(context),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(0, 40),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                ),
                                child: const Text(AppStrings.adViewPlansButton),
                              ),
                            ),
                          ],
                        ),
                        if (isPro) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(height: 1),
                          ),
                          OutlinedButton.icon(
                            onPressed: () =>
                                MonthlyExpensesScreen.open(context),
                            icon: const Icon(
                              Icons.calculate_outlined,
                              size: 18,
                            ),
                            label: const Text(
                              AppStrings.cartMonthlyHistoryButton,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // SECTION 1: Apariencia y pantalla
                const _SectionHeading(
                  icon: Icons.palette_outlined,
                  title: AppStrings.settingsAppearanceSection,
                ),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const KarritoFieldLabel(
                          AppStrings.settingsAppearanceLabel,
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<String>(
                          showSelectedIcon: false,
                          segments: const [
                            ButtonSegment<String>(
                              value: 'light',
                              icon: Icon(Icons.light_mode_rounded, size: 16),
                              label: Text(AppStrings.themeLightLabel),
                            ),
                            ButtonSegment<String>(
                              value: 'dark',
                              icon: Icon(Icons.dark_mode_rounded, size: 16),
                              label: Text(AppStrings.themeDarkLabel),
                            ),
                            ButtonSegment<String>(
                              value: 'system',
                              icon: Icon(
                                Icons.brightness_auto_rounded,
                                size: 16,
                              ),
                              label: Text(AppStrings.themeSystemLabel),
                            ),
                          ],
                          selected: <String>{currentTheme},
                          onSelectionChanged: (selection) {
                            if (selection.isNotEmpty) {
                              controller.setThemeMode(selection.first);
                            }
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(height: 1),
                        ),
                        _PreferenceToggleRow(
                          icon: Icons.stay_current_portrait_rounded,
                          iconBg: keepScreenOn
                              ? karritoColors.ctaContainer
                              : karritoColors.fieldSurface,
                          iconColor: keepScreenOn
                              ? karritoColors.cta
                              : karritoColors.textSecondary,
                          title: AppStrings.settingsKeepScreenOnTitle,
                          subtitle: AppStrings.settingsKeepScreenOnSubtitle,
                          value: keepScreenOn,
                          showActiveBadge: true,
                          onChanged: (val) =>
                              controller.setKeepScreenOn(val, notify: false),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // SECTION 2: Localidad
                const _SectionHeading(
                  icon: Icons.storefront_outlined,
                  title: AppStrings.settingsLocationSection,
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
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                              color: karritoColors.cta,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                AppStrings.settingsCityHelper,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: karritoColors.textSecondary,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // SECTION 3: Preferencias de compra (Sonido al tachar + Guía)
                const _SectionHeading(
                  icon: Icons.tune_rounded,
                  title: AppStrings.settingsShoppingSection,
                ),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _PreferenceToggleRow(
                          icon: soundEnabled
                              ? Icons.volume_up_rounded
                              : Icons.volume_off_rounded,
                          iconBg: soundEnabled
                              ? karritoColors.accentContainer
                              : karritoColors.fieldSurface,
                          iconColor: soundEnabled
                              ? karritoColors.accentSoft
                              : karritoColors.textSecondary,
                          title: AppStrings.settingsSoundOnCheckTitle,
                          subtitle: AppStrings.settingsSoundOnCheckSubtitle,
                          value: soundEnabled,
                          showActiveBadge: true,
                          onChanged: controller.setSoundEnabled,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(height: 1),
                        ),
                        _PreferenceToggleRow(
                          icon: Icons.vibration_rounded,
                          iconBg: vibrationEnabled
                              ? karritoColors.accentContainer
                              : karritoColors.fieldSurface,
                          iconColor: vibrationEnabled
                              ? karritoColors.accentSoft
                              : karritoColors.textSecondary,
                          title: AppStrings.settingsVibrationOnCheckTitle,
                          subtitle: AppStrings.settingsVibrationOnCheckSubtitle,
                          value: vibrationEnabled,
                          showActiveBadge: true,
                          onChanged: controller.setVibrationEnabled,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(height: 1),
                        ),
                        _PreferenceToggleRow(
                          icon: remindersEnabled
                              ? Icons.notifications_active_outlined
                              : Icons.notifications_off_outlined,
                          iconBg: remindersEnabled
                              ? karritoColors.accentContainer
                              : karritoColors.fieldSurface,
                          iconColor: remindersEnabled
                              ? karritoColors.accentSoft
                              : karritoColors.textSecondary,
                          title: AppStrings.settingsRemindersTitle,
                          subtitle: AppStrings.settingsRemindersSubtitle,
                          value: remindersEnabled,
                          showActiveBadge: true,
                          onChanged: controller.setRemindersEnabled,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(height: 1),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: karritoColors.accentContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.menu_book_outlined,
                                size: 19,
                                color: karritoColors.accentSoft,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.settingsGuideTitle,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    AppStrings.settingsGuideSubtitle,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: karritoColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            KarritoBounceButton(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const GuideFaqScreen(),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 40),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                ),
                                child: const Text(
                                  AppStrings.settingsViewGuideButton,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // SECTION 4: Cuenta y privacidad (requisito obligatorio Google Play)
                const _SectionHeading(
                  icon: Icons.privacy_tip_outlined,
                  title: AppStrings.accountPrivacySection,
                ),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AppStrings.deleteAccountSubtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: karritoColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        KarritoBounceButton(
                          enabled: !uiState.isDeletingAccount,
                          child: OutlinedButton.icon(
                            onPressed: uiState.isDeletingAccount
                                ? null
                                : _confirmAndDeleteAccount,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              backgroundColor: colorScheme.errorContainer
                                  .withValues(alpha: isDark ? 0.55 : 0.45),
                              foregroundColor: karritoColors.softDestructive,
                              side: BorderSide(
                                color: karritoColors.softDestructive.withValues(
                                  alpha: 0.45,
                                ),
                              ),
                            ),
                            icon: uiState.isDeletingAccount
                                ? SizedBox(
                                    width: 17,
                                    height: 17,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: karritoColors.softDestructive,
                                    ),
                                  )
                                : const Icon(
                                    Icons.delete_forever_outlined,
                                    size: 19,
                                  ),
                            label: Text(
                              uiState.isDeletingAccount
                                  ? AppStrings.deletingAccountLabel
                                  : AppStrings.deleteAccountButton,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppStrings.settingsFooterNote,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: karritoColors.textSecondary,
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

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final karritoColors = Theme.of(context).extension<KarritoColors>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Icon(icon, size: 19, color: karritoColors.accentSoft),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
              color: karritoColors.accentSoft,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreferenceToggleRow extends StatelessWidget {
  const _PreferenceToggleRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.showActiveBadge = false,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showActiveBadge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final karritoColors = theme.extension<KarritoColors>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, size: 19, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (showActiveBadge && value)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: karritoColors.lime,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        AppStrings.settingsActiveBadge,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: karritoColors.onLime,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: karritoColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
