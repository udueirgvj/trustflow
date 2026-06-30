import 'package:flutter/material.dart';

/// شعار TrustFlow: درع بتدرج أخضر/ذهبي مع حرف T، يطابق أيقونة التطبيق.
class TrustFlowLogo extends StatelessWidget {
  final double size;
  const TrustFlowLogo({super.key, this.size = 140});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ShieldPainter(),
      ),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final shieldPath = Path()
      ..moveTo(w * 0.5, h * 0.02)
      ..cubicTo(w * 0.5, h * 0.02, w * 0.85, h * 0.14, w * 0.92, h * 0.18)
      ..cubicTo(w * 0.95, h * 0.20, w * 0.97, h * 0.22, w * 0.97, h * 0.27)
      ..cubicTo(w * 0.97, h * 0.65, w * 0.78, h * 0.90, w * 0.5, h * 0.99)
      ..cubicTo(w * 0.22, h * 0.90, w * 0.03, h * 0.65, w * 0.03, h * 0.27)
      ..cubicTo(w * 0.03, h * 0.22, w * 0.05, h * 0.20, w * 0.08, h * 0.18)
      ..cubicTo(w * 0.15, h * 0.14, w * 0.5, h * 0.02, w * 0.5, h * 0.02)
      ..close();

    final shieldGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF2ECC71),
        Color(0xFF0E7A4B),
        Color(0xFF14532D),
      ],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final shieldPaint = Paint()..shader = shieldGradient;
    canvas.drawPath(shieldPath, shieldPaint);

    // إطار ذهبي خفيف للدرع
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.012
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFE08A), Color(0xFFB8860B)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(shieldPath, borderPaint);

    // حرف T ذهبي بالمنتصف
    final tGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFFE9A8), Color(0xFFC79A2A)],
    ).createShader(Rect.fromLTWH(w * 0.28, h * 0.28, w * 0.44, h * 0.46));
    final tPaint = Paint()..shader = tGradient;

    final barHeight = h * 0.085;
    final topBarRect = Rect.fromLTWH(w * 0.27, h * 0.30, w * 0.46, barHeight);
    canvas.drawRRect(
      RRect.fromRectAndRadius(topBarRect, Radius.circular(barHeight * 0.25)),
      tPaint,
    );

    final stemWidth = w * 0.12;
    final stemRect = Rect.fromLTWH(
      w * 0.5 - stemWidth / 2,
      h * 0.30,
      stemWidth,
      h * 0.42,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(stemRect, Radius.circular(stemWidth * 0.25)),
      tPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}