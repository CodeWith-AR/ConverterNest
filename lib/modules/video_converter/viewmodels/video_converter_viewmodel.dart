import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:battery_plus/battery_plus.dart';
import '../repositories/video_conversion_repository.dart';
import '../../../data/models/conversion_job.dart';
import '../../../data/repositories/history_repository.dart';
import '../../../core/errors/failure.dart';

enum VideoConverterState { idle, converting, done, error }

class VideoConversionOptions {
  final String? resolution;
  final int? fps;
  final int crf;
  final bool extractAudioOnly;
  final bool muteVideo;
  final double? trimStart;
  final double? trimEnd;

  const VideoConversionOptions({
    this.resolution,
    this.fps,
    this.crf = 23,
    this.extractAudioOnly = false,
    this.muteVideo = false,
    this.trimStart,
    this.trimEnd,
  });

  VideoConversionOptions copyWith({
    String? resolution,
    int? fps,
    int? crf,
    bool? extractAudioOnly,
    bool? muteVideo,
    double? trimStart,
    double? trimEnd,
  }) =>
      VideoConversionOptions(
        resolution: resolution ?? this.resolution,
        fps: fps ?? this.fps,
        crf: crf ?? this.crf,
        extractAudioOnly: extractAudioOnly ?? this.extractAudioOnly,
        muteVideo: muteVideo ?? this.muteVideo,
        trimStart: trimStart ?? this.trimStart,
        trimEnd: trimEnd ?? this.trimEnd,
      );
}

class VideoConverterViewModel extends ChangeNotifier {
  final VideoConversionRepository _repo;
  final HistoryRepository _history;
  VideoConverterViewModel(this._repo, this._history);

  File? selectedFile;
  String? selectedOutputFormat;
  VideoConverterState state = VideoConverterState.idle;
  File? resultFile;
  Failure? error;
  VideoConversionOptions options = const VideoConversionOptions();
  double conversionProgress = 0.0;
  bool showBatteryWarning = false;
  bool showLargeFileWarning = false;
  int _inputSizeBytes = 0;
  int get inputSizeBytes => _inputSizeBytes;
  int lastDurationMs = 0;

  static const supportedFormats = [
    'MP4',
    'MKV',
    'AVI',
    'MOV',
    'WebM',
    'FLV',
    '3GP',
    'TS'
  ];

  Future<void> setFile(File file) async {
    selectedFile = file;
    selectedOutputFormat = null;
    resultFile = null;
    error = null;
    state = VideoConverterState.idle;
    _inputSizeBytes = file.lengthSync();
    conversionProgress = 0.0;

    // Check battery
    try {
      final batteryLevel = await Battery().batteryLevel;
      showBatteryWarning = batteryLevel < 20;
    } catch (_) {
      showBatteryWarning = false;
    }

    // Check file size (200 MB threshold default)
    showLargeFileWarning = _inputSizeBytes > 200 * 1024 * 1024;

    notifyListeners();
  }

  void setOutputFormat(String format) {
    selectedOutputFormat = format;
    notifyListeners();
  }

  void updateResolution(String? res) {
    options = options.copyWith(resolution: res);
    notifyListeners();
  }

  void updateFps(int? f) {
    options = options.copyWith(fps: f);
    notifyListeners();
  }

  void updateCrf(int c) {
    options = options.copyWith(crf: c);
    notifyListeners();
  }

  void toggleExtractAudio() {
    options = options.copyWith(extractAudioOnly: !options.extractAudioOnly);
    notifyListeners();
  }

  void toggleMuteVideo() {
    options = options.copyWith(muteVideo: !options.muteVideo);
    notifyListeners();
  }

  void reset() {
    selectedFile = null;
    selectedOutputFormat = null;
    resultFile = null;
    error = null;
    state = VideoConverterState.idle;
    options = const VideoConversionOptions();
    conversionProgress = 0.0;
    _inputSizeBytes = 0;
    lastDurationMs = 0;
    showBatteryWarning = false;
    showLargeFileWarning = false;
    notifyListeners();
  }

  bool get canConvert => selectedFile != null && selectedOutputFormat != null;

  Future<void> convert() async {
    if (!canConvert) return;
    state = VideoConverterState.converting;
    conversionProgress = 0.0;
    error = null;
    notifyListeners();

    final sw = Stopwatch()..start();
    try {
      resultFile = await _repo.convert(
        inputFile: selectedFile!,
        outputFormat: selectedOutputFormat!.toLowerCase(),
        resolution: options.resolution,
        fps: options.fps,
        crf: options.crf,
        extractAudioOnly: options.extractAudioOnly,
        muteVideo: options.muteVideo,
        trimStart: options.trimStart,
        trimEnd: options.trimEnd,
        onProgress: (p) {
          conversionProgress = p;
          notifyListeners();
        },
      );
      sw.stop();
      lastDurationMs = sw.elapsedMilliseconds;

      await _history.saveJob(ConversionJob(
        id: const Uuid().v4(),
        inputFormat: selectedFile!.path.split('.').last.toUpperCase(),
        outputFormat: options.extractAudioOnly ? 'MP3' : selectedOutputFormat!,
        category: 'video',
        inputFileName: selectedFile!.path.split(Platform.pathSeparator).last,
        outputFilePath: resultFile!.path,
        status: 'completed',
        inputSizeBytes: _inputSizeBytes,
        outputSizeBytes: await resultFile!.length(),
        durationMs: lastDurationMs,
        createdAt: DateTime.now(),
      ));

      state = VideoConverterState.done;
    } catch (e) {
      sw.stop();
      error = UnknownFailure(e.toString());
      state = VideoConverterState.error;
    }
    notifyListeners();
  }
}
