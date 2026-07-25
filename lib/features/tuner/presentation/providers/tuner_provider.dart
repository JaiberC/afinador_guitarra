import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tunner/features/tuner/data/audio_recorder_service.dart';
import 'package:tunner/features/tuner/data/pitch_detector_service.dart';
import 'package:tunner/features/tuner/domain/models/pitch_result.dart';
import 'package:tunner/core/constants/musical_notes.dart';

const String _a4RefKey = 'a4_reference';

final a4ReferenceProvider = StateNotifierProvider<A4ReferenceNotifier, double>(
  (ref) => A4ReferenceNotifier(),
);

class A4ReferenceNotifier extends StateNotifier<double> {
  A4ReferenceNotifier() : super(defaultA4Reference) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getDouble(_a4RefKey) ?? defaultA4Reference;
  }

  Future<void> setReference(double value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_a4RefKey, value);
  }
}

final tunerProvider = StreamProvider<PitchResult>((ref) async* {
  final double a4Ref = ref.watch(a4ReferenceProvider);
  final audioService = AudioRecorderService();
  final detectorService = PitchDetectorService();

  ref.onDispose(() {
    audioService.dispose();
  });

  bool hasPerm;
  try {
    hasPerm = await audioService.hasPermission();
  } catch (_) {
    hasPerm = true;
  }
  if (!hasPerm) {
    yield PitchResult.silence;
    return;
  }

  try {
    await audioService.start();
  } catch (_) {
    yield PitchResult.silence;
    return;
  }

  await for (final samples in audioService.pcmStream) {
    final result = await detectorService.process(samples, a4Ref: a4Ref);
    yield result;
  }
});
