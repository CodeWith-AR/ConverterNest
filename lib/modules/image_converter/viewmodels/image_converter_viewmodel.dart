import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../repositories/image_conversion_repository.dart';
import '../../../data/models/conversion_job.dart';
import '../../../data/repositories/history_repository.dart';
import '../../../core/errors/failure.dart';

enum ImageConverterState { idle, converting, done, error }

class ImageConversionOptions {
  final int quality;
  final int? targetWidth;
  final int? targetHeight;
  final int rotationDegrees;
  final bool flipH;
  final bool flipV;

  const ImageConversionOptions({
    this.quality = 90,
    this.targetWidth,
    this.targetHeight,
    this.rotationDegrees = 0,
    this.flipH = false,
    this.flipV = false,
  });

  ImageConversionOptions copyWith({
    int? quality,
    int? targetWidth,
    int? targetHeight,
    int? rotationDegrees,
    bool? flipH,
    bool? flipV,
  }) =>
      ImageConversionOptions(
        quality: quality ?? this.quality,
        targetWidth: targetWidth ?? this.targetWidth,
        targetHeight: targetHeight ?? this.targetHeight,
        rotationDegrees: rotationDegrees ?? this.rotationDegrees,
        flipH: flipH ?? this.flipH,
        flipV: flipV ?? this.flipV,
      );
}

class ImageConverterViewModel extends ChangeNotifier {
  final ImageConversionRepository _repo;
  final HistoryRepository _history;
  ImageConverterViewModel(this._repo, this._history);

  File? selectedFile;
  String? selectedOutputFormat;
  ImageConverterState state = ImageConverterState.idle;
  File? resultFile;
  Failure? error;
  ImageConversionOptions options = const ImageConversionOptions();
  int _inputSizeBytes = 0;
  int get inputSizeBytes => _inputSizeBytes;
  int lastDurationMs = 0;

  static const supportedFormats = [
    'JPG',
    'PNG',
    'WebP',
    'BMP',
    'GIF',
    'TIFF',
    'TGA'
  ];

  void setFile(File file) {
    selectedFile = file;
    selectedOutputFormat = null;
    resultFile = null;
    error = null;
    state = ImageConverterState.idle;
    _inputSizeBytes = file.lengthSync();
    notifyListeners();
  }

  void setOutputFormat(String format) {
    selectedOutputFormat = format;
    notifyListeners();
  }

  void setOptions(ImageConversionOptions opts) {
    options = opts;
    notifyListeners();
  }

  void updateQuality(int q) {
    options = options.copyWith(quality: q);
    notifyListeners();
  }

  void updateRotation(int deg) {
    options = options.copyWith(rotationDegrees: deg);
    notifyListeners();
  }

  void toggleFlipH() {
    options = options.copyWith(flipH: !options.flipH);
    notifyListeners();
  }

  void toggleFlipV() {
    options = options.copyWith(flipV: !options.flipV);
    notifyListeners();
  }

  void reset() {
    selectedFile = null;
    selectedOutputFormat = null;
    resultFile = null;
    error = null;
    state = ImageConverterState.idle;
    options = const ImageConversionOptions();
    _inputSizeBytes = 0;
    lastDurationMs = 0;
    notifyListeners();
  }

  bool get canConvert => selectedFile != null && selectedOutputFormat != null;

  Future<void> convert() async {
    if (!canConvert) return;
    state = ImageConverterState.converting;
    error = null;
    notifyListeners();

    final sw = Stopwatch()..start();
    try {
      resultFile = await _repo.convert(
        inputFile: selectedFile!,
        outputFormat: selectedOutputFormat!.toLowerCase(),
        quality: options.quality,
        targetWidth: options.targetWidth,
        targetHeight: options.targetHeight,
        rotationDegrees: options.rotationDegrees,
        flipHorizontal: options.flipH,
        flipVertical: options.flipV,
      );
      sw.stop();
      lastDurationMs = sw.elapsedMilliseconds;

      await _history.saveJob(ConversionJob(
        id: const Uuid().v4(),
        inputFormat: selectedFile!.path.split('.').last.toUpperCase(),
        outputFormat: selectedOutputFormat!,
        category: 'image',
        inputFileName: selectedFile!.path.split(Platform.pathSeparator).last,
        outputFilePath: resultFile!.path,
        status: 'completed',
        inputSizeBytes: _inputSizeBytes,
        outputSizeBytes: await resultFile!.length(),
        durationMs: lastDurationMs,
        createdAt: DateTime.now(),
      ));

      state = ImageConverterState.done;
    } catch (e) {
      sw.stop();
      error = UnknownFailure(e.toString());
      state = ImageConverterState.error;
    }
    notifyListeners();
  }
}
