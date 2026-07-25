import 'package:flutter/material.dart';
import 'package:tunner/core/theme/app_theme.dart';
import 'package:tunner/features/tuner/domain/models/pitch_result.dart';

class FrequencyBar extends StatelessWidget {
  final PitchResult result;

  const FrequencyBar({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final bool active = result.hasSignal && result.noteName != '-';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                active ? result.frequency.toStringAsFixed(1) : '--.-',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: active ? AppColors.onBackground : AppColors.inactive,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Hz',
                style: TextStyle(
                  fontSize: 14,
                  color: active ? AppColors.onSurface : AppColors.inactive,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _DeviationIndicator(result: result, active: active),
        ],
      ),
    );
  }
}

class _DeviationIndicator extends StatelessWidget {
  final PitchResult result;
  final bool active;

  const _DeviationIndicator({required this.result, required this.active});

  @override
  Widget build(BuildContext context) {
    if (!active) {
      return Text(
        'esperando señal...',
        style: TextStyle(
          fontSize: 12,
          color: AppColors.inactive,
          letterSpacing: 2,
        ),
      );
    }

    if (result.isTuned) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, color: AppColors.tuned, size: 16),
          const SizedBox(width: 6),
          Text(
            'AFINADO',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.tuned,
              letterSpacing: 3,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    final double absCents = result.cents.abs();
    final bool isAbove = result.isAbove;
    final Color devColor = isAbove ? AppColors.sharp : AppColors.flat;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isAbove ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          color: devColor,
          size: 18,
        ),
        const SizedBox(width: 4),
        Text(
          '${absCents.toStringAsFixed(0)} cents  ${isAbove ? 'por encima' : 'por debajo'}',
          style: TextStyle(
            fontSize: 12,
            color: devColor,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
