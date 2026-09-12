import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../repositories/audio_conversion_repository.dart';
import '../../../data/models/conversion_job.dart';
import '../../../data/repositories/history_repository.dart';
import '../../../core/errors/failure.dart';

enum AudioConverterState { idle, converting, done, error }

class AudioConversionOptions {
  final String bitrate;
  final int sampleRate;
  final int channels;
  final double? trimStart;
  final double? trimEnd;
  final double volume;

  const AudioConversionOptions({
    this.bitrate = '128k',
    this.sampleRate = 44100,
    this.channels = 2,
    this.trimStart,
    this.trimEnd,
    this.volume = 1.0,
  });

  AudioConversionOptions copyWith({
    String? bitrate,
    int? sampleRate,
    int? channels,
    double? trimStart,
    double? trimEnd,
    double? volume,
  }) =>
      AudioConversionOptions(
        bitrate: bitrate ?? this.bitrate,
        sampleRate: sampleRate ?? this.sampleRate,
        channels: channels ?? this.channels,
        trimStart: trimStart ?? this.trimStart,
        trimEnd: trimEnd ?? this.trimEnd,
        volume: volume ?? this.volume,
      );
}

class AudioConverterViewModel extends ChangeNotifier {
  final AudioConversionRepository _repo;
  final HistoryRepository _history;
  AudioConverterViewModel(this._repo, this._history);

  File? selectedFile;
  String? selectedOutputFormat;
  AudioConverterState state = AudioConverterState.idle;
  File? resultFile;
  Failure? error;
  AudioConversionOptions options = const AudioConversionOptions();
  int _inputSizeBytes = 0;
  int get inputSizeBytes => _inputSizeBytes;
  int lastDurationMs = 0;

  static const supportedFormats = [
    'MP3',
    'AAC',
    'WAV',
    'FLAC',
    'OGG',
    'OPUS',
    'M4A',
    'AMR',
    'AIFF'
  ];

  void setFile(File file) {
    selectedFile = file;
    selectedOutputFormat = null;
    resultFile = null;
    error = null;
    state = AudioConverterState.idle;
    _inputSizeBytes = file.lengthSync();
    notifyListeners();
  }

  void setOutputFormat(String format) {
    selectedOutputFormat = format;
    notifyListeners();
  }

  void updateBitrate(String br) {
    options = options.copyWith(bitrate: br);
    notifyListeners();
  }

  void updateSampleRate(int sr) {
    options = options.copyWith(sampleRate: sr);
    notifyListeners();
  }

  void updateChannels(int ch) {
    options = options.copyWith(channels: ch);
    notifyListeners();
  }

  void updateVolume(double vol) {
    options = options.copyWith(volume: vol);
    notifyListeners();
  }

  void reset() {
    selectedFile = null;
    selectedOutputFormat = null;
    resultFile = null;
    error = null;
    state = AudioConverterState.idle;
    options = const AudioConversionOptions();
    _inputSizeBytes = 0;
    lastDurationMs = 0;
    notifyListeners();
  }

  bool get canConvert => selectedFile != null && selectedOutputFormat != null;

  Future<void> convert() async {
    if (!canConvert) return;
    state = AudioConverterState.converting;
    error = null;
    notifyListeners();

    final sw = Stopwatch()..start();
    try {
      resultFile = await _repo.convert(
        inputFile: selectedFile!,
        outputFormat: selectedOutputFormat!.toLowerCase(),
        bitrate: options.bitrate,
        sampleRate: options.sampleRate,
        channels: options.channels,
        trimStart: options.trimStart,
        trimEnd: options.trimEnd,
        volume: options.volume,
      );
      sw.stop();
      lastDurationMs = sw.elapsedMilliseconds;

      await _history.saveJob(ConversionJob(
        id: const Uuid().v4(),
        inputFormat: selectedFile!.path.split('.').last.toUpperCase(),
        outputFormat: selectedOutputFormat!,
        category: 'audio',
        inputFileName: selectedFile!.path.split(Platform.pathSeparator).last,
        outputFilePath: resultFile!.path,
        status: 'completed',
        inputSizeBytes: _inputSizeBytes,
        outputSizeBytes: await resultFile!.length(),
        durationMs: lastDurationMs,
        createdAt: DateTime.now(),
      ));

      state = AudioConverterState.done;
    } catch (e) {
      sw.stop();
      error = UnknownFailure(e.toString());
      state = AudioConverterState.error;
    }
    notifyListeners();
  }
}
