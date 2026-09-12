import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path/path.dart' as p;
import '../../../core/utils/app_storage_service.dart';

class AudioConversionRepository {
  Future<File> convert({
    required File inputFile,
    required String outputFormat,
    String bitrate = '128k',
    int sampleRate = 44100,
    int channels = 2,
    double? trimStart,
    double? trimEnd,
    double volume = 1.0,
  }) async {
    final outDir = await AppStorageService.getCategoryOutputDirectory('audio');
    final outName =
        '${p.basenameWithoutExtension(inputFile.path)}_converted.${outputFormat.toLowerCase()}';
    final outPath = p.join(outDir.path, outName);

    final cmd = StringBuffer('-i "${inputFile.path}"');
    if (trimStart != null) cmd.write(' -ss $trimStart');
    if (trimEnd != null) cmd.write(' -to $trimEnd');
    cmd.write(' -ar $sampleRate');
    cmd.write(' -ac $channels');
    if (volume != 1.0) cmd.write(' -af "volume=$volume"');

    switch (outputFormat) {
      case 'mp3':
        cmd.write(' -codec:a libmp3lame -b:a $bitrate');
      case 'aac':
      case 'm4a':
        cmd.write(' -codec:a aac -b:a $bitrate');
      case 'ogg':
        cmd.write(' -codec:a libvorbis -b:a $bitrate');
      case 'opus':
        cmd.write(' -codec:a libopus -b:a $bitrate');
      case 'flac':
        cmd.write(' -codec:a flac');
      case 'wav':
        cmd.write(' -codec:a pcm_s16le');
      case 'amr':
        cmd.write(' -codec:a libopencore_amrnb -ar 8000 -ac 1');
      case 'aiff':
        cmd.write(' -codec:a pcm_s16be');
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
