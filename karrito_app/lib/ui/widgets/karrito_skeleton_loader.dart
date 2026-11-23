import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Shimmer/pulse placeholder mimicking store tabs and aisle cards while local
/// data loads or while AI organizes newly entered items.
class KarritoSkeletonLoader extends StatefulWidget {
  const KarritoSkeletonLoader({
    this.showStoreTabs = true,
    this.cardCount = 2,
    this.shrinkWrap = false,
    super.key,
  });

  final bool showStoreTabs;
  final int cardCount;
  final bool shrinkWrap;

  @override
  State<KarritoSkeletonLoader> createState() => _KarritoSkeletonLoaderState();
}

class _KarritoSkeletonLoaderState extends State<KarritoSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final karritoColors =
        theme.extension<KarritoColors>() ?? KarritoColors.light;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    final baseColor = isDark
        ? const Color(0xFF1E192E)
        : const Color(0xFFECE5FA);
    final highlightColor = isDark
        ? const Color(0xFF2E2646)
        : const Color(0xFFF9F6FF);

    Widget buildContent(Color shimmerColor) {
      final children = <Widget>[
        if (widget.showStoreTabs) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              children: [
                _SkeletonBox(
                  width: 128,
                  height: 34,
                  radius: 999,
                  color: shimmerColor,
                ),
                const SizedBox(width: 8),
                _SkeletonBox(
                  width: 102,
                  height: 34,
                  radius: 999,
                  color: shimmerColor,
                ),
                const SizedBox(width: 8),
                _SkeletonBox(
                  width: 112,
                  height: 34,
                  radius: 999,
                  color: shimmerColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        for (var i = 0; i < widget.cardCount; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _SkeletonAisleCard(
            shimmerColor: shimmerColor,
            cardSurface: isDark
                ? karritoColors.aisleCardSurface
                : theme.colorScheme.surface,
            borderColor: karritoColors.border,
            rowCount: i == 0 ? 3 : 2,
          ),
        ],
      ];

      if (widget.shrinkWrap) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        );
      }

      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: children,
      );
    }

    if (disableAnimations) {
      return Semantics(
        label: 'Cargando productos de la lista',
        child: buildContent(baseColor),
      );
    }

    return Semantics(
      label: 'Cargando productos de la lista',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_controller.value);
          final shimmerColor = Color.lerp(baseColor, highlightColor, t)!;
          return buildContent(shimmerColor);
        },
      ),
    );
  }
}

class _SkeletonAisleCard extends StatelessWidget {
  const _SkeletonAisleCard({
    required this.shimmerColor,
    required this.cardSurface,
    required this.borderColor,
    required this.rowCount,
  });

  final Color shimmerColor;
  final Color cardSurface;
  final Color borderColor;
  final int rowCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor.withValues(alpha: 0.65)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _SkeletonBox(
                width: 34,
                height: 34,
                radius: 999,
                color: shimmerColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SkeletonBox(
                  width: double.infinity,
                  height: 15,
                  radius: 8,
                  color: shimmerColor,
                ),
              ),
              const SizedBox(width: 28),
              _SkeletonBox(
                width: 42,
                height: 22,
                radius: 999,
                color: shimmerColor,
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (var r = 0; r < rowCount; r++) ...[
            if (r > 0) const SizedBox(height: 10),
            Row(
              children: [
                _SkeletonBox(
                  width: 22,
                  height: 22,
                  radius: 7,
                  color: shimmerColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SkeletonBox(
                    width: double.infinity,
                    height: 14,
                    radius: 8,
                    color: shimmerColor,
                  ),
                ),
                const SizedBox(width: 20),
                _SkeletonBox(
                  width: 46,
                  height: 20,
                  radius: 999,
                  color: shimmerColor,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.radius,
    required this.color,
  });

  final double width;
  final double height;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
