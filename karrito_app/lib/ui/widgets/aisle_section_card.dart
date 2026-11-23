import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/store_visuals.dart';
import '../../data/local/app_database.dart';
import '../../data/services/share_service.dart';
import '../../domain/services/currency_formatter.dart';
import '../../domain/services/recipe_package_normalizer.dart';
import 'karrito_asset_icon.dart';

class AisleSectionCard extends StatelessWidget {
  const AisleSectionCard({
    required this.aisleName,
    required this.items,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onToggleItem,
    required this.onEditItem,
    this.showPriceChips = false,
    this.onEditPrice,
    super.key,
  });

  final String aisleName;
  final List<ShoppingItemEntity> items;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final ValueChanged<ShoppingItemEntity> onToggleItem;
  final ValueChanged<ShoppingItemEntity> onEditItem;
  final bool showPriceChips;
  final ValueChanged<ShoppingItemEntity>? onEditPrice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final karritoColors = theme.extension<KarritoColors>()!;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final isDark = theme.brightness == Brightness.dark;
    final visual = StoreVisuals.forAisle(aisleName);

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
                alpha: isDark ? 0.55 : 0.72,
              )
            : karritoColors.aisleCardSurface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: allDone
              ? karritoColors.completed.withValues(alpha: 0.35)
              : karritoColors.border.withValues(alpha: isDark ? 0.85 : 0.75),
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
                padding: const EdgeInsets.fromLTRB(14, 13, 12, 11),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: allDone
                            ? karritoColors.lime
                            : visual.color.withValues(
                                alpha: isDark ? 0.22 : 0.16,
                              ),
                      ),
                      child: Center(
                        child: allDone
                            ? Icon(
                                Icons.check_rounded,
                                size: 17,
                                color: karritoColors.onLime,
                              )
                            : KarritoAssetIcon.aisle(
                                aisleName,
                                size: 20,
                                color: visual.color,
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        aisleName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.15,
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
                    if (i > 0) const SizedBox(height: 8),
                    _ShoppingItemTile(
                      key: ValueKey<String>(sortedItems[i].id),
                      item: sortedItems[i],
                      showPriceChip: showPriceChips,
                      onTap: () => onToggleItem(sortedItems[i]),
                      onEdit: () => onEditItem(sortedItems[i]),
                      onEditPrice: onEditPrice != null
                          ? () => onEditPrice!(sortedItems[i])
                          : null,
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

class _ShoppingItemTile extends StatefulWidget {
  const _ShoppingItemTile({
    required this.item,
    required this.onTap,
    required this.onEdit,
    this.showPriceChip = false,
    this.onEditPrice,
    super.key,
  });

  final ShoppingItemEntity item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final bool showPriceChip;
  final VoidCallback? onEditPrice;

  @override
  State<_ShoppingItemTile> createState() => _ShoppingItemTileState();
}

class _ShoppingItemTileState extends State<_ShoppingItemTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _burstController;
  late final Animation<double> _popScale;

  @override
  void initState() {
    super.initState();
    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _popScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.78,
          end: 1.24,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.24,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 55,
      ),
    ]).animate(_burstController);
  }

  @override
  void didUpdateWidget(covariant _ShoppingItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.item.isChecked && widget.item.isChecked) {
      if (!MediaQuery.disableAnimationsOf(context)) {
        _burstController.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _burstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final karritoColors = theme.extension<KarritoColors>()!;
    final isDark = theme.brightness == Brightness.dark;
    final isChecked = widget.item.isChecked;
    final isPendingOffline = widget.item.syncStatus == 'pending_ai';
    final recipeNote = RecipePackageNormalizer.extractRecipeNote(
      widget.item.rawText,
    );
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final animDuration = disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 200);

    final tileBg = isChecked
        ? karritoColors.checkedTileSurface
        : (isDark ? karritoColors.fieldSurface : colorScheme.surface);

    final tileBorder = isChecked
        ? karritoColors.checkedTileBorder
        : karritoColors.border.withValues(alpha: isDark ? 0.65 : 0.45);

    return AnimatedContainer(
      duration: animDuration,
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: tileBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: tileBorder, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: widget.onEdit,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 11, 6, 11),
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                  height: 30,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      if (!disableAnimations)
                        AnimatedBuilder(
                          animation: _burstController,
                          builder: (context, _) {
                            if (!_burstController.isAnimating) {
                              return const SizedBox.shrink();
                            }
                            return CustomPaint(
                              size: const Size(30, 30),
                              painter: _CheckSparklePainter(
                                progress: _burstController.value,
                                primaryColor: karritoColors.accent,
                                limeColor: karritoColors.lime,
                                papayaColor: karritoColors.cta,
                              ),
                            );
                          },
                        ),
                      AnimatedBuilder(
                        animation: _popScale,
                        builder: (context, child) {
                          final scale = _burstController.isAnimating
                              ? _popScale.value
                              : 1.0;
                          return Transform.scale(scale: scale, child: child);
                        },
                        child: AnimatedContainer(
                          duration: animDuration,
                          curve: Curves.easeOutCubic,
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isChecked
                                ? karritoColors.accent
                                : Colors.transparent,
                            border: Border.all(
                              color: isChecked
                                  ? karritoColors.accent
                                  : karritoColors.textSecondary.withValues(
                                      alpha: 0.55,
                                    ),
                              width: 2,
                            ),
                            boxShadow: isChecked && isDark
                                ? [
                                    BoxShadow(
                                      color: karritoColors.accent.withValues(
                                        alpha: 0.45,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
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
                                    color: karritoColors.onAccent,
                                  )
                                : const SizedBox.shrink(
                                    key: ValueKey<bool>(false),
                                  ),
                          ),
                        ),
                      ),
                    ],
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
                              fontWeight: FontWeight.w700,
                              decoration: isChecked
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              decorationThickness: 2,
                              color: isChecked
                                  ? karritoColors.textSecondary.withValues(
                                      alpha: 0.72,
                                    )
                                  : colorScheme.onSurface,
                            ) ??
                            const TextStyle(),
                        child: Text(widget.item.cleanName),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '${ShareService.formatQuantity(widget.item.quantity)} ${widget.item.unit}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isChecked
                                  ? karritoColors.textSecondary.withValues(
                                      alpha: 0.65,
                                    )
                                  : karritoColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
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
                                color: karritoColors.cta,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                AppStrings.pendingOfflineBadge,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: karritoColors.onCta,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (recipeNote != null) ...[
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: karritoColors.accentContainer.withValues(
                              alpha: isDark ? 0.65 : 0.85,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            recipeNote,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: karritoColors.onAccentContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.showPriceChip && widget.onEditPrice != null) ...[
                  const SizedBox(width: 6),
                  Material(
                    color: widget.item.price != null
                        ? karritoColors.accentContainer
                        : karritoColors.fieldSurface,
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: widget.item.price != null
                            ? karritoColors.accentSoft.withValues(alpha: 0.45)
                            : karritoColors.border,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: widget.onEditPrice,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        child: Text(
                          widget.item.price != null
                              ? CurrencyFormatter.formatArs(widget.item.price!)
                              : '+ ${AppStrings.cartPutPriceButton}',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            fontFeatures: const [FontFeature.tabularFigures()],
                            color: widget.item.price != null
                                ? karritoColors.onAccentContainer
                                : karritoColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 19,
                    color: karritoColors.textSecondary,
                  ),
                  tooltip: AppStrings.editItemTitle,
                  onPressed: widget.onEdit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckSparklePainter extends CustomPainter {
  const _CheckSparklePainter({
    required this.progress,
    required this.primaryColor,
    required this.limeColor,
    required this.papayaColor,
  });

  final double progress;
  final Color primaryColor;
  final Color limeColor;
  final Color papayaColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final colors = <Color>[
      primaryColor,
      limeColor,
      papayaColor,
      primaryColor,
      limeColor,
      papayaColor,
      limeColor,
    ];
    final eased = Curves.easeOutCubic.transform(progress);
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    final radius = 12.0 + (16.0 * eased);
    final dotSize = 3.2 * (1.0 - (progress * 0.6));

    for (var i = 0; i < colors.length; i++) {
      final angle = (2 * math.pi * i) / colors.length - (math.pi / 2);
      final pos = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      final paint = Paint()
        ..color = colors[i].withValues(alpha: opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, dotSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CheckSparklePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
