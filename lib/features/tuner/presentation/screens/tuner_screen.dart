import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tunner/core/theme/app_theme.dart';
import 'package:tunner/features/tuner/domain/models/pitch_result.dart';
import 'package:tunner/features/tuner/presentation/providers/tuner_provider.dart';
import 'package:tunner/features/tuner/presentation/widgets/db_level_bar.dart';
import 'package:tunner/features/tuner/presentation/widgets/note_display.dart';
import 'package:tunner/features/tuner/presentation/widgets/tuner_needle.dart';
import 'package:tunner/features/tuner/presentation/widgets/frequency_bar.dart';
import 'package:tunner/features/tuner/presentation/widgets/a4_selector_sheet.dart';

class TunerScreen extends ConsumerStatefulWidget {
  const TunerScreen({super.key});

  @override
  ConsumerState<TunerScreen> createState() => _TunerScreenState();
}

class _TunerScreenState extends ConsumerState<TunerScreen> {
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    try {
      final status = await Permission.microphone.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        setState(() => _permissionDenied = true);
      } else {
        ref.invalidate(tunerProvider);
      }
    } catch (_) {
      // Desktop: permission not required
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_permissionDenied) {
      return _PermissionDeniedView(onRetry: () {
        setState(() => _permissionDenied = false);
        _requestPermission();
      });
    }

    final tunerAsync = ref.watch(tunerProvider);
    final a4Ref = ref.watch(a4ReferenceProvider);

    return tunerAsync.when(
      data: (result) => _buildScaffold(context, result, a4Ref),
      loading: () => _buildScaffold(context, PitchResult.silence, a4Ref),
      error: (err, stack) => _buildScaffold(context, PitchResult.silence, a4Ref),
    );
  }

  Widget _buildScaffold(
      BuildContext context, PitchResult result, double a4Ref) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(
          color: result.isTuned && result.hasSignal
              ? AppColors.tuned.withValues(alpha: 0.35)
              : Colors.transparent,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, a4Ref),
              Expanded(child: _buildTunerLayout(result)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double a4Ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/logo_jaco_dev.png',
                width: 26,
                height: 26,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'TUN',
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 13,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: 'NER',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => A4SelectorSheet.show(context),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.inactive),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'A4 = ${a4Ref.toStringAsFixed(0)} Hz',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.tune,
                    color: AppColors.primary,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTunerLayout(PitchResult result) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DbLevelBar(db: result.db),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 1),
              TunerNeedle(result: result),
              const SizedBox(height: 4),
              NoteDisplay(result: result),
              const SizedBox(height: 8),
              FrequencyBar(result: result),
              const Spacer(flex: 2),
            ],
          ),
        ),
        const SizedBox(width: 44), // balance visual frente al DbLevelBar
      ],
    );
  }
}

class _PermissionDeniedView extends StatelessWidget {
  final VoidCallback onRetry;

  const _PermissionDeniedView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.mic_off_outlined,
                size: 64,
                color: AppColors.inactive,
              ),
              const SizedBox(height: 24),
              const Text(
                'Acceso al micrófono requerido',
                style: TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Tunner necesita el micrófono para detectar el tono del instrumento.',
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () async {
                  await openAppSettings();
                  onRetry();
                },
                icon: const Icon(Icons.settings_outlined),
                label: const Text('Abrir ajustes'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
