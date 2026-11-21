import 'package:flutter/material.dart';

/// Interactive micro-animation wrapper that gently scales down to `0.96`
/// on press and rebounds with an elastic curve, without intercepting taps
/// from child buttons or chips.
class KarritoBounceButton extends StatefulWidget {
  const KarritoBounceButton({
    required this.child,
    this.enabled = true,
    this.pressedScale = 0.96,
    super.key,
  });

  final Widget child;
  final bool enabled;
  final double pressedScale;

  @override
  State<KarritoBounceButton> createState() => _KarritoBounceButtonState();
}

class _KarritoBounceButtonState extends State<KarritoBounceButton> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (!widget.enabled && value) return;
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final targetScale = (_isPressed && widget.enabled && !disableAnimations)
        ? widget.pressedScale
        : 1.0;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: targetScale,
        duration: disableAnimations
            ? Duration.zero
            : Duration(milliseconds: _isPressed ? 90 : 220),
        curve: _isPressed ? Curves.easeOutCubic : Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}
