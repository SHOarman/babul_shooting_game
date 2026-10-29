import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// ==================== SOUND SERVICE ====================
class SoundService {
  static final AudioPlayer _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  static final RxBool isSoundEnabled = true.obs;

  static Uint8List? _popWav;
  static Uint8List? _comboWav;
  static Uint8List? _megaComboWav;
  static Uint8List? _bounceWav;
  static Uint8List? _winWav;
  static Uint8List? _loseWav;

  static void init() {
    _popWav = _generatePopSound();
    _comboWav = _generateComboSound();
    _megaComboWav = _generateMegaComboSound();
    _bounceWav = _generateBounceSound();
    _winWav = _generateWinSound();
    _loseWav = _generateLoseSound();
  }

  // ==================== PLAYBACK METHODS ====================
  static Future<void> playPop() async {
    if (!isSoundEnabled.value) return;
    try {
      HapticFeedback.lightImpact();
      _popWav ??= _generatePopSound();
      await _player.play(BytesSource(_popWav!));
    } catch (_) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  static Future<void> playCombo() async {
    if (!isSoundEnabled.value) return;
    try {
      HapticFeedback.mediumImpact();
      _comboWav ??= _generateComboSound();
      await _player.play(BytesSource(_comboWav!));
    } catch (_) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  static Future<void> playMegaCombo() async {
    if (!isSoundEnabled.value) return;
    try {
      HapticFeedback.heavyImpact();
      _megaComboWav ??= _generateMegaComboSound();
      await _player.play(BytesSource(_megaComboWav!));
    } catch (_) {
      SystemSound.play(SystemSoundType.alert);
    }
  }

  static Future<void> playBounce() async {
    if (!isSoundEnabled.value) return;
    try {
      HapticFeedback.selectionClick();
      _bounceWav ??= _generateBounceSound();
      await _player.play(BytesSource(_bounceWav!));
    } catch (_) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  static Future<void> playWin() async {
    if (!isSoundEnabled.value) return;
    try {
      HapticFeedback.heavyImpact();
      _winWav ??= _generateWinSound();
      await _player.play(BytesSource(_winWav!));
    } catch (_) {
      SystemSound.play(SystemSoundType.alert);
    }
  }

  static Future<void> playLose() async {
    if (!isSoundEnabled.value) return;
    try {
      HapticFeedback.vibrate();
      _loseWav ??= _generateLoseSound();
      await _player.play(BytesSource(_loseWav!));
    } catch (_) {}
  }

  // ==================== WAV GENERATION ====================
  static Uint8List _generatePopSound() {
    const int sampleRate = 22050;
    const double duration = 0.08;
    final int totalSamples = (sampleRate * duration).round();
    final ByteData pcm = ByteData(totalSamples * 2);

    double phase = 0;
    for (int i = 0; i < totalSamples; i++) {
      final double t = i / totalSamples;
      final double freq = 420.0 + (500.0 * t);
      final double decay = exp(-6.5 * t);
      phase += 2 * pi * freq / sampleRate;
      final double sample = sin(phase) * decay;
      final int value = (sample * 24000).clamp(-32768, 32767).toInt();
      pcm.setInt16(i * 2, value, Endian.little);
    }

    final header = _buildWavHeader(pcm.lengthInBytes, sampleRate);
    final bb = BytesBuilder()
      ..add(header)
      ..add(pcm.buffer.asUint8List());
    return bb.toBytes();
  }

  static Uint8List _generateComboSound() {
    const int sampleRate = 22050;
    const double duration = 0.22;
    final int totalSamples = (sampleRate * duration).round();
    final ByteData pcm = ByteData(totalSamples * 2);

    double phase1 = 0, phase2 = 0, phase3 = 0;
    for (int i = 0; i < totalSamples; i++) {
      final double t = i / totalSamples;
      final double decay = exp(-4.5 * t);
      phase1 += 2 * pi * 1046.5 / sampleRate;
      phase2 += 2 * pi * 1318.5 / sampleRate;
      phase3 += 2 * pi * 1567.9 / sampleRate;
      final double sample = (sin(phase1) + sin(phase2) + sin(phase3)) / 3.0 * decay;
      final int value = (sample * 22000).clamp(-32768, 32767).toInt();
      pcm.setInt16(i * 2, value, Endian.little);
    }

    final header = _buildWavHeader(pcm.lengthInBytes, sampleRate);
    final bb = BytesBuilder()
      ..add(header)
      ..add(pcm.buffer.asUint8List());
    return bb.toBytes();
  }

  static Uint8List _generateMegaComboSound() {
    const int sampleRate = 22050;
    const double duration = 0.38;
    final int totalSamples = (sampleRate * duration).round();
    final ByteData pcm = ByteData(totalSamples * 2);

    final List<double> notes = [523.25, 659.25, 783.99, 987.77, 1046.50];
    double p1 = 0, p2 = 0;

    for (int i = 0; i < totalSamples; i++) {
      final double t = i / totalSamples;
      final int noteIdx = (t * 5).floor().clamp(0, 4);
      final double noteFreq = notes[noteIdx];
      final double localT = (t * 5) - noteIdx;
      final double decay = exp(-3.0 * localT);

      p1 += 2 * pi * noteFreq / sampleRate;
      p2 += 2 * pi * (noteFreq * 2) / sampleRate;
      final double sample = (sin(p1) * 0.75 + sin(p2) * 0.25) * decay;
      final int value = (sample * 25000).clamp(-32768, 32767).toInt();
      pcm.setInt16(i * 2, value, Endian.little);
    }

    final header = _buildWavHeader(pcm.lengthInBytes, sampleRate);
    final bb = BytesBuilder()
      ..add(header)
      ..add(pcm.buffer.asUint8List());
    return bb.toBytes();
  }

  static Uint8List _generateBounceSound() {
    const int sampleRate = 22050;
    const double duration = 0.04;
    final int totalSamples = (sampleRate * duration).round();
    final ByteData pcm = ByteData(totalSamples * 2);

    double phase = 0;
    for (int i = 0; i < totalSamples; i++) {
      final double t = i / totalSamples;
      final double decay = exp(-12.0 * t);
      phase += 2 * pi * 240.0 / sampleRate;
      final double sample = sin(phase) * decay;
      final int value = (sample * 20000).clamp(-32768, 32767).toInt();
      pcm.setInt16(i * 2, value, Endian.little);
    }

    final header = _buildWavHeader(pcm.lengthInBytes, sampleRate);
    final bb = BytesBuilder()
      ..add(header)
      ..add(pcm.buffer.asUint8List());
    return bb.toBytes();
  }

  static Uint8List _generateWinSound() {
    const int sampleRate = 22050;
    const double duration = 0.45;
    final int totalSamples = (sampleRate * duration).round();
    final ByteData pcm = ByteData(totalSamples * 2);

    final List<double> notes = [523.25, 659.25, 783.99, 1046.50];
    double phase = 0;

    for (int i = 0; i < totalSamples; i++) {
      final double t = i / totalSamples;
      final int noteIndex = (t * 4).floor().clamp(0, 3);
      final double freq = notes[noteIndex];
      final double noteT = (t * 4) - noteIndex;
      final double decay = exp(-2.5 * noteT);
      phase += 2 * pi * freq / sampleRate;
      final double sample = sin(phase) * decay;
      final int value = (sample * 22000).clamp(-32768, 32767).toInt();
      pcm.setInt16(i * 2, value, Endian.little);
    }

    final header = _buildWavHeader(pcm.lengthInBytes, sampleRate);
    final bb = BytesBuilder()
      ..add(header)
      ..add(pcm.buffer.asUint8List());
    return bb.toBytes();
  }

  static Uint8List _generateLoseSound() {
    const int sampleRate = 22050;
    const double duration = 0.35;
    final int totalSamples = (sampleRate * duration).round();
    final ByteData pcm = ByteData(totalSamples * 2);

    double phase = 0;
    for (int i = 0; i < totalSamples; i++) {
      final double t = i / totalSamples;
      final double freq = 380.0 - (180.0 * t);
      final double decay = exp(-3.0 * t);
      phase += 2 * pi * freq / sampleRate;
      final double sample = sin(phase) * decay;
      final int value = (sample * 20000).clamp(-32768, 32767).toInt();
      pcm.setInt16(i * 2, value, Endian.little);
    }

    final header = _buildWavHeader(pcm.lengthInBytes, sampleRate);
    final bb = BytesBuilder()
      ..add(header)
      ..add(pcm.buffer.asUint8List());
    return bb.toBytes();
  }

  // ==================== WAV HEADER BUILDER ====================
  static Uint8List _buildWavHeader(int dataLength, int sampleRate) {
    final bb = BytesBuilder();
    bb.add('RIFF'.codeUnits);
    final ByteData sizeData = ByteData(4)..setInt32(0, 36 + dataLength, Endian.little);
    bb.add(sizeData.buffer.asUint8List());
    bb.add('WAVE'.codeUnits);
    bb.add('fmt '.codeUnits);
    final ByteData subchunk1Size = ByteData(4)..setInt32(0, 16, Endian.little);
    bb.add(subchunk1Size.buffer.asUint8List());
    final ByteData audioFormat = ByteData(2)..setInt16(0, 1, Endian.little);
    bb.add(audioFormat.buffer.asUint8List());
    final ByteData numChannels = ByteData(2)..setInt16(0, 1, Endian.little);
    bb.add(numChannels.buffer.asUint8List());
    final ByteData srData = ByteData(4)..setInt32(0, sampleRate, Endian.little);
    bb.add(srData.buffer.asUint8List());
    final ByteData byteRate = ByteData(4)..setInt32(0, sampleRate * 1 * 2, Endian.little);
    bb.add(byteRate.buffer.asUint8List());
    final ByteData blockAlign = ByteData(2)..setInt16(0, 2, Endian.little);
    bb.add(blockAlign.buffer.asUint8List());
    final ByteData bitsPerSample = ByteData(2)..setInt16(0, 16, Endian.little);
    bb.add(bitsPerSample.buffer.asUint8List());
    bb.add('data'.codeUnits);
    final ByteData dataLengthData = ByteData(4)..setInt32(0, dataLength, Endian.little);
    bb.add(dataLengthData.buffer.asUint8List());

    return bb.toBytes();
  }
}
