import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/subscription_service.dart';
import '../../providers/shopping_providers.dart';
import '../screens/guide_faq_screen.dart';
import '../screens/monthly_expenses_screen.dart';
import '../screens/plans_screen.dart';
import '../screens/settings_screen.dart';
import 'google_mark_icon.dart';
import 'karrito_bounce_button.dart';
import 'profile_avatar_widget.dart';

/// Profile menu sheet opened by tapping the circular profile avatar button
/// in the top-right corner of `ShoppingListScreen`.
class ProfileMenuSheet extends ConsumerWidget {
  const ProfileMenuSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const ProfileMenuSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountStatusProvider);
    final prefs = ref.watch(preferencesProvider).value;
    final planTier = ref.watch(effectivePlanTierProvider);
    final isPro = KarritoPlanTier.isPro(planTier);
    final uiState = ref.watch(shoppingControllerProvider);
    final controller = ref.read(shoppingControllerProvider.notifier);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final karritoColors = theme.extension<KarritoColors>()!;

    final avatarChoice = prefs?.avatarChoice ?? KarritoAvatars.defaultChoice;
    final googlePhotoUrl = prefs?.googlePhotoUrl ?? account.photoUrl;
    final hasGooglePhoto =
        !account.isAnonymous &&
        googlePhotoUrl != null &&
        googlePhotoUrl.trim().isNotEmpty;

    final headerTitle = account.isAnonymous
        ? AppStrings.guestAccountTitle
        : (account.displayName?.trim().isNotEmpty == true
              ? account.displayName!.trim()
              : (account.email ?? AppStrings.linkedAccountTitle));
    final headerSubtitle = account.isAnonymous
        ? AppStrings.settingsLocalBadge
        : (account.email ?? AppStrings.linkedAccountTitle);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with user info & current avatar
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: karritoColors.fieldSurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: karritoColors.border, width: 1),
            ),
            child: Row(
              children: [
                KarritoProfileAvatar(
                  avatarChoice: avatarChoice,
                  googlePhotoUrl: googlePhotoUrl,
                  size: 56,
                  isSelected: true,
                  showLinkedDot: !account.isAnonymous,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        headerTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        headerSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: karritoColors.textSecondary,
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
                  ),
                  child: Text(
                    account.isAnonymous
                        ? AppStrings.settingsLocalBadge
                        : AppStrings.settingsBackedUpBadge,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: account.isAnonymous
                          ? karritoColors.onCtaContainer
                          : karritoColors.onCompletedContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Horizontal avatar picker
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              AppStrings.profileAvatarPickerLabel,
              style: theme.textTheme.labelMedium?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: karritoColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 62,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                if (hasGooglePhoto) ...[
                  _AvatarOptionTile(
                    choice: KarritoAvatars.googleChoice,
                    googlePhotoUrl: googlePhotoUrl,
                    tooltip: AppStrings.profileGooglePhotoLabel,
                    isSelected: avatarChoice == KarritoAvatars.googleChoice,
                    onTap: () =>
                        controller.setAvatarChoice(KarritoAvatars.googleChoice),
                  ),
                  const SizedBox(width: 10),
                ],
                for (
                  var i = 0;
                  i < KarritoAvatars.localChoices.length;
                  i++
                ) ...[
                  if (i > 0) const SizedBox(width: 10),
                  _AvatarOptionTile(
                    choice: KarritoAvatars.localChoices[i],
                    googlePhotoUrl: null,
                    tooltip: 'Avatar ${i + 1}',
                    isSelected: avatarChoice == KarritoAvatars.localChoices[i],
                    onTap: () => controller.setAvatarChoice(
                      KarritoAvatars.localChoices[i],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Menu options
          _ProfileActionTile(
            icon: Icons.workspace_premium_rounded,
            title: AppStrings.profilePlansOption,
            subtitle:
                'Tu plan actual: ${KarritoPlanTier.displayName(planTier)}. ${AppStrings.profilePlansSubtitle}',
            onTap: () {
              final navigator = Navigator.of(context);
              navigator.pop();
              navigator.push(
                MaterialPageRoute<void>(builder: (_) => const PlansScreen()),
              );
            },
          ),
          if (isPro) ...[
            const SizedBox(height: 10),
            _ProfileActionTile(
              icon: Icons.calculate_outlined,
              title: AppStrings.cartMonthlyHistoryButton,
              subtitle:
                  'Revisá tu consumo mensual por comercio y ajustá tu tope.',
              onTap: () {
                final navigator = Navigator.of(context);
                navigator.pop();
                navigator.push(
                  MaterialPageRoute<void>(
                    builder: (_) => const MonthlyExpensesScreen(),
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 10),
          _ProfileActionTile(
            icon: Icons.tune_rounded,
            title: AppStrings.profilePreferencesOption,
            subtitle: AppStrings.profilePreferencesSubtitle,
            onTap: () {
              final navigator = Navigator.of(context);
              navigator.pop();
              navigator.push(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(height: 10),
          _ProfileActionTile(
            icon: Icons.menu_book_rounded,
            title: AppStrings.profileGuideFaqOption,
            subtitle: AppStrings.profileGuideFaqSubtitle,
            onTap: () {
              final navigator = Navigator.of(context);
              navigator.pop();
              navigator.push(
                MaterialPageRoute<void>(builder: (_) => const GuideFaqScreen()),
              );
            },
          ),
          const SizedBox(height: 10),
          if (account.isAnonymous)
            _ProfileActionTile(
              leadingWidget: const GoogleMarkIcon(size: 20),
              title: uiState.isLinkingGoogle
                  ? AppStrings.linkingGoogleLabel
                  : AppStrings.profileSignInGoogleOption,
              subtitle: AppStrings.profileSignInGoogleSubtitle,
              enabled: !uiState.isLinkingGoogle,
              onTap: () async {
                Navigator.of(context).pop();
                await controller.linkGoogleAccount();
              },
            )
          else
            _ProfileActionTile(
              icon: Icons.logout_rounded,
              iconColor: colorScheme.error,
              iconBackgroundColor: colorScheme.errorContainer,
              title: AppStrings.profileSignOutOption,
              subtitle: AppStrings.profileSignOutSubtitle,
              enabled: !uiState.isLinkingGoogle,
              onTap: () async {
                Navigator.of(context).pop();
                await controller.signOutToGuest();
              },
            ),
        ],
      ),
    );
  }
}

class _AvatarOptionTile extends StatelessWidget {
  const _AvatarOptionTile({
    required this.choice,
    required this.googlePhotoUrl,
    required this.tooltip,
    required this.isSelected,
    required this.onTap,
  });

  final String choice;
  final String? googlePhotoUrl;
  final String tooltip;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final karritoColors = Theme.of(context).extension<KarritoColors>()!;

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        selected: isSelected,
        label: tooltip,
        child: KarritoBounceButton(
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  KarritoProfileAvatar(
                    avatarChoice: choice,
                    googlePhotoUrl: googlePhotoUrl,
                    size: 54,
                    isSelected: isSelected,
                  ),
                  if (isSelected)
                    Positioned(
                      right: -1,
                      bottom: -1,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: karritoColors.lime,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.surface,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 12,
                          color: karritoColors.onLime,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  const _ProfileActionTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.icon,
    this.leadingWidget,
    this.iconColor,
    this.iconBackgroundColor,
    this.enabled = true,
  });

  final IconData? icon;
  final Widget? leadingWidget;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final karritoColors = theme.extension<KarritoColors>()!;

    return Material(
      color: karritoColors.fieldSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: karritoColors.border, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBackgroundColor ?? karritoColors.accentContainer,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child:
                    leadingWidget ??
                    Icon(
                      icon,
                      size: 20,
                      color: iconColor ?? karritoColors.accentSoft,
                    ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: karritoColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                color: karritoColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
