import 'package:hive_flutter/hive_flutter.dart';

part 'conversion_job.g.dart';

@HiveType(typeId: 0)
class ConversionJob extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String inputFormat;
  @HiveField(2)
  String outputFormat;
  @HiveField(3)
  String category; // 'image', 'audio', 'video', 'archive', 'text', 'pdf'
  @HiveField(4)
  String inputFileName;
  @HiveField(5)
  String outputFilePath;
  @HiveField(6)
  String status; // 'completed', 'failed'
  @HiveField(7)
  int inputSizeBytes;
  @HiveField(8)
  int outputSizeBytes;
  @HiveField(9)
  int durationMs;
  @HiveField(10)
  String? errorMessage;
  @HiveField(11)
  DateTime createdAt;

  ConversionJob({
    required this.id,
    required this.inputFormat,
    required this.outputFormat,
    required this.category,
    required this.inputFileName,
    required this.outputFilePath,
    required this.status,
    required this.inputSizeBytes,
    required this.outputSizeBytes,
    required this.durationMs,
    this.errorMessage,
    required this.createdAt,
  });
}
