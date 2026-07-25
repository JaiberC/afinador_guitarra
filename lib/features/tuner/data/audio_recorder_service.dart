import 'dart:async';
import 'dart:typed_data';
import 'package:record/record.dart';

const int _sampleRate = 44100;
const int _bufferSize = 4096;

class AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _subscription;
  final StreamController<List<int>> _pcmController =
      StreamController<List<int>>.broadcast();

  Stream<List<int>> get pcmStream => _pcmController.stream;

  Future<bool> hasPermission() async {
    return _recorder.hasPermission();
  }

  Future<void> start() async {
    if (await _recorder.isRecording()) return;

    final stream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: _sampleRate,
        numChannels: 1,
        bitRate: _sampleRate * 16,
      ),
    );

    final List<int> buffer = [];
    _subscription = stream.listen((bytes) {
      for (int i = 0; i + 1 < bytes.length; i += 2) {
        final int sample = bytes[i] | (bytes[i + 1] << 8);
        final int signed = sample > 32767 ? sample - 65536 : sample;
        buffer.add(signed);
      }
      while (buffer.length >= _bufferSize) {
        _pcmController.add(List<int>.from(buffer.take(_bufferSize)));
        buffer.removeRange(0, _bufferSize);
      }
    });
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    await _recorder.stop();
  }

  void dispose() {
    stop();
    _pcmController.close();
    _recorder.dispose();
  }
}
