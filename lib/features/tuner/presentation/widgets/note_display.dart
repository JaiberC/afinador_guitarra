import 'package:flutter/material.dart';
import 'package:tunner/core/theme/app_theme.dart';
import 'package:tunner/features/tuner/domain/models/pitch_result.dart';

class NoteDisplay extends StatelessWidget {
  final PitchResult result;

  const NoteDisplay({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final Color noteColor = _noteColor(result);

    return SizedBox(
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (result.hasSignal && result.noteName != '-')
            Positioned(
              top: 16,
              right: 12,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w300,
                  color: result.isSharp ? AppColors.sharp : Colors.transparent,
                  height: 1,
                ),
                child: Text(result.isSharp ? '#' : ' '),
              ),
            ),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 150),
            style: TextStyle(
              fontSize: 120,
              fontWeight: FontWeight.w200,
              color: noteColor,
              height: 1,
              letterSpacing: -4,
            ),
            child: Text(
              result.hasSignal && result.noteName != '-'
                  ? result.noteName
                  : '-',
            ),
          ),
          if (result.hasSignal && result.noteName != '-')
            Positioned(
              bottom: 8,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: noteColor.withValues(alpha: 0.7),
                  letterSpacing: 3,
                ),
                child: Text(result.octave.toString()),
              ),
            ),
        ],
      ),
    );
  }

  Color _noteColor(PitchResult r) {
    if (!r.hasSignal || r.noteName == '-') return AppColors.inactive;
    if (r.isTuned) return AppColors.tuned;
    if (r.isAbove) return AppColors.sharp;
    return AppColors.flat;
  }
}
