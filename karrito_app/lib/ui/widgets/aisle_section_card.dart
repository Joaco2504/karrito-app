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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onToggleExpand,
            child: AnimatedContainer(
              duration: disableAnimations
                  ? Duration.zero
                  : const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              color: allDone
                  ? karritoColors.completedContainer.withValues(alpha: 0.65)
                  : karritoColors.fieldSurface.withValues(alpha: 0.72),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      aisleName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
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
                      horizontal: 9,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: allDone
                          ? karritoColors.completed
                          : karritoColors.accentContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      AppStrings.pendingCountBadge(pendingCount, totalCount),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: allDone
                            ? colorScheme.onTertiary
                            : karritoColors.onAccentContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: disableAnimations
                        ? Duration.zero
                        : const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                for (var i = 0; i < sortedItems.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _ShoppingItemTile(
                    key: ValueKey<String>(sortedItems[i].id),
                    item: sortedItems[i],
                    onTap: () => onToggleItem(sortedItems[i]),
                    onEdit: () => onEditItem(sortedItems[i]),
                  ),
                ],
              ],
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
    final isChecked = item.isChecked;
    final isPendingOffline = item.syncStatus == 'pending_ai';
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final animDuration = disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 200);

    return InkWell(
      onTap: onTap,
      onLongPress: onEdit,
      child: AnimatedContainer(
        duration: animDuration,
        curve: Curves.easeOutCubic,
        color: isChecked
            ? karritoColors.completedContainer.withValues(alpha: 0.45)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            AnimatedContainer(
              duration: animDuration,
              curve: Curves.easeOutBack,
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isChecked ? karritoColors.completed : Colors.transparent,
                border: Border.all(
                  color: isChecked
                      ? karritoColors.completed
                      : karritoColors.border,
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
                        size: 15,
                        color: colorScheme.onTertiary,
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
                          fontWeight: FontWeight.w500,
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
                        ),
                      ),
                      if (isPendingOffline) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: karritoColors.warningSurface,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            AppStrings.pendingOfflineBadge,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: karritoColors.warningText,
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
                Icons.more_vert_rounded,
                size: 20,
                color: karritoColors.textSecondary,
              ),
              tooltip: AppStrings.editItemTitle,
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }
}
