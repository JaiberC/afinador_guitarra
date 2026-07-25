import 'package:flutter/material.dart';
import 'package:tunner/core/theme/app_theme.dart';
import 'package:tunner/features/tuner/domain/models/pitch_result.dart';
import 'package:tunner/features/tuner/presentation/widgets/cents_bar.dart';

class FrequencyBar extends StatelessWidget {
  final PitchResult result;

  const FrequencyBar({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final bool active = result.hasSignal && result.noteName != '-';
    final Color freqColor = _freqColor(result);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Hz display
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w300,
                color: active ? freqColor : AppColors.inactive,
                letterSpacing: -0.5,
              ),
              child: Text(
                active ? result.frequency.toStringAsFixed(1) : '--.-',
              ),
            ),
            const SizedBox(width: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 13,
                color: active ? AppColors.onSurface : AppColors.inactive,
                letterSpacing: 2,
              ),
              child: const Text('Hz'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Barra de cents
        CentsBar(result: result),
      ],
    );
  }

  Color _freqColor(PitchResult r) {
    if (!r.hasSignal || r.noteName == '-') return AppColors.inactive;
    if (r.isTuned) return AppColors.tuned;
    if (r.isAbove) return AppColors.sharp;
    return AppColors.flat;
  }
}
