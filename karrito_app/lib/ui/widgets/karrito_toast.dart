import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

enum KarritoToastType { success, error, info }

/// Reusable animated floating toast overlay replacing plain SnackBars across
/// Karrito. Features an elastic top entrance (`SlideTransition` +
/// `ScaleTransition` with `Curves.easeOutBack`), a distinct lateral-upward
/// exit (`Curves.easeInCubic`), and a synchronized bottom linear countdown bar.
class KarritoToast {
  KarritoToast._();

  static const Key countdownBarKey = ValueKey<String>(
    'karrito_toast_countdown_bar',
  );

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
    Duration duration = const Duration(milliseconds: 3500),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    showInOverlay(overlay, message: message, type: type, duration: duration);
  }

  static void showInOverlay(
    OverlayState overlay, {
    required String message,
    KarritoToastType type = KarritoToastType.info,
    Duration duration = const Duration(milliseconds: 3500),
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
    with TickerProviderStateMixin {
  late final AnimationController _enterController;
  late final AnimationController _exitController;
  late final AnimationController _countdownController;

  late final Animation<Offset> _enterSlide;
  late final Animation<double> _enterScale;
  late final Animation<double> _enterFade;

  late final Animation<Offset> _exitSlide;
  late final Animation<double> _exitScale;
  late final Animation<double> _exitFade;

  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _countdownController = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: 1.0,
    );

    final enterElastic = CurvedAnimation(
      parent: _enterController,
      curve: Curves.easeOutBack,
    );
    _enterSlide = Tween<Offset>(
      begin: const Offset(0, -0.45),
      end: Offset.zero,
    ).animate(enterElastic);
    _enterScale = Tween<double>(begin: 0.88, end: 1.0).animate(enterElastic);
    _enterFade = CurvedAnimation(
      parent: _enterController,
      curve: const Interval(0.0, 0.72, curve: Curves.easeOut),
    );

    final exitCurved = CurvedAnimation(
      parent: _exitController,
      curve: Curves.easeInCubic,
    );
    _exitSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.18, -0.32),
    ).animate(exitCurved);
    _exitScale = Tween<double>(begin: 1.0, end: 0.88).animate(exitCurved);
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(exitCurved);

    _countdownController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        _dismiss();
      }
    });

    widget.onRegisterDismiss(_dismiss);
    _enterController.forward();
    _countdownController.reverse(from: 1.0);
  }

  @override
  void dispose() {
    _countdownController.dispose();
    _enterController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (_isDismissing) return;
    _isDismissing = true;
    _countdownController.stop();

    if (mounted) {
      final disableAnimations = MediaQuery.disableAnimationsOf(context);
      if (!disableAnimations) {
        try {
          await _exitController.forward();
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
      Color progressColor,
      IconData iconData,
    ) = switch (widget.type) {
      KarritoToastType.success => (
        karritoColors.lime,
        karritoColors.onLime,
        karritoColors.completed.withValues(alpha: 0.55),
        karritoColors.completed,
        Icons.check_circle_rounded,
      ),
      KarritoToastType.error => (
        colorScheme.errorContainer,
        colorScheme.error,
        colorScheme.error.withValues(alpha: 0.55),
        colorScheme.error,
        Icons.error_outline_rounded,
      ),
      KarritoToastType.info => (
        karritoColors.accentContainer,
        karritoColors.accentSoft,
        karritoColors.accent.withValues(alpha: 0.55),
        karritoColors.accent,
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
            _isDismissing = true;
            _countdownController.stop();
            widget.onRemoved();
          },
          child: GestureDetector(
            onTap: _dismiss,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                width: double.infinity,
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
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                      child: Row(
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
                          Expanded(
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
                    AnimatedBuilder(
                      animation: _countdownController,
                      builder: (context, _) {
                        return LinearProgressIndicator(
                          key: KarritoToast.countdownBarKey,
                          value: _countdownController.value.clamp(0.0, 1.0),
                          minHeight: 3.5,
                          backgroundColor: progressColor.withValues(
                            alpha: 0.14,
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progressColor,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final animatedCard = disableAnimations
        ? card
        : FadeTransition(
            opacity: _exitFade,
            child: SlideTransition(
              position: _exitSlide,
              child: ScaleTransition(
                scale: _exitScale,
                child: FadeTransition(
                  opacity: _enterFade,
                  child: SlideTransition(
                    position: _enterSlide,
                    child: ScaleTransition(scale: _enterScale, child: card),
                  ),
                ),
              ),
            ),
          );

    return Positioned(
      top: topPadding + 12,
      left: 16,
      right: 16,
      child: Align(alignment: Alignment.topCenter, child: animatedCard),
    );
  }
}
