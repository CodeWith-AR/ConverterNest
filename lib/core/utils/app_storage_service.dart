import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

/// Service managing file output locations across all Android versions
/// and other platforms, ensuring outputs are placed in public Downloads/ConverterNest/{category}
class AppStorageService {
  AppStorageService._();

  static const String appFolderName = 'ConverterNest';

  /// Request necessary storage permissions across Android versions
  static Future<void> requestStoragePermissions() async {
    if (!Platform.isAndroid) return;
    try {
      if (await Permission.storage.isDenied) {
        await Permission.storage.request();
      }
    } catch (_) {}
  }

  /// Resolves the base ConverterNest directory, prioritizing public Downloads/ConverterNest
  static Future<Directory> getBaseOutputDirectory() async {
    if (Platform.isAndroid) {
      await requestStoragePermissions();

      // Priority 1: Standard public /storage/emulated/0/Download
      final downloadCandidates = [
        Directory('/storage/emulated/0/Download'),
        Directory('/storage/emulated/0/Downloads'),
      ];

      for (final candidate in downloadCandidates) {
        try {
          if (await candidate.exists()) {
            final appDir = Directory('${candidate.path}/$appFolderName');
            if (!await appDir.exists()) {
              await appDir.create(recursive: true);
            }
            return appDir;
          }
        } catch (_) {}
      }

      // Priority 2: path_provider getDownloadsDirectory
      try {
        final downloadsDir = await getDownloadsDirectory();
        if (downloadsDir != null) {
          final appDir = Directory('${downloadsDir.path}/$appFolderName');
          if (!await appDir.exists()) {
            await appDir.create(recursive: true);
          }
          return appDir;
        }
      } catch (_) {}

      // Priority 3: External storage directory
      try {
        final extDir = await getExternalStorageDirectory();
        if (extDir != null) {
          final appDir = Directory('${extDir.path}/$appFolderName');
          if (!await appDir.exists()) {
            await appDir.create(recursive: true);
          }
          return appDir;
        }
      } catch (_) {}
    }

    // Fallback: App documents directory (works on iOS, desktop, test)
    final appDocDir = await getApplicationDocumentsDirectory();
    final appDir = Directory('${appDocDir.path}/$appFolderName');
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    return appDir;
  }

  /// Resolves the category folder inside ConverterNest (e.g. Downloads/ConverterNest/audio)
  static Future<Directory> getCategoryOutputDirectory(String category) async {
    final baseDir = await getBaseOutputDirectory();
    final sanitizedCategory =
        category.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    final categoryDir = Directory('${baseDir.path}/$sanitizedCategory');
    if (!await categoryDir.exists()) {
      try {
        await categoryDir.create(recursive: true);
        return categoryDir;
      } catch (_) {
        return baseDir;
      }
    }
    return categoryDir;
  }

  /// Opens the ConverterNest folder in the system file explorer
  static Future<OpenResult> openFolder([String? category]) async {
    final dir = category != null
        ? await getCategoryOutputDirectory(category)
        : await getBaseOutputDirectory();

    return OpenFile.open(dir.path);
  }
}
