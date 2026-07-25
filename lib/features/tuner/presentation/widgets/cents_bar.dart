import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:tunner/core/theme/app_theme.dart';
import 'package:tunner/core/constants/musical_notes.dart';
import 'package:tunner/features/tuner/domain/models/pitch_result.dart';

class CentsBar extends StatefulWidget {
  final PitchResult result;

  const CentsBar({super.key, required this.result});

  @override
  State<CentsBar> createState() => _CentsBarState();
}

class _CentsBarState extends State<CentsBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const _spring = SpringDescription(
    mass: 1.0,
    stiffness: 200.0,
    damping: 20.0,
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(CentsBar old) {
    super.didUpdateWidget(old);
    final double target = widget.result.hasSignal &&
            widget.result.noteName != '-'
        ? widget.result.cents.clamp(-50.0, 50.0)
        : 0.0;

    final sim = SpringSimulation(_spring, _controller.value, target, 0);
    _controller.animateWith(sim);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool active =
        widget.result.hasSignal && widget.result.noteName != '-';
    final Color dotColor = _dotColor(widget.result);

    final String prevNote = _adjacentNote(widget.result.noteName, -1);
    final String nextNote = _adjacentNote(widget.result.noteName, 1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        children: [
          // Notas adyacentes + barra
          Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  active ? prevNote : '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.flat.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 20,
                  child: CustomPaint(
                    painter: _CentsBarPainter(
                      cents: active ? _controller.value : 0,
                      dotColor: dotColor,
                      active: active,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 28,
                child: Text(
                  active ? nextNote : '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.sharp.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          // Etiquetas cents
          Padding(
            padding: const EdgeInsets.only(left: 28, right: 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['-50', '-25', '0', '+25', '+50']
                  .map(
                    (l) => Text(
                      l,
                      style: TextStyle(
                        color: l == '0'
                            ? AppColors.tuned.withValues(alpha: 0.7)
                            : AppColors.inactive,
                        fontSize: 8,
                        letterSpacing: 0,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _dotColor(PitchResult r) {
    if (!r.hasSignal || r.noteName == '-') return AppColors.inactive;
    if (r.isTuned) return AppColors.tuned;
    if (r.isAbove) return AppColors.sharp;
    return AppColors.flat;
  }

  String _adjacentNote(String noteName, int offset) {
    if (noteName == '-') return '';
    final String base = noteName.replaceAll('#', '');
    final int idx = noteNames.indexOf(base.length == 1 && noteNames.contains(noteName)
        ? noteName
        : base);
    if (idx < 0) return '';
    final int adjIdx = (idx + offset + noteNames.length) % noteNames.length;
    return noteNames[adjIdx];
  }
}

class _CentsBarPainter extends CustomPainter {
  final double cents;
  final Color dotColor;
  final bool active;

  static const double _maxCents = 50.0;

  _CentsBarPainter({
    required this.cents,
    required this.dotColor,
    required this.active,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;

    // Línea de fondo
    final bgPaint = Paint()
      ..color = AppColors.inactive
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, cy), Offset(size.width, cy), bgPaint);

    // Zona verde central (±5 cents → ±5% del ancho)
    final double greenHalfWidth = size.width * 5 / (2 * _maxCents);
    final greenPaint = Paint()
      ..color = AppColors.arcZoneGreen
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx - greenHalfWidth, cy),
      Offset(cx + greenHalfWidth, cy),
      greenPaint,
    );

    // Marca central
    canvas.drawLine(
      Offset(cx, cy - 5),
      Offset(cx, cy + 5),
      Paint()
        ..color = AppColors.tuned.withValues(alpha: 0.5)
        ..strokeWidth = 1.5,
    );

    if (!active) return;

    // Dot animado
    final double fraction = (cents.clamp(-_maxCents, _maxCents) + _maxCents) /
        (2 * _maxCents);
    final double dotX = fraction * size.width;

    // Sombra del dot
    canvas.drawCircle(
      Offset(dotX, cy),
      7,
      Paint()
        ..color = dotColor.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Dot principal
    canvas.drawCircle(
      Offset(dotX, cy),
      5,
      Paint()
        ..color = dotColor
        ..style = PaintingStyle.fill,
    );

    // Anillo exterior del dot
    canvas.drawCircle(
      Offset(dotX, cy),
      5,
      Paint()
        ..color = dotColor.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_CentsBarPainter old) =>
      old.cents != cents || old.dotColor != dotColor || old.active != active;
}
