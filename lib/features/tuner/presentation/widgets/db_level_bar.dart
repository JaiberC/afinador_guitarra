import 'package:flutter/material.dart';
import 'package:tunner/core/theme/app_theme.dart';
import 'package:tunner/core/utils/note_converter.dart';

class DbLevelBar extends StatelessWidget {
  final double db;

  const DbLevelBar({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    final double level = NoteConverter.normalizeDb(db);
    return Container(
      width: 28,
      margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      child: CustomPaint(
        painter: _DbBarPainter(level: level),
      ),
    );
  }
}

class _DbBarPainter extends CustomPainter {
  final double level;

  _DbBarPainter({required this.level});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = AppColors.inactive
      ..style = PaintingStyle.fill;
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(4),
    );
    canvas.drawRRect(bgRect, bgPaint);

    final double filledHeight = size.height * level;
    final double top = size.height - filledHeight;

    final Gradient gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: const [0.0, 0.4, 1.0],
      colors: [AppColors.dbHigh, AppColors.dbMid, AppColors.dbLow],
    );

    final fillPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, top, size.width, filledHeight),
      )
      ..style = PaintingStyle.fill;

    final fillRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, top, size.width, filledHeight),
      const Radius.circular(4),
    );
    canvas.drawRRect(fillRect, fillPaint);

    final tickPaint = Paint()
      ..color = AppColors.background.withValues(alpha: 0.5)
      ..strokeWidth = 1;

    const int ticks = 10;
    for (int i = 1; i < ticks; i++) {
      final double y = size.height * i / ticks;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), tickPaint);
    }
  }

  @override
  bool shouldRepaint(_DbBarPainter old) => old.level != level;
}
