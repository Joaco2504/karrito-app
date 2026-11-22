import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Crisp vector Google "G" emblem for sign-in buttons (no external assets
/// needed and cleanly readable in both light and dark modes).
class GoogleMarkIcon extends StatelessWidget {
  const GoogleMarkIcon({this.size = 20, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _GoogleMarkPainter(),
    );
  }
}

class _GoogleMarkPainter extends CustomPainter {
  const _GoogleMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.19;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: (size.width - stroke) / 2,
    );

    Paint arcPaint(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    // Red top-left arc
    canvas.drawArc(
      rect,
      -math.pi * 0.85,
      math.pi * 0.62,
      false,
      arcPaint(const Color(0xFFEA4335)),
    );
    // Yellow left arc
    canvas.drawArc(
      rect,
      math.pi * 0.72,
      math.pi * 0.43,
      false,
      arcPaint(const Color(0xFFFBBC05)),
    );
    // Green bottom arc
    canvas.drawArc(
      rect,
      math.pi * 0.18,
      math.pi * 0.54,
      false,
      arcPaint(const Color(0xFF34A853)),
    );
    // Blue right arc
    canvas.drawArc(
      rect,
      -math.pi * 0.04,
      math.pi * 0.28,
      false,
      arcPaint(const Color(0xFF4285F4)),
    );
    // Blue horizontal bar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.50,
          size.height * 0.50 - stroke * 0.46,
          size.width * 0.46,
          stroke * 0.92,
        ),
        Radius.circular(stroke * 0.25),
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
