class PitchResult {
  final double frequency;
  final String noteName;
  final int octave;
  final bool isSharp;
  final double cents;
  final double db;
  final bool hasSignal;

  const PitchResult({
    required this.frequency,
    required this.noteName,
    required this.octave,
    required this.isSharp,
    required this.cents,
    required this.db,
    required this.hasSignal,
  });

  bool get isTuned => cents.abs() <= 3.0;
  bool get isAbove => cents > 0;

  static const PitchResult silence = PitchResult(
    frequency: 0,
    noteName: '-',
    octave: 0,
    isSharp: false,
    cents: 0,
    db: -60,
    hasSignal: false,
  );
}
