import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
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
  double _velocity = 0;

  static const _spring = SpringDescription(
    mass: 1.0,
    stiffness: 180.0,
    damping: 18.0,
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(TunerNeedle old) {
    super.didUpdateWidget(old);
    final double target = widget.result.hasSignal &&
            widget.result.noteName != '-'
        ? widget.result.cents.clamp(-50.0, 50.0)
        : 0.0;

    _velocity = _controller.isAnimating ? _velocity : 0;

    final sim = SpringSimulation(
      _spring,
      _controller.value,
      target,
      _velocity,
    );
    _controller.animateWith(sim);
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
      height: 110,
      width: double.infinity,
      child: CustomPaint(
        painter: _NeedlePainter(
          cents: _controller.value,
          color: needleColor,
          hasSignal: widget.result.hasSignal && widget.result.noteName != '-',
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

  static const double _maxCents = 50.0;
  static const double _arcSpan = pi * 0.75;
  static const double _arcStart = pi + (pi - _arcSpan) / 2;

  double _centsFraction(double c) =>
      ((c.clamp(-_maxCents, _maxCents) + _maxCents) / (2 * _maxCents));

  double _centsToAngle(double c) => _arcStart + _centsFraction(c) * _arcSpan;

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height + 30;
    final double radius = size.height * 1.55;

    _drawArcZones(canvas, cx, cy, radius);
    _drawArcBase(canvas, cx, cy, radius);
    _drawTicks(canvas, cx, cy, radius);
    _drawLabels(canvas, cx, cy, radius, size);
    _drawNeedle(canvas, cx, cy, radius);
    _drawPivot(canvas, cx, cy);
  }

  void _drawArcZones(Canvas canvas, double cx, double cy, double radius) {
    void drawZone(double fromCents, double toCents, Color zoneColor) {
      final double startAngle = _centsToAngle(fromCents);
      final double sweep = (_centsToAngle(toCents) - startAngle);
      final paint = Paint()
        ..color = zoneColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        startAngle,
        sweep,
        false,
        paint,
      );
    }

    // Zonas: rojo extremo → amarillo → verde centro → amarillo → rojo extremo
    drawZone(-50, -30, AppColors.arcZoneRed);
    drawZone(-30, -10, AppColors.arcZoneYellow);
    drawZone(-10, 10, AppColors.arcZoneGreen);
    drawZone(10, 30, AppColors.arcZoneYellow);
    drawZone(30, 50, AppColors.arcZoneRed);
  }

  void _drawArcBase(Canvas canvas, double cx, double cy, double radius) {
    final paint = Paint()
      ..color = AppColors.inactive
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      _arcStart,
      _arcSpan,
      false,
      paint,
    );
  }

  void _drawTicks(Canvas canvas, double cx, double cy, double radius) {
    const List<double> majorTicks = [-50, -25, 0, 25, 50];
    const List<double> minorTicks = [
      -40, -30, -20, -10, 10, 20, 30, 40
    ];

    final majorPaint = Paint()
      ..color = AppColors.onSurface
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final centerPaint = Paint()
      ..color = AppColors.tuned
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final minorPaint = Paint()
      ..color = AppColors.inactive
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    for (final c in minorTicks) {
      final double angle = _centsToAngle(c);
      final double inner = radius - 6;
      final double outer = radius + 1;
      canvas.drawLine(
        Offset(cx + inner * cos(angle), cy + inner * sin(angle)),
        Offset(cx + outer * cos(angle), cy + outer * sin(angle)),
        minorPaint,
      );
    }

    for (final c in majorTicks) {
      final double angle = _centsToAngle(c);
      final double inner = radius - 12;
      final double outer = radius + 2;
      final bool isCenter = c == 0;
      canvas.drawLine(
        Offset(cx + inner * cos(angle), cy + inner * sin(angle)),
        Offset(cx + outer * cos(angle), cy + outer * sin(angle)),
        isCenter ? centerPaint : majorPaint,
      );
    }
  }

  void _drawLabels(
      Canvas canvas, double cx, double cy, double radius, Size size) {
    const labels = {-50: '-50', -25: '-25', 0: '0', 25: '+25', 50: '+50'};
    for (final entry in labels.entries) {
      final double angle = _centsToAngle(entry.key.toDouble());
      final double labelRadius = radius - 22;
      final double lx = cx + labelRadius * cos(angle);
      final double ly = cy + labelRadius * sin(angle);
      final bool isCenter = entry.key == 0;

      final tp = TextPainter(
        text: TextSpan(
          text: entry.value,
          style: TextStyle(
            color: isCenter
                ? AppColors.tuned
                : AppColors.onSurface.withValues(alpha: 0.6),
            fontSize: isCenter ? 10 : 9,
            fontWeight:
                isCenter ? FontWeight.w600 : FontWeight.w400,
            letterSpacing: 0,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();
      tp.paint(canvas, Offset(lx - tp.width / 2, ly - tp.height / 2));
    }
  }

  void _drawNeedle(Canvas canvas, double cx, double cy, double radius) {
    final double angle = _centsToAngle(cents);
    final double needleLength = radius - 18;
    final Offset tip = Offset(
      cx + needleLength * cos(angle),
      cy + needleLength * sin(angle),
    );

    // Sombra de la aguja
    if (hasSignal) {
      final shadowPaint = Paint()
        ..color = color.withValues(alpha: 0.25)
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawLine(Offset(cx, cy), tip, shadowPaint);
    }

    // Aguja principal
    final needlePaint = Paint()
      ..color = hasSignal ? color : AppColors.inactive
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy), tip, needlePaint);

    // Punta de la aguja (círculo pequeño)
    if (hasSignal) {
      canvas.drawCircle(
        tip,
        3,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
    }
  }

  void _drawPivot(Canvas canvas, double cx, double cy) {
    // Anillo exterior
    canvas.drawCircle(
      Offset(cx, cy),
      8,
      Paint()
        ..color = AppColors.surfaceVariant
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(cx, cy),
      8,
      Paint()
        ..color = hasSignal ? color : AppColors.inactive
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    // Punto interior
    canvas.drawCircle(
      Offset(cx, cy),
      3.5,
      Paint()
        ..color = hasSignal ? color : AppColors.inactive
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_NeedlePainter old) =>
      old.cents != cents || old.color != color || old.hasSignal != hasSignal;
}
