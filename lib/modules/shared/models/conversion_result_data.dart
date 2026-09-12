import 'dart:io';

/// Data passed to ConversionResultPage via GoRouter extras.
class ConversionResultData {
  final File outputFile;
  final String inputFormat;
  final String outputFormat;
  final int inputSizeBytes;
  final int outputSizeBytes;
  final int durationMs;
  final String category;
  final String inputFileName;

  const ConversionResultData({
    required this.outputFile,
    required this.inputFormat,
    required this.outputFormat,
    required this.inputSizeBytes,
    required this.outputSizeBytes,
    required this.durationMs,
    required this.category,
    required this.inputFileName,
  });
}
