import 'dart:math';
import '../constants/musical_notes.dart';

class NoteInfo {
  final String name;
  final int octave;
  final bool isSharp;
  final double frequency;
  final double cents;
  final int midiNote;

  const NoteInfo({
    required this.name,
    required this.octave,
    required this.isSharp,
    required this.frequency,
    required this.cents,
    required this.midiNote,
  });

  bool get isTuned => cents.abs() <= 3.0;
  bool get isAbove => cents > 0;
  bool get isBelow => cents < 0;

  String get displayName => isSharp ? name.replaceAll('#', '') : name;
  String get sharpSymbol => isSharp ? '#' : '';
}

class NoteConverter {
  static NoteInfo? fromFrequency(double frequency, {double a4Ref = 440.0}) {
    if (frequency <= 0 || frequency < minFrequency || frequency > maxFrequency) {
      return null;
    }

    final double midiFloat = defaultA4MidiNote + 12 * log(frequency / a4Ref) / log(2);
    final int midiNote = midiFloat.round();

    if (midiNote < 0 || midiNote > 127) return null;

    final int noteIndex = midiNote % 12;
    final int octave = (midiNote ~/ 12) - 1;
    final String name = noteNames[noteIndex];
    final bool isSharp = name.contains('#');
    final double cents = (midiFloat - midiNote) * 100;

    return NoteInfo(
      name: name,
      octave: octave,
      isSharp: isSharp,
      frequency: frequency,
      cents: cents,
      midiNote: midiNote,
    );
  }

  static double computeDbFromAmplitude(double amplitude) {
    if (amplitude <= 0) return minDetectableDb;
    final double db = 20 * log(amplitude) / log(10);
    return db.clamp(minDetectableDb, maxDetectableDb);
  }

  static double computeDbFromPcmSamples(List<int> samples) {
    if (samples.isEmpty) return minDetectableDb;

    double sumSquares = 0;
    for (final s in samples) {
      final double normalized = s / 32768.0;
      sumSquares += normalized * normalized;
    }
    final double rms = sqrt(sumSquares / samples.length);
    return computeDbFromAmplitude(rms);
  }

  static double normalizeDb(double db) {
    return ((db - minDetectableDb) / (maxDetectableDb - minDetectableDb)).clamp(0.0, 1.0);
  }
}
