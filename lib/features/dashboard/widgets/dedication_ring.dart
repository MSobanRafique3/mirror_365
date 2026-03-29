import 'package:flutter/material.dart';
import 'dart:math';
import '../../../core/constants/app_constants.dart';

class DedicationRing extends StatelessWidget {
  final double dailyScore;
  final double monthlyScore;
  final double yearlyScore;
  final double strokeWidth;

  const DedicationRing({
    super.key,
    required this.dailyScore,
    required this.monthlyScore,
    required this.yearlyScore,
    this.strokeWidth = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: CustomPaint(
        painter: _DedicationPainter(
          dailyScore: dailyScore,
          monthlyScore: monthlyScore,
          yearlyScore: yearlyScore,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _DedicationPainter extends CustomPainter {
  final double dailyScore;
  final double monthlyScore;
  final double yearlyScore;
  final double strokeWidth;

  _DedicationPainter({
    required this.dailyScore,
    required this.monthlyScore,
    required this.yearlyScore,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 - strokeWidth / 2;
    
    // Rings from outer to inner
    _drawArc(canvas, center, maxRadius, dailyScore);
    _drawArc(canvas, center, maxRadius - (strokeWidth * 1.5), monthlyScore);
    _drawArc(canvas, center, maxRadius - (strokeWidth * 3.0), yearlyScore);
  }

  void _drawArc(Canvas canvas, Offset center, double radius, double score) {
    if (radius <= 0) return;

    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -pi / 2; // Start from top
    final sweepAngle = 2 * pi * score.clamp(0.0, 1.0);

    // Background Arc (unfilled)
    final bgPaint = Paint()
      ..color = AppColors.surfaceVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * pi, false, bgPaint);

    // Filled Arc
    if (score > 0) {
      final fgPaint = Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, sweepAngle, false, fgPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DedicationPainter oldDelegate) {
    return oldDelegate.dailyScore != dailyScore ||
           oldDelegate.monthlyScore != monthlyScore ||
           oldDelegate.yearlyScore != yearlyScore ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}
