import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tunner/core/theme/app_theme.dart';
import 'package:tunner/features/tuner/domain/models/pitch_result.dart';

class TunerNeedle extends StatefulWidget {
  final PitchResult result;

  const TunerNeedle({super.key, required this.result});

  @override
  State<TunerNeedle> createState() => _TunerNeedleState();
}

class _TunerNeedleState extends State<TunerNeedle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _needleAnim;
  double _targetCents = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _needleAnim = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(TunerNeedle old) {
    super.didUpdateWidget(old);
    final double newCents = widget.result.hasSignal ? widget.result.cents : 0;
    if (newCents != _targetCents) {
      _needleAnim = Tween<double>(
        begin: _needleAnim.value,
        end: newCents,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _targetCents = newCents;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color needleColor = _needleColor(widget.result);
    return SizedBox(
      height: 100,
      child: AnimatedBuilder(
        animation: _needleAnim,
        builder: (context, _) => CustomPaint(
          painter: _NeedlePainter(
            cents: _needleAnim.value,
            color: needleColor,
            hasSignal: widget.result.hasSignal,
          ),
          size: Size(MediaQuery.of(context).size.width - 60, 100),
        ),
      ),
    );
  }

  Color _needleColor(PitchResult r) {
    if (!r.hasSignal || r.noteName == '-') return AppColors.inactive;
    if (r.isTuned) return AppColors.tuned;
    if (r.isAbove) return AppColors.sharp;
    return AppColors.flat;
  }
}

class _NeedlePainter extends CustomPainter {
  final double cents;
  final Color color;
  final bool hasSignal;

  _NeedlePainter({
    required this.cents,
    required this.color,
    required this.hasSignal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height + 20;
    final double radius = size.height * 1.6;

    final arcPaint = Paint()
      ..color = AppColors.inactive
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      pi + pi / 6,
      2 * pi * 2 / 3,
      false,
      arcPaint,
    );

    const int ticks = 11;
    final tickPaint = Paint()
      ..color = AppColors.inactive
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final centerTickPaint = Paint()
      ..color = AppColors.tuned.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < ticks; i++) {
      final double frac = i / (ticks - 1);
      final double angle = (pi + pi / 6) + frac * (2 * pi * 2 / 3);
      final bool isCenter = i == ticks ~/ 2;
      final double inner = radius - (isCenter ? 14 : 8);
      final double outer = radius + 1;

      canvas.drawLine(
        Offset(cx + inner * cos(angle), cy + inner * sin(angle)),
        Offset(cx + outer * cos(angle), cy + outer * sin(angle)),
        isCenter ? centerTickPaint : tickPaint,
      );
    }

    const double maxCents = 50.0;
    final double clampedCents = cents.clamp(-maxCents, maxCents);
    final double fraction = (clampedCents + maxCents) / (2 * maxCents);
    final double needleAngle = (pi + pi / 6) + fraction * (2 * pi * 2 / 3);

    final needlePaint = Paint()
      ..color = hasSignal ? color : AppColors.inactive
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final double needleEnd = radius - 10;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + needleEnd * cos(needleAngle), cy + needleEnd * sin(needleAngle)),
      needlePaint,
    );

    final pivotPaint = Paint()
      ..color = hasSignal ? color : AppColors.inactive
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 5, pivotPaint);
  }

  @override
  bool shouldRepaint(_NeedlePainter old) =>
      old.cents != cents || old.color != color || old.hasSignal != hasSignal;
}
