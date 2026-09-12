import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path/path.dart' as p;
import '../../../core/utils/app_storage_service.dart';

class VideoConversionRepository {
  Future<File> convert({
    required File inputFile,
    required String outputFormat,
    String? resolution,
    int? fps,
    int crf = 23,
    bool extractAudioOnly = false,
    bool muteVideo = false,
    double? trimStart,
    double? trimEnd,
    void Function(double progress)? onProgress,
  }) async {
    final outDir = await AppStorageService.getCategoryOutputDirectory('video');
    final suffix = extractAudioOnly ? 'mp3' : outputFormat.toLowerCase();
    final outName =
        '${p.basenameWithoutExtension(inputFile.path)}_converted.$suffix';
    final outPath = p.join(outDir.path, outName);

    if (onProgress != null) {
      FFmpegKitConfig.enableStatisticsCallback((stats) {
        final time = stats.getTime();
        if (time > 0) {
          onProgress(0.5); // Simplified — use ffprobe for accurate progress
        }
      });
    }

    final cmd = StringBuffer('-i "${inputFile.path}"');
    if (trimStart != null) cmd.write(' -ss $trimStart');
    if (trimEnd != null) cmd.write(' -to $trimEnd');

    if (extractAudioOnly) {
      cmd.write(' -vn -codec:a libmp3lame -b:a 192k');
    } else {
      if (muteVideo) cmd.write(' -an');
      cmd.write(' -codec:v libx264 -crf $crf -preset medium');
      if (resolution != null) cmd.write(' -vf "scale=$resolution"');
      if (fps != null) cmd.write(' -r $fps');
      if (!muteVideo) cmd.write(' -codec:a aac -b:a 128k');
    }
    cmd.write(' -y "$outPath"');

    final session = await FFmpegKit.execute(cmd.toString());
    final rc = await session.getReturnCode();

    if (!ReturnCode.isSuccess(rc)) {
      final logs = await session.getAllLogsAsString();
      throw Exception('FFmpeg failed: $logs');
    }

    return File(outPath);
  }
}
