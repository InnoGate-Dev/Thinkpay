import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';

class ArcProgressRing extends StatelessWidget {
  const ArcProgressRing({super.key, required this.pct, this.size = 80, this.label = 'paid'});
  final double pct;
  final double size;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: pct),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, value, _) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _ArcPainter(
            pct: value,
            trackColor: tc.text10,
            progressColor: tc.coreAction,
            strokeWidth: 6,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(value * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.manrope(color: tc.text100, fontSize: 14, fontWeight: FontWeight.w800),
                ),
                Text(label, style: GoogleFonts.inter(color: tc.text40, fontSize: 9)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter({
    required this.pct,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });
  final double pct;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      2 * math.pi * pct,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.pct != pct || old.progressColor != progressColor;
}
