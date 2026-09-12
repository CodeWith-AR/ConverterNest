import 'package:flutter_test/flutter_test.dart';
import 'package:converter_nest/core/utils/file_type_detector.dart';
import 'package:converter_nest/core/constants/app_colors.dart';

void main() {
  group('FileTypeDetector', () {
    test('categoryForExtension identifies all categories', () {
      expect(FileTypeDetector.categoryForExtension('jpg'), 'image');
      expect(FileTypeDetector.categoryForExtension('.PNG'), 'image');
      expect(FileTypeDetector.categoryForExtension('mp3'), 'audio');
      expect(FileTypeDetector.categoryForExtension('mp4'), 'video');
      expect(FileTypeDetector.categoryForExtension('zip'), 'archive');
      expect(FileTypeDetector.categoryForExtension('md'), 'text');
      expect(FileTypeDetector.categoryForExtension('pdf'), 'pdf');
      expect(FileTypeDetector.categoryForExtension('xyz_unknown'), 'unknown');
    });

    test('accentColorForCategory returns correct brand accent colors', () {
      expect(FileTypeDetector.accentColorForCategory('image'),
          AppColors.accentImage);
      expect(FileTypeDetector.accentColorForCategory('audio'),
          AppColors.accentAudio);
      expect(FileTypeDetector.accentColorForCategory('video'),
          AppColors.accentVideo);
      expect(FileTypeDetector.accentColorForCategory('archive'),
          AppColors.accentArchive);
      expect(FileTypeDetector.accentColorForCategory('text'),
          AppColors.accentText);
      expect(
          FileTypeDetector.accentColorForCategory('pdf'), AppColors.accentPdf);
      expect(FileTypeDetector.accentColorForCategory('unknown'),
          AppColors.textSecondary);
    });
  });
}
