import 'dart:io';
import 'package:pdf/pdf.dart' hide PdfDocument;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfx/pdfx.dart';
import 'package:path/path.dart' as p;
import '../../../core/utils/app_storage_service.dart';

class PdfRepository {
  /// Convert multiple images to a single PDF
  Future<File> imagesToPdf({
    required List<File> images,
    String pageFormat = 'A4',
    int imageQuality = 85,
  }) async {
    final doc = pw.Document();
    final format = pageFormat == 'A4' ? PdfPageFormat.a4 : PdfPageFormat.letter;

    for (final imageFile in images) {
      final imageBytes = await imageFile.readAsBytes();
      final pdfImage = pw.MemoryImage(imageBytes);
      doc.addPage(pw.Page(
        pageFormat: format,
        build: (context) => pw.Center(
          child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
        ),
      ));
    }

    final outDir = await AppStorageService.getCategoryOutputDirectory('pdf');
    final outPath = p.join(outDir.path,
        'images_to_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf');
    final file = File(outPath);
    await file.writeAsBytes(await doc.save());
    return file;
  }

  /// Convert PDF pages to images
  Future<List<File>> pdfToImages({
    required File pdfFile,
    String format = 'jpg',
    int dpi = 150,
  }) async {
    final doc = await PdfDocument.openFile(pdfFile.path);
    final outDir = await AppStorageService.getCategoryOutputDirectory('pdf');
    final baseName = p.basenameWithoutExtension(pdfFile.path);
    final outFiles = <File>[];

    for (var i = 1; i <= doc.pagesCount; i++) {
      final page = await doc.getPage(i);
      final pageImage = await page.render(
        width: (page.width * dpi / 72).toDouble(),
        height: (page.height * dpi / 72).toDouble(),
        format: PdfPageImageFormat.jpeg,
      );
      await page.close();

      if (pageImage != null) {
        final outPath =
            p.join(outDir.path, '${baseName}_page_$i.$format');
        final outFile = File(outPath);
        await outFile.writeAsBytes(pageImage.bytes);
        outFiles.add(outFile);
      }
    }
    await doc.close();
    return outFiles;
  }

  /// Get page count of a PDF
  Future<int> getPageCount(File pdfFile) async {
    final doc = await PdfDocument.openFile(pdfFile.path);
    final count = doc.pagesCount;
    await doc.close();
    return count;
  }

  /// Merge multiple PDFs into one (using pdf package — re-render approach)
  Future<File> mergePdfs(List<File> pdfFiles) async {
    // Simple merge: render each page to image and combine into new PDF
    final doc = pw.Document();

    for (final pdfFile in pdfFiles) {
      final pdfDoc = await PdfDocument.openFile(pdfFile.path);
      for (var i = 1; i <= pdfDoc.pagesCount; i++) {
        final page = await pdfDoc.getPage(i);
        final pageImage = await page.render(
          width: (page.width * 2).toDouble(),
          height: (page.height * 2).toDouble(),
          format: PdfPageImageFormat.jpeg,
        );
        await page.close();

        if (pageImage != null) {
          final image = pw.MemoryImage(pageImage.bytes);
          doc.addPage(pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.zero,
            build: (context) => pw.Center(
              child: pw.Image(image, fit: pw.BoxFit.contain),
            ),
          ));
        }
      }
      await pdfDoc.close();
    }

    final outDir = await AppStorageService.getCategoryOutputDirectory('pdf');
    final outPath = p.join(outDir.path,
        'merged_${DateTime.now().millisecondsSinceEpoch}.pdf');
    final outFile = File(outPath);
    await outFile.writeAsBytes(await doc.save());
    return outFile;
  }

  /// Split PDF — extract specific page range
  Future<File> splitPdf({
    required File pdfFile,
    required int startPage,
    required int endPage,
  }) async {
    final doc = pw.Document();
    final pdfDoc = await PdfDocument.openFile(pdfFile.path);

    for (var i = startPage; i <= endPage; i++) {
      final page = await pdfDoc.getPage(i);
      final pageImage = await page.render(
        width: (page.width * 2).toDouble(),
        height: (page.height * 2).toDouble(),
        format: PdfPageImageFormat.jpeg,
      );
      await page.close();

      if (pageImage != null) {
        final image = pw.MemoryImage(pageImage.bytes);
        doc.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (context) => pw.Center(
            child: pw.Image(image, fit: pw.BoxFit.contain),
          ),
        ));
      }
    }
    await pdfDoc.close();

    final outDir = await AppStorageService.getCategoryOutputDirectory('pdf');
    final baseName = p.basenameWithoutExtension(pdfFile.path);
    final outPath = p.join(outDir.path,
        '${baseName}_pages_${startPage}_$endPage.pdf');
    final outFile = File(outPath);
    await outFile.writeAsBytes(await doc.save());
    return outFile;
  }
}
