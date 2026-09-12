import 'package:flutter_test/flutter_test.dart';
import 'package:converter_nest/modules/text_converter/repositories/text_conversion_repository.dart';

void main() {
  group('TextConversionRepository', () {
    final repo = TextConversionRepository();

    test('Markdown to HTML converts headings and paragraphs', () {
      final html = repo.convertString(
        input: '# Hello World\n\nThis is a test.',
        inputFormat: 'md',
        outputFormat: 'html',
      );
      expect(html, contains('<h1>Hello World</h1>'));
      expect(html, contains('<p>This is a test.</p>'));
    });

    test('HTML to TXT strips HTML tags', () {
      final txt = repo.convertString(
        input: '<h1>Title</h1><p>Paragraph content</p>',
        inputFormat: 'html',
        outputFormat: 'txt',
      );
      expect(txt, 'TitleParagraph content');
    });

    test('CSV to JSON converts tabular data', () {
      const csv = 'name,age\nAlice,30\nBob,25';
      final jsonStr = repo.convertString(
        input: csv,
        inputFormat: 'csv',
        outputFormat: 'json',
      );
      expect(jsonStr, contains('"name": "Alice"'));
      expect(jsonStr, contains('"age": 30'));
    });

    test('JSON to CSV converts json array to csv rows', () {
      const jsonStr = '[{"name":"Alice","age":30},{"name":"Bob","age":25}]';
      final csv = repo.convertString(
        input: jsonStr,
        inputFormat: 'json',
        outputFormat: 'csv',
      );
      expect(csv, contains('name,age'));
      expect(csv, contains('Alice,30'));
    });
  });
}
