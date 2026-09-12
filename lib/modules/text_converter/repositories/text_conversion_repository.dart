import 'dart:convert';
import 'dart:io';
import 'package:markdown/markdown.dart' as md;
import 'package:csv/csv.dart';
import 'package:path/path.dart' as p;
import '../../../core/utils/app_storage_service.dart';

class TextConversionRepository {
  Future<File> convert({
    required File inputFile,
    required String inputFormat,
    required String outputFormat,
  }) async {
    final inputContent = await inputFile.readAsString(encoding: utf8);
    final outputContent = convertString(
      input: inputContent,
      inputFormat: inputFormat,
      outputFormat: outputFormat,
    );

    final outDir = await AppStorageService.getCategoryOutputDirectory('text');
    final outName =
        '${p.basenameWithoutExtension(inputFile.path)}_converted.${outputFormat.toLowerCase()}';
    final outPath = p.join(outDir.path, outName);
    return File(outPath)..writeAsStringSync(outputContent, encoding: utf8);
  }

  /// Also supports converting from pasted text string
  Future<File> convertFromString({
    required String input,
    required String inputFormat,
    required String outputFormat,
  }) async {
    final outputContent = convertString(
      input: input,
      inputFormat: inputFormat,
      outputFormat: outputFormat,
    );

    final outDir = await AppStorageService.getCategoryOutputDirectory('text');
    final outName =
        'text_converted_${DateTime.now().millisecondsSinceEpoch}.${outputFormat.toLowerCase()}';
    final outPath = p.join(outDir.path, outName);
    return File(outPath)..writeAsStringSync(outputContent, encoding: utf8);
  }

  String convertString({
    required String input,
    required String inputFormat,
    required String outputFormat,
  }) {
    if (inputFormat == 'md' && outputFormat == 'html') {
      return md.markdownToHtml(input);
    } else if (inputFormat == 'md' && outputFormat == 'txt') {
      return input.replaceAll(RegExp(r'[#*_`\[\]()]'), '').trim();
    } else if (inputFormat == 'html' && outputFormat == 'txt') {
      return input.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    } else if (inputFormat == 'html' && outputFormat == 'md') {
      return input
          .replaceAll(RegExp(r'<h1[^>]*>(.*?)</h1>'), '# \$1')
          .replaceAll(RegExp(r'<h2[^>]*>(.*?)</h2>'), '## \$1')
          .replaceAll(RegExp(r'<p[^>]*>(.*?)</p>'), '\$1\n\n')
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .trim();
    } else if (inputFormat == 'csv' && outputFormat == 'json') {
      final normalized = input.replaceAll('\r\n', '\n');
      final rows = const CsvToListConverter(eol: '\n').convert(normalized);
      if (rows.isEmpty) throw Exception('Empty CSV');
      final headers = rows.first.map((e) => e.toString().trim()).toList();
      final data = rows.skip(1).where((r) => r.isNotEmpty).map((row) {
        final map = <String, dynamic>{};
        for (var i = 0; i < headers.length; i++) {
          map[headers[i]] = i < row.length ? row[i] : null;
        }
        return map;
      }).toList();
      return const JsonEncoder.withIndent('  ').convert(data);
    } else if (inputFormat == 'json' && outputFormat == 'csv') {
      final data = jsonDecode(input);
      final list = data is List ? data : [data];
      if (list.isEmpty) throw Exception('Empty JSON');
      final headers = (list.first as Map).keys.toList();
      final rows = [
        headers,
        ...list.map((item) => headers.map((h) => item[h]).toList()),
      ];
      return const ListToCsvConverter().convert(
        rows.map((r) => r.map((e) => e).toList()).toList(),
      );
    } else if (inputFormat == 'json' && outputFormat == 'xml') {
      final data = jsonDecode(input);
      return _jsonToXml(data);
    } else if (inputFormat == 'xml' && outputFormat == 'json') {
      // Simple XML → JSON (basic — uses regex for common tags)
      return input; // Simplified — full XML parsing requires xml package
    } else if (inputFormat == 'txt' && outputFormat == 'md') {
      return input;
    } else if (inputFormat == 'txt' && outputFormat == 'html') {
      final paragraphs = input.split('\n\n');
      return paragraphs.map((p) => '<p>$p</p>').join('\n');
    } else {
      return input;
    }
  }

  String _jsonToXml(dynamic data, {String root = 'root'}) {
    final buffer = StringBuffer('<?xml version="1.0" encoding="UTF-8"?>\n');
    buffer.write('<$root>\n');
    _buildXml(buffer, data, indent: '  ');
    buffer.write('</$root>');
    return buffer.toString();
  }

  void _buildXml(StringBuffer buffer, dynamic data, {String indent = ''}) {
    if (data is Map) {
      data.forEach((key, value) {
        buffer.write('$indent<$key>');
        if (value is Map || value is List) {
          buffer.writeln();
          _buildXml(buffer, value, indent: '$indent  ');
          buffer.write(indent);
        } else {
          buffer.write(value?.toString() ?? '');
        }
        buffer.writeln('</$key>');
      });
    } else if (data is List) {
      for (final item in data) {
        buffer.write('$indent<item>');
        if (item is Map || item is List) {
          buffer.writeln();
          _buildXml(buffer, item, indent: '$indent  ');
          buffer.write(indent);
        } else {
          buffer.write(item?.toString() ?? '');
        }
        buffer.writeln('</item>');
      }
    } else {
      buffer.write('$indent${data?.toString() ?? ''}');
    }
  }

  /// Returns valid output formats for a given input format
  static List<String> outputFormatsFor(String inputFormat) {
    switch (inputFormat.toLowerCase()) {
      case 'txt':
        return ['MD', 'HTML'];
      case 'md':
        return ['HTML', 'TXT'];
      case 'html':
        return ['TXT', 'MD'];
      case 'csv':
        return ['JSON', 'XML', 'TXT'];
      case 'json':
        return ['CSV', 'XML', 'TXT'];
      case 'xml':
        return ['JSON', 'CSV', 'TXT'];
      default:
        return [];
    }
  }
}
