import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import '../../../core/utils/app_storage_service.dart';

class ArchiveRepository {
  /// Create ZIP from list of files
  Future<File> createZip(List<File> files, String archiveName) async {
    final encoder = ZipFileEncoder();
    final outDir = await AppStorageService.getCategoryOutputDirectory('archive');
    final outPath = p.join(outDir.path, '$archiveName.zip');

    encoder.create(outPath);
    for (final file in files) {
      encoder.addFile(file, p.basename(file.path));
    }
    encoder.close();
    return File(outPath);
  }

  /// Create TAR from list of files
  Future<File> createTar(List<File> files, String archiveName) async {
    final outDir = await AppStorageService.getCategoryOutputDirectory('archive');
    final outPath = p.join(outDir.path, '$archiveName.tar');

    final archive = Archive();
    for (final file in files) {
      final bytes = await file.readAsBytes();
      archive.addFile(ArchiveFile(p.basename(file.path), bytes.length, bytes));
    }

    final encoded = TarEncoder().encode(archive);
    final outFile = File(outPath);
    await outFile.writeAsBytes(encoded);
    return outFile;
  }

  /// Extract archive to folder
  Future<Directory> extract(File archiveFile) async {
    final outDir = await AppStorageService.getCategoryOutputDirectory('archive');
    final outDirPath = p.join(
        outDir.path, 'extracted', p.basenameWithoutExtension(archiveFile.path));
    await Directory(outDirPath).create(recursive: true);

    final bytes = await archiveFile.readAsBytes();
    Archive archive;

    final ext = p.extension(archiveFile.path).toLowerCase();
    if (ext == '.zip') {
      archive = ZipDecoder().decodeBytes(bytes);
    } else if (ext == '.tar') {
      archive = TarDecoder().decodeBytes(bytes);
    } else if (ext == '.gz' || ext == '.gzip') {
      final decompressed = GZipDecoder().decodeBytes(bytes);
      archive = TarDecoder().decodeBytes(decompressed);
    } else if (ext == '.bz2') {
      final decompressed = BZip2Decoder().decodeBytes(bytes);
      archive = TarDecoder().decodeBytes(decompressed);
    } else {
      throw UnsupportedError('Format $ext not supported');
    }

    for (final file in archive) {
      final filePath = p.join(outDirPath, file.name);
      if (file.isFile) {
        final outFile = File(filePath);
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content as List<int>);
      } else {
        await Directory(filePath).create(recursive: true);
      }
    }

    return Directory(outDirPath);
  }

  /// List archive contents without extracting
  Future<List<String>> listContents(File archiveFile) async {
    final bytes = await archiveFile.readAsBytes();
    final ext = p.extension(archiveFile.path).toLowerCase();
    Archive archive;

    if (ext == '.zip') {
      archive = ZipDecoder().decodeBytes(bytes);
    } else if (ext == '.tar') {
      archive = TarDecoder().decodeBytes(bytes);
    } else if (ext == '.gz' || ext == '.gzip') {
      final decompressed = GZipDecoder().decodeBytes(bytes);
      archive = TarDecoder().decodeBytes(decompressed);
    } else {
      return [];
    }
    return archive.map((f) => f.name).toList();
  }
}
