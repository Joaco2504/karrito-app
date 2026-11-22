import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/app_database.dart';
import '../../data/services/share_service.dart';

class AisleSectionCard extends StatelessWidget {
  const AisleSectionCard({
    required this.aisleName,
    required this.items,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onToggleItem,
    required this.onEditItem,
    super.key,
  });

  final String aisleName;
  final List<ShoppingItemEntity> items;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final ValueChanged<ShoppingItemEntity> onToggleItem;
  final ValueChanged<ShoppingItemEntity> onEditItem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final karritoColors = theme.extension<KarritoColors>()!;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final isDark = theme.brightness == Brightness.dark;

    final sortedItems = List<ShoppingItemEntity>.from(items)
      ..sort((a, b) {
        if (a.isChecked != b.isChecked) {
          return a.isChecked ? 1 : -1;
        }
        return a.position.compareTo(b.position);
      });

    final pendingCount = sortedItems.where((item) => !item.isChecked).length;
    final totalCount = sortedItems.length;
    final allDone = pendingCount == 0 && totalCount > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: allDone
            ? karritoColors.completedContainer.withValues(
                alpha: isDark ? 0.55 : 0.65,
              )
            : (isDark ? colorScheme.surface : karritoColors.fieldSurface),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: allDone
              ? karritoColors.completed.withValues(alpha: 0.35)
              : karritoColors.border.withValues(alpha: 0.75),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: karritoColors.shadowTint,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggleExpand,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 13, 12, 11),
                child: Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: allDone
                            ? karritoColors.lime
                            : karritoColors.accentSoft,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        aisleName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.1,
                          color: allDone
                              ? karritoColors.onCompletedContainer
                              : colorScheme.onSurface,
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: disableAnimations
                          ? Duration.zero
                          : const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: allDone
                            ? karritoColors.lime
                            : karritoColors.accentContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        AppStrings.pendingCountBadge(pendingCount, totalCount),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: allDone
                              ? karritoColors.onLime
                              : karritoColors.onAccentContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: disableAnimations
                          ? Duration.zero
                          : const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      child: Icon(
                        Icons.expand_more_rounded,
                        color: karritoColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                children: [
                  for (var i = 0; i < sortedItems.length; i++) ...[
                    if (i > 0) const SizedBox(height: 6),
                    _ShoppingItemTile(
                      key: ValueKey<String>(sortedItems[i].id),
                      item: sortedItems[i],
                      onTap: () => onToggleItem(sortedItems[i]),
                      onEdit: () => onEditItem(sortedItems[i]),
                    ),
                  ],
                ],
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: disableAnimations
                ? Duration.zero
                : const Duration(milliseconds: 220),
            sizeCurve: Curves.easeInOutCubic,
          ),
        ],
      ),
    );
  }
}

class _ShoppingItemTile extends StatelessWidget {
  const _ShoppingItemTile({
    required this.item,
    required this.onTap,
    required this.onEdit,
    super.key,
  });

  final ShoppingItemEntity item;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final karritoColors = theme.extension<KarritoColors>()!;
    final isDark = theme.brightness == Brightness.dark;
    final isChecked = item.isChecked;
    final isPendingOffline = item.syncStatus == 'pending_ai';
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final animDuration = disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 200);

    final tileBg = isChecked
        ? (isDark
              ? karritoColors.completedContainer.withValues(alpha: 0.65)
              : karritoColors.completedContainer.withValues(alpha: 0.6))
        : (isDark ? karritoColors.fieldSurface : colorScheme.surface);

    return Material(
      color: tileBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isChecked
              ? karritoColors.completed.withValues(alpha: 0.28)
              : karritoColors.border.withValues(alpha: isDark ? 0.55 : 0.45),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onEdit,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
          child: Row(
            children: [
              AnimatedContainer(
                duration: animDuration,
                curve: Curves.easeOutBack,
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isChecked ? karritoColors.lime : Colors.transparent,
                  border: Border.all(
                    color: isChecked
                        ? karritoColors.completed
                        : karritoColors.accentSoft.withValues(alpha: 0.65),
                    width: 2,
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: animDuration,
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: isChecked
                      ? Icon(
                          Icons.check_rounded,
                          key: const ValueKey<bool>(true),
                          size: 16,
                          color: karritoColors.onLime,
                        )
                      : const SizedBox.shrink(key: ValueKey<bool>(false)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: animDuration,
                      style:
                          theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w600,
                            decoration: isChecked
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: isChecked
                                ? karritoColors.textSecondary
                                : colorScheme.onSurface,
                          ) ??
                          const TextStyle(),
                      child: Text(item.cleanName),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          '${ShareService.formatQuantity(item.quantity)} ${item.unit}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: karritoColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        if (isPendingOffline) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: karritoColors.ctaContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              AppStrings.pendingOfflineBadge,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: karritoColors.onCtaContainer,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  size: 19,
                  color: karritoColors.textSecondary,
                ),
                tooltip: AppStrings.editItemTitle,
                onPressed: onEdit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
