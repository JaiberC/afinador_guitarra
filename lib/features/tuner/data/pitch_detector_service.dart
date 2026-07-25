import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:pitch_detector_dart/pitch_detector_result.dart';
import 'package:tunner/features/tuner/domain/models/pitch_result.dart';
import 'package:tunner/core/utils/note_converter.dart';
import 'package:tunner/core/constants/musical_notes.dart';

const int _sampleRate = 44100;
const double _silenceThreshold = -45.0;

class PitchDetectorService {
  final PitchDetector _detector = PitchDetector(
    audioSampleRate: _sampleRate.toDouble(),
    bufferSize: 4096,
  );

  Future<PitchResult> process(
    List<int> samples, {
    double a4Ref = defaultA4Reference,
  }) async {
    final double db = NoteConverter.computeDbFromPcmSamples(samples);

    if (db < _silenceThreshold) {
      return PitchResult.silence;
    }

    final List<double> floatSamples =
        samples.map((s) => s / 32768.0).toList();

    PitchDetectorResult result;
    try {
      result = await _detector.getPitchFromFloatBuffer(floatSamples);
    } catch (_) {
      return PitchResult(
        frequency: 0,
        noteName: '-',
        octave: 0,
        isSharp: false,
        cents: 0,
        db: db,
        hasSignal: true,
      );
    }

    if (!result.pitched || result.pitch <= 0) {
      return PitchResult(
        frequency: 0,
        noteName: '-',
        octave: 0,
        isSharp: false,
        cents: 0,
        db: db,
        hasSignal: true,
      );
    }

    final NoteInfo? noteInfo = NoteConverter.fromFrequency(
      result.pitch,
      a4Ref: a4Ref,
    );

    if (noteInfo == null) {
      return PitchResult(
        frequency: result.pitch,
        noteName: '-',
        octave: 0,
        isSharp: false,
        cents: 0,
        db: db,
        hasSignal: true,
      );
    }

    return PitchResult(
      frequency: result.pitch,
      noteName: noteInfo.displayName,
      octave: noteInfo.octave,
      isSharp: noteInfo.isSharp,
      cents: noteInfo.cents,
      db: db,
      hasSignal: true,
    );
  }
}
