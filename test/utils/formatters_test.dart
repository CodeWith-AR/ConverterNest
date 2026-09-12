import 'package:flutter_test/flutter_test.dart';
import 'package:converter_nest/core/utils/formatters.dart';

void main() {
  group('Formatters', () {
    test('fileSize formats correctly across ranges', () {
      expect(Formatters.fileSize(500), '500 B');
      expect(Formatters.fileSize(1024), '1.0 KB');
      expect(Formatters.fileSize(1536), '1.5 KB');
      expect(Formatters.fileSize(1024 * 1024), '1.0 MB');
      expect(Formatters.fileSize(1024 * 1024 * 1024), '1.00 GB');
    });

    test('duration formats correctly across ranges', () {
      expect(Formatters.duration(500), '500ms');
      expect(Formatters.duration(1500), '1.5s');
      expect(Formatters.duration(65000), '1m 5s');
    });

    test('formatExtension formats extension cleanly', () {
      expect(Formatters.formatExtension('.jpg'), 'JPG');
      expect(Formatters.formatExtension('png'), 'PNG');
    });

    test('formatBadge returns uppercase string', () {
      expect(Formatters.formatBadge('pdf'), 'PDF');
      expect(Formatters.formatBadge('webp'), 'WEBP');
    });

    test('sizeDiff reports percent reduction or increase', () {
      expect(Formatters.sizeDiff(1000, 500), '50% smaller');
      expect(Formatters.sizeDiff(500, 1000), '100% larger');
      expect(Formatters.sizeDiff(500, 500), 'Same size');
    });
  });
}
