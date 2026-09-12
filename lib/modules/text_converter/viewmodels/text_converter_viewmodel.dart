import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../repositories/text_conversion_repository.dart';
import '../../../data/models/conversion_job.dart';
import '../../../data/repositories/history_repository.dart';
import '../../../core/errors/failure.dart';

enum TextConverterState { idle, converting, done, error }

class TextConverterViewModel extends ChangeNotifier {
  final TextConversionRepository _repo;
  final HistoryRepository _history;
  TextConverterViewModel(this._repo, this._history);

  TextConverterState state = TextConverterState.idle;
  Failure? error;

  File? selectedFile;
  String? selectedInputFormat;
  String? selectedOutputFormat;
  File? resultFile;
  int _inputSizeBytes = 0;
  int get inputSizeBytes => _inputSizeBytes;
  int lastDurationMs = 0;

  bool isPasteMode = false;
  String pastedText = '';
  String preview = '';

  static const inputFormats = ['TXT', 'MD', 'HTML', 'CSV', 'JSON', 'XML'];

  List<String> get availableOutputFormats {
    if (selectedInputFormat == null) return [];
    return TextConversionRepository.outputFormatsFor(selectedInputFormat!);
  }

  void setFile(File file) {
    selectedFile = file;
    isPasteMode = false;
    pastedText = '';
    resultFile = null;
    error = null;
    state = TextConverterState.idle;
    _inputSizeBytes = file.lengthSync();
    // Auto-detect format from extension
    final ext = file.path.split('.').last.toLowerCase();
    selectedInputFormat = ext.toUpperCase();
    selectedOutputFormat = null;
    _updatePreview();
    notifyListeners();
  }

  void setInputFormat(String fmt) {
    selectedInputFormat = fmt;
    selectedOutputFormat = null;
    _updatePreview();
    notifyListeners();
  }

  void setOutputFormat(String fmt) {
    selectedOutputFormat = fmt;
    _updatePreview();
    notifyListeners();
  }

  void setPasteMode(bool v) {
    isPasteMode = v;
    selectedFile = null;
    _inputSizeBytes = 0;
    notifyListeners();
  }

  void setPastedText(String text) {
    pastedText = text;
    _inputSizeBytes = text.length;
    _updatePreview();
    notifyListeners();
  }

  void _updatePreview() {
    if (selectedInputFormat == null || selectedOutputFormat == null) {
      preview = '';
      return;
    }
    try {
      String input = pastedText;
      if (!isPasteMode && selectedFile != null) {
        input = selectedFile!.readAsStringSync();
      }
      if (input.isEmpty) {
        preview = '';
        return;
      }
      final result = _repo.convertString(
        input: input,
        inputFormat: selectedInputFormat!.toLowerCase(),
        outputFormat: selectedOutputFormat!.toLowerCase(),
      );
      preview = result.length > 500 ? '${result.substring(0, 500)}...' : result;
    } catch (_) {
      preview = '';
    }
  }

  void reset() {
    selectedFile = null;
    selectedInputFormat = null;
    selectedOutputFormat = null;
    resultFile = null;
    error = null;
    state = TextConverterState.idle;
    isPasteMode = false;
    pastedText = '';
    preview = '';
    _inputSizeBytes = 0;
    lastDurationMs = 0;
    notifyListeners();
  }

  bool get canConvert =>
      selectedInputFormat != null &&
      selectedOutputFormat != null &&
      (selectedFile != null || (isPasteMode && pastedText.isNotEmpty));

  Future<void> convert() async {
    if (!canConvert) return;
    state = TextConverterState.converting;
    error = null;
    notifyListeners();

    final sw = Stopwatch()..start();
    try {
      if (isPasteMode) {
        resultFile = await _repo.convertFromString(
          input: pastedText,
          inputFormat: selectedInputFormat!.toLowerCase(),
          outputFormat: selectedOutputFormat!.toLowerCase(),
        );
      } else {
        resultFile = await _repo.convert(
          inputFile: selectedFile!,
          inputFormat: selectedInputFormat!.toLowerCase(),
          outputFormat: selectedOutputFormat!.toLowerCase(),
        );
      }
      sw.stop();
      lastDurationMs = sw.elapsedMilliseconds;

      await _history.saveJob(ConversionJob(
        id: const Uuid().v4(),
        inputFormat: selectedInputFormat!,
        outputFormat: selectedOutputFormat!,
        category: 'text',
        inputFileName: isPasteMode
            ? 'Pasted text'
            : selectedFile!.path.split(Platform.pathSeparator).last,
        outputFilePath: resultFile!.path,
        status: 'completed',
        inputSizeBytes: _inputSizeBytes,
        outputSizeBytes: await resultFile!.length(),
        durationMs: lastDurationMs,
        createdAt: DateTime.now(),
      ));

      state = TextConverterState.done;
    } catch (e) {
      sw.stop();
      error = UnknownFailure(e.toString());
      state = TextConverterState.error;
    }
    notifyListeners();
  }
}
