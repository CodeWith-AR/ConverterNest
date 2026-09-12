import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../core/utils/app_storage_service.dart';

class ImageConversionRepository {
  Future<File> convert({
    required File inputFile,
    required String outputFormat,
    int quality = 90,
    int? targetWidth,
    int? targetHeight,
    int rotationDegrees = 0,
    bool flipHorizontal = false,
    bool flipVertical = false,
  }) async {
    // 1. Decode input
    img.Image? decoded;
    final ext = p.extension(inputFile.path).toLowerCase().replaceAll('.', '');

    if (ext == 'heic' || ext == 'heif') {
      // HEIC handled via flutter_image_compress → JPG first
      final tmpDir = await getTemporaryDirectory();
      final tmpPath = p.join(
          tmpDir.path, 'heic_tmp_${DateTime.now().millisecondsSinceEpoch}.jpg');
      final result = await FlutterImageCompress.compressAndGetFile(
        inputFile.absolute.path,
        tmpPath,
        format: CompressFormat.jpeg,
        quality: 95,
      );
      if (result == null) throw Exception('HEIC conversion failed');
      decoded = img.decodeImage(await File(result.path).readAsBytes());
    } else {
      decoded = img.decodeImage(await inputFile.readAsBytes());
    }

    if (decoded == null) throw Exception('Could not decode image');

    // 2. Apply operations
    if (rotationDegrees != 0) {
      decoded = img.copyRotate(decoded, angle: rotationDegrees);
    }
    if (flipHorizontal) decoded = img.flipHorizontal(decoded);
    if (flipVertical) decoded = img.flipVertical(decoded);
    if (targetWidth != null || targetHeight != null) {
      decoded = img.copyResize(
        decoded,
        width: targetWidth,
        height: targetHeight,
        interpolation: img.Interpolation.cubic,
      );
    }

    // 3. Encode output
    final outDir = await AppStorageService.getCategoryOutputDirectory('image');
    final outFileName =
        '${p.basenameWithoutExtension(inputFile.path)}_converted.${outputFormat.toLowerCase()}';
    final outPath = p.join(outDir.path, outFileName);

    Uint8List outBytes;
    switch (outputFormat) {
      case 'jpg':
      case 'jpeg':
        outBytes = img.encodeJpg(decoded, quality: quality);
      case 'png':
        outBytes = img.encodePng(decoded);
      case 'bmp':
        outBytes = img.encodeBmp(decoded);
      case 'gif':
        outBytes = img.encodeGif(decoded);
      case 'tga':
        outBytes = img.encodeTga(decoded);
      case 'tiff':
        outBytes = img.encodePng(decoded); // fallback
      case 'ico':
        outBytes = img.encodeIco(decoded);
      case 'webp':
        // Use flutter_image_compress for WebP (better quality)
        final tmpDir = await getTemporaryDirectory();
        final tmpJpg = p.join(tmpDir.path,
            'tmp_webp_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await File(tmpJpg).writeAsBytes(img.encodeJpg(decoded));
        final result = await FlutterImageCompress.compressAndGetFile(
          tmpJpg,
          outPath,
          format: CompressFormat.webp,
          quality: quality,
        );
        await File(tmpJpg).delete();
        if (result == null) throw Exception('WebP conversion failed');
        return File(result.path);
      default:
        outBytes = img.encodePng(decoded);
    }

    final outFile = File(outPath);
    await outFile.writeAsBytes(outBytes);
    return outFile;
  }
}
