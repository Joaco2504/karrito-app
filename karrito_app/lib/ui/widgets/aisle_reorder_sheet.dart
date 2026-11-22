import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/store_hierarchy.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/store_visuals.dart';
import 'karrito_asset_icon.dart';
import 'karrito_bounce_button.dart';

class AisleReorderSheet extends StatefulWidget {
  const AisleReorderSheet({
    required this.storeCategory,
    required this.initialAisles,
    this.aisleItemPreviews = const <String, List<String>>{},
    super.key,
  });

  final String storeCategory;
  final List<String> initialAisles;
  final Map<String, List<String>> aisleItemPreviews;

  static Future<List<String>?> show({
    required BuildContext context,
    required String storeCategory,
    required List<String> initialAisles,
    Map<String, List<String>> aisleItemPreviews =
        const <String, List<String>>{},
  }) {
    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => AisleReorderSheet(
        storeCategory: storeCategory,
        initialAisles: initialAisles,
        aisleItemPreviews: aisleItemPreviews,
      ),
    );
  }

  @override
  State<AisleReorderSheet> createState() => _AisleReorderSheetState();
}

class _AisleReorderSheetState extends State<AisleReorderSheet> {
  late List<String> _aisles;

  @override
  void initState() {
    super.initState();
    _aisles = List<String>.from(widget.initialAisles);
  }

  void _onReorderItem(int oldIndex, int newIndex) {
    setState(() {
      final moved = _aisles.removeAt(oldIndex);
      _aisles.insert(newIndex, moved);
    });
  }

  void _resetToDefaultOrder() {
    final defaults =
        StoreHierarchy.storeAisles[widget.storeCategory] ?? const <String>[];
    setState(() {
      _aisles.sort((a, b) {
        final idxA = defaults.indexOf(a);
        final idxB = defaults.indexOf(b);
        final rankA = idxA >= 0 ? idxA : 999;
        final rankB = idxB >= 0 ? idxB : 999;
        if (rankA != rankB) return rankA.compareTo(rankB);
        return a.compareTo(b);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final karritoColors = theme.extension<KarritoColors>()!;
    final isDark = theme.brightness == Brightness.dark;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.86;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: karritoColors.fieldSurface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: karritoColors.border),
              ),
              child: Row(
                children: [
                  KarritoAssetIcon.store(
                    widget.storeCategory,
                    size: 18,
                    color: karritoColors.cta,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Comercio:',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: karritoColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      widget.storeCategory,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _resetToDefaultOrder,
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.restart_alt_rounded, size: 16),
                    label: const Text(
                      AppStrings.reorderResetButton,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.reorderAislesTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    AppStrings.reorderAislesSubtitle(widget.storeCategory),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: karritoColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ReorderableListView.builder(
                shrinkWrap: true,
                buildDefaultDragHandles: false,
                itemCount: _aisles.length,
                onReorderItem: _onReorderItem,
                proxyDecorator: (child, index, animation) {
                  return Material(
                    color: Colors.transparent,
                    elevation: 10,
                    shadowColor: karritoColors.cta.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(22),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: karritoColors.cta,
                              width: 2,
                            ),
                          ),
                          child: child,
                        ),
                        Positioned(
                          left: 0,
                          top: 12,
                          bottom: 20,
                          child: Container(
                            width: 5,
                            decoration: BoxDecoration(
                              color: karritoColors.cta,
                              borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(999),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 46,
                          top: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: karritoColors.cta,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              AppStrings.reorderMovingBadge,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                itemBuilder: (context, index) {
                  final aisle = _aisles[index];
                  final previews =
                      widget.aisleItemPreviews[aisle] ?? const <String>[];
                  final hasItems = previews.isNotEmpty;
                  final previewText = previews.take(3).join(', ');
                  final visual = StoreVisuals.forAisle(aisle);

                  return Padding(
                    key: ValueKey<String>('reorder::$aisle'),
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ReorderableDragStartListener(
                      index: index,
                      child: Opacity(
                        opacity: hasItems || widget.aisleItemPreviews.isEmpty
                            ? 1.0
                            : 0.78,
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 64),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: karritoColors.fieldSurface,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: karritoColors.border,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: visual.color.withValues(
                                    alpha: isDark ? 0.22 : 0.16,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: KarritoAssetIcon.aisle(
                                    aisle,
                                    size: 20,
                                    color: visual.color,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '#${index + 1}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            fontFeatures: const [
                                              FontFeature.tabularFigures(),
                                            ],
                                            color: index == 0
                                                ? karritoColors.completed
                                                : karritoColors.accentSoft,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            aisle,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: colorScheme.onSurface,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (widget
                                        .aisleItemPreviews
                                        .isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: hasItems
                                                  ? karritoColors.lime
                                                  : colorScheme.surface,
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              hasItems
                                                  ? AppStrings.reorderInListBadge(
                                                      previews.length,
                                                    )
                                                  : AppStrings
                                                        .reorderNoItemsBadge,
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w800,
                                                color: hasItems
                                                    ? karritoColors.onLime
                                                    : karritoColors
                                                          .textSecondary,
                                              ),
                                            ),
                                          ),
                                          if (hasItems) ...[
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                previewText,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                      color: karritoColors
                                                          .textSecondary,
                                                      fontSize: 12,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.drag_indicator_rounded,
                                color: karritoColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: karritoColors.aisleCardSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: karritoColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: karritoColors.ctaContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 16,
                      color: karritoColors.cta,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppStrings.reorderTipBody,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: karritoColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: KarritoBounceButton(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        AppStrings.cancelButton,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 7,
                  child: KarritoBounceButton(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).pop(_aisles),
                      icon: Icon(
                        Icons.check_circle_outline_rounded,
                        size: 19,
                        color: karritoColors.lime,
                      ),
                      label: const Text(
                        AppStrings.saveOrderButton,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
