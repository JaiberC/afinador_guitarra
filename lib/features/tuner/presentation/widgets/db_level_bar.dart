import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tunner/core/theme/app_theme.dart';
import 'package:tunner/core/utils/note_converter.dart';

class DbLevelBar extends StatefulWidget {
  final double db;

  const DbLevelBar({super.key, required this.db});

  @override
  State<DbLevelBar> createState() => _DbLevelBarState();
}

class _DbLevelBarState extends State<DbLevelBar> {
  double _peakLevel = 0.0;
  Timer? _peakTimer;

  @override
  void didUpdateWidget(DbLevelBar old) {
    super.didUpdateWidget(old);
    final double level = NoteConverter.normalizeDb(widget.db);
    if (level > _peakLevel) {
      _peakLevel = level;
      _peakTimer?.cancel();
      _peakTimer = Timer(const Duration(seconds: 2), () {
        setState(() {
          _peakLevel = NoteConverter.normalizeDb(widget.db);
        });
      });
    }
  }

  @override
  void dispose() {
    _peakTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double level = NoteConverter.normalizeDb(widget.db);
    return SizedBox(
      width: 44,
      child: Column(
        children: [
          // Etiqueta top
          const Padding(
            padding: EdgeInsets.only(top: 16, bottom: 4),
            child: Text(
              '0',
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 8,
                letterSpacing: 0,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CustomPaint(
                painter: _VuMeterPainter(
                  level: level,
                  peakLevel: _peakLevel,
                ),
                size: Size.infinite,
              ),
            ),
          ),
          // Etiqueta bottom
          const Padding(
            padding: EdgeInsets.only(top: 4, bottom: 16),
            child: Text(
              '-60',
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 8,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VuMeterPainter extends CustomPainter {
  final double level;
  final double peakLevel;

  static const int _segments = 22;
  static const double _gapRatio = 0.15;

  _VuMeterPainter({required this.level, required this.peakLevel});

  @override
  void paint(Canvas canvas, Size size) {
    final double segH =
        (size.height - (_segments - 1) * size.height * _gapRatio / _segments) /
            _segments;
    final double gapH = size.height * _gapRatio / _segments;
    final double totalStep = segH + gapH;

    final int filledCount = (level * _segments).round();
    final int peakSegment =
        (peakLevel * _segments).clamp(0, _segments - 1).round();

    for (int i = 0; i < _segments; i++) {
      // i=0 is bottom, i=segments-1 is top
      final double top = size.height - (i + 1) * totalStep + gapH / 2;
      final Rect rect = Rect.fromLTWH(0, top, size.width, segH);
      final RRect rRect = RRect.fromRectAndRadius(rect, const Radius.circular(2));

      final bool isActive = i < filledCount;
      final bool isPeak = i == peakSegment && peakLevel > 0.05;

      Color segColor;
      if (isPeak) {
        segColor = AppColors.dbPeak;
      } else if (isActive) {
        // Color por zona: verde bajo, amarillo medio, rojo alto
        final double frac = i / _segments;
        if (frac < 0.5) {
          segColor = AppColors.dbLow;
        } else if (frac < 0.75) {
          segColor = AppColors.dbMid;
        } else {
          segColor = AppColors.dbHigh;
        }
      } else {
        segColor = AppColors.inactive;
      }

      canvas.drawRRect(rRect, Paint()..color = segColor);
    }

    // Líneas de referencia -20dB y -40dB
    _drawRefLine(canvas, size, 0.33, '-40');
    _drawRefLine(canvas, size, 0.67, '-20');
  }

  void _drawRefLine(Canvas canvas, Size size, double frac, String label) {
    final double y = size.height - frac * size.height;
    canvas.drawLine(
      Offset(-4, y),
      Offset(size.width + 4, y),
      Paint()
        ..color = AppColors.inactive.withValues(alpha: 0.5)
        ..strokeWidth = 0.5,
    );
  }

  @override
  bool shouldRepaint(_VuMeterPainter old) =>
      old.level != level || old.peakLevel != peakLevel;
}
