import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Canonical profile avatar choices stored in `local_preferences.avatar_choice`.
class KarritoAvatars {
  KarritoAvatars._();

  static const String googleChoice = 'google';
  static const String defaultChoice = 'avatar_1';

  static const List<String> localChoices = <String>[
    'avatar_1',
    'avatar_2',
    'avatar_3',
    'avatar_4',
    'avatar_5',
    'avatar_6',
    'avatar_7',
    'avatar_8',
    'avatar_9',
    'avatar_10',
    'avatar_11',
    'avatar_12',
  ];

  static String assetPathFor(String choice) {
    final normalized = localChoices.contains(choice) ? choice : defaultChoice;
    return 'assets/avatars/$normalized.png';
  }
}

/// Renders the user's circular profile avatar (`40x40` in the AppBar or larger
/// inside the profile menu), preferring the cached Google profile photo when
/// selected and falling back smoothly to the chosen local geometric avatar.
class KarritoProfileAvatar extends StatelessWidget {
  const KarritoProfileAvatar({
    required this.avatarChoice,
    this.googlePhotoUrl,
    this.size = 40,
    this.isSelected = false,
    this.showLinkedDot = false,
    super.key,
  });

  final String avatarChoice;
  final String? googlePhotoUrl;
  final double size;
  final bool isSelected;
  final bool showLinkedDot;

  bool get _shouldShowGooglePhoto =>
      avatarChoice == KarritoAvatars.googleChoice &&
      googlePhotoUrl != null &&
      googlePhotoUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final karritoColors = theme.extension<KarritoColors>()!;
    final fallbackAsset = KarritoAvatars.assetPathFor(
      avatarChoice == KarritoAvatars.googleChoice
          ? KarritoAvatars.defaultChoice
          : avatarChoice,
    );

    Widget buildVectorFallback() {
      return Container(
        width: size,
        height: size,
        color: karritoColors.accentContainer,
        alignment: Alignment.center,
        child: Icon(
          Icons.person_rounded,
          size: size * 0.56,
          color: karritoColors.accentSoft,
        ),
      );
    }

    Widget buildLocalAsset() {
      return Image.asset(
        fallbackAsset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, _, _) => buildVectorFallback(),
      );
    }

    final avatarContent = _shouldShowGooglePhoto
        ? Image.network(
            googlePhotoUrl!.trim(),
            width: size,
            height: size,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
            cacheWidth: (size * 3).round(),
            cacheHeight: (size * 3).round(),
            errorBuilder: (_, _, _) => buildLocalAsset(),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return buildLocalAsset();
            },
          )
        : buildLocalAsset();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            padding: EdgeInsets.all(isSelected ? 2.2 : 1.4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? karritoColors.accent : karritoColors.border,
                width: isSelected ? 2.2 : 1.2,
              ),
              color: karritoColors.fieldSurface,
            ),
            child: ClipOval(child: avatarContent),
          ),
          if (showLinkedDot)
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: karritoColors.lime,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
