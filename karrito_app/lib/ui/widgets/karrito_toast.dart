import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

enum KarritoToastType { success, error, info }

/// Reusable animated floating toast overlay replacing plain SnackBars across
/// Karrito. Supports top slide + fade transitions, status icons, swipe/tap
/// dismissal, reduced motion, and safe timer cleanup.
class KarritoToast {
  KarritoToast._();

  static OverlayEntry? _activeEntry;
  static VoidCallback? _activeDismiss;

  static void dismissCurrent() {
    final dismiss = _activeDismiss;
    if (dismiss != null) {
      dismiss();
      return;
    }
    _activeEntry?.remove();
    _activeEntry = null;
  }

  static void show(
    BuildContext context, {
    required String message,
    KarritoToastType type = KarritoToastType.info,
    Duration duration = const Duration(milliseconds: 3200),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    showInOverlay(overlay, message: message, type: type, duration: duration);
  }

  static void showInOverlay(
    OverlayState overlay, {
    required String message,
    KarritoToastType type = KarritoToastType.info,
    Duration duration = const Duration(milliseconds: 3200),
  }) {
    _activeEntry?.remove();
    _activeEntry = null;
    _activeDismiss = null;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (overlayContext) {
        return _KarritoToastOverlay(
          message: message,
          type: type,
          duration: duration,
          onRegisterDismiss: (fn) {
            if (_activeEntry == entry) {
              _activeDismiss = fn;
            }
          },
          onRemoved: () {
            if (_activeEntry == entry) {
              _activeEntry = null;
              _activeDismiss = null;
            }
            if (entry.mounted) {
              entry.remove();
            }
          },
        );
      },
    );

    _activeEntry = entry;
    overlay.insert(entry);
  }
}

class _KarritoToastOverlay extends StatefulWidget {
  const _KarritoToastOverlay({
    required this.message,
    required this.type,
    required this.duration,
    required this.onRegisterDismiss,
    required this.onRemoved,
  });

  final String message;
  final KarritoToastType type;
  final Duration duration;
  final ValueChanged<VoidCallback> onRegisterDismiss;
  final VoidCallback onRemoved;

  @override
  State<_KarritoToastOverlay> createState() => _KarritoToastOverlayState();
}

class _KarritoToastOverlayState extends State<_KarritoToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  Timer? _dismissTimer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    widget.onRegisterDismiss(_dismiss);
    _controller.forward();
    _dismissTimer = Timer(widget.duration, _dismiss);
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (_isDismissing) return;
    _isDismissing = true;
    _dismissTimer?.cancel();

    if (mounted) {
      final disableAnimations = MediaQuery.disableAnimationsOf(context);
      if (!disableAnimations) {
        try {
          await _controller.reverse();
        } catch (_) {
          // Ignore ticker cancellation if overlay was torn down.
        }
      }
    }
    widget.onRemoved();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final karritoColors =
        theme.extension<KarritoColors>() ?? KarritoColors.light;
    final topPadding = MediaQuery.paddingOf(context).top;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    final (
      Color badgeBg,
      Color iconColor,
      Color borderColor,
      IconData iconData,
    ) = switch (widget.type) {
      KarritoToastType.success => (
        karritoColors.lime,
        karritoColors.onLime,
        karritoColors.completed.withValues(alpha: 0.55),
        Icons.check_circle_rounded,
      ),
      KarritoToastType.error => (
        colorScheme.errorContainer,
        colorScheme.error,
        colorScheme.error.withValues(alpha: 0.55),
        Icons.error_outline_rounded,
      ),
      KarritoToastType.info => (
        karritoColors.accentContainer,
        karritoColors.accentSoft,
        karritoColors.accent.withValues(alpha: 0.55),
        Icons.info_outline_rounded,
      ),
    };

    final card = Semantics(
      liveRegion: true,
      container: true,
      child: Material(
        color: Colors.transparent,
        child: Dismissible(
          key: ValueKey<String>('karrito_toast_${widget.message}'),
          direction: DismissDirection.up,
          onDismissed: (_) {
            _dismissTimer?.cancel();
            widget.onRemoved();
          },
          child: GestureDetector(
            onTap: _dismiss,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 520),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 1.3),
                boxShadow: [
                  BoxShadow(
                    color: karritoColors.shadowTint.withValues(alpha: 0.28),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: badgeBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconData, size: 19, color: iconColor),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      widget.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: karritoColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return Positioned(
      top: topPadding + 12,
      left: 16,
      right: 16,
      child: Align(
        alignment: Alignment.topCenter,
        child: disableAnimations
            ? card
            : FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(position: _slideAnimation, child: card),
              ),
      ),
    );
  }
}
