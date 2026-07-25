import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tunner/core/theme/app_theme.dart';
import 'package:tunner/core/constants/musical_notes.dart';
import 'package:tunner/features/tuner/presentation/providers/tuner_provider.dart';

class A4SelectorSheet extends ConsumerWidget {
  const A4SelectorSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const A4SelectorSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double current = ref.watch(a4ReferenceProvider);
    final notifier = ref.read(a4ReferenceProvider.notifier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.inactive,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'FRECUENCIA DE REFERENCIA',
            style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'LA (A4)',
            style: TextStyle(
              color: AppColors.onBackground,
              fontSize: 22,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: a4ReferenceOptions.map((freq) {
              final bool selected = (freq - current).abs() < 0.1;
              return GestureDetector(
                onTap: () => notifier.setReference(freq),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : AppColors.inactive,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${freq.toStringAsFixed(0)} Hz',
                    style: TextStyle(
                      color: selected
                          ? AppColors.onPrimary
                          : AppColors.onSurface,
                      fontSize: 14,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Por defecto: 440 Hz',
              style: TextStyle(
                color: AppColors.inactive,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
