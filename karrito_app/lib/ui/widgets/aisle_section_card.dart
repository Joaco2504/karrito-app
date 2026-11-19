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
    final colorScheme = Theme.of(context).colorScheme;
    final karritoColors = Theme.of(context).extension<KarritoColors>()!;

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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              color: allDone
                  ? karritoColors.completedContainer.withValues(alpha: 0.5)
                  : colorScheme.surfaceContainerLow.withValues(alpha: 0.55),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      aisleName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: allDone
                            ? karritoColors.onCompletedContainer
                            : colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: allDone
                          ? karritoColors.completed
                          : colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      AppStrings.pendingCountBadge(pendingCount, totalCount),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: allDone
                            ? Colors.white
                            : colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    isExpanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Column(
              children: [
                for (var i = 0; i < sortedItems.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _ShoppingItemTile(
                    item: sortedItems[i],
                    onTap: () => onToggleItem(sortedItems[i]),
                    onEdit: () => onEditItem(sortedItems[i]),
                  ),
                ],
              ],
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
  });

  final ShoppingItemEntity item;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final karritoColors = Theme.of(context).extension<KarritoColors>()!;
    final isChecked = item.isChecked;
    final isPendingOffline = item.syncStatus == 'pending_ai';

    return InkWell(
      onTap: onTap,
      onLongPress: onEdit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        color: isChecked
            ? karritoColors.completedContainer.withValues(alpha: 0.42)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isChecked ? karritoColors.completed : Colors.transparent,
                border: Border.all(
                  color: isChecked
                      ? karritoColors.completed
                      : colorScheme.outlineVariant,
                  width: 2,
                ),
              ),
              child: isChecked
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.cleanName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      decoration: isChecked
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: isChecked
                          ? karritoColors.textSecondary
                          : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '${ShareService.formatQuantity(item.quantity)} ${item.unit}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
