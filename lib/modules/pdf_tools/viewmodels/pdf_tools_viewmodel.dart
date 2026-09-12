import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../repositories/pdf_repository.dart';
import '../../../data/models/conversion_job.dart';
import '../../../data/repositories/history_repository.dart';
import '../../../core/errors/failure.dart';

enum PdfToolMode { imagesToPdf, pdfToImages, mergePdfs, splitPdf }

enum PdfToolsState { idle, processing, done, error }

class PdfToolsViewModel extends ChangeNotifier {
  final PdfRepository _repo;
  final HistoryRepository _history;
  PdfToolsViewModel(this._repo, this._history);

  PdfToolMode mode = PdfToolMode.imagesToPdf;
  PdfToolsState state = PdfToolsState.idle;
  Failure? error;

  // Images → PDF
  List<File> selectedImages = [];
  String pageFormat = 'A4';
  int imageQuality = 85;

  // PDF → Images
  File? selectedPdf;
  String outputImageFormat = 'jpg';
  int dpi = 150;
  int? totalPages;

  // Merge PDFs
  List<File> selectedPdfs = [];

  // Split PDF
  File? splitPdfFile;
  int? splitTotalPages;
  int startPage = 1;
  int endPage = 1;

  // Result
  File? resultFile;
  List<File>? resultFiles;
  int lastDurationMs = 0;

  void setMode(PdfToolMode m) {
    mode = m;
    state = PdfToolsState.idle;
    error = null;
    notifyListeners();
  }

  // Images → PDF methods
  void addImages(List<File> images) {
    selectedImages.addAll(images);
    notifyListeners();
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
    notifyListeners();
  }

  void reorderImages(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = selectedImages.removeAt(oldIndex);
    selectedImages.insert(newIndex, item);
    notifyListeners();
  }

  void setPageFormat(String fmt) {
    pageFormat = fmt;
    notifyListeners();
  }

  // PDF → Images methods
  Future<void> setPdfFile(File file) async {
    selectedPdf = file;
    state = PdfToolsState.idle;
    error = null;
    try {
      totalPages = await _repo.getPageCount(file);
    } catch (_) {
      totalPages = null;
    }
    notifyListeners();
  }

  void setOutputImageFormat(String fmt) {
    outputImageFormat = fmt;
    notifyListeners();
  }

  void setDpi(int d) {
    dpi = d;
    notifyListeners();
  }

  // Merge methods
  void addPdfs(List<File> pdfs) {
    selectedPdfs.addAll(pdfs);
    notifyListeners();
  }

  void removePdf(int index) {
    selectedPdfs.removeAt(index);
    notifyListeners();
  }

  void reorderPdfs(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = selectedPdfs.removeAt(oldIndex);
    selectedPdfs.insert(newIndex, item);
    notifyListeners();
  }

  // Split methods
  Future<void> setSplitPdf(File file) async {
    splitPdfFile = file;
    state = PdfToolsState.idle;
    error = null;
    try {
      splitTotalPages = await _repo.getPageCount(file);
      startPage = 1;
      endPage = splitTotalPages ?? 1;
    } catch (_) {
      splitTotalPages = null;
    }
    notifyListeners();
  }

  void setStartPage(int page) {
    startPage = page;
    notifyListeners();
  }

  void setEndPage(int page) {
    endPage = page;
    notifyListeners();
  }

  void reset() {
    state = PdfToolsState.idle;
    error = null;
    selectedImages = [];
    pageFormat = 'A4';
    imageQuality = 85;
    selectedPdf = null;
    outputImageFormat = 'jpg';
    dpi = 150;
    totalPages = null;
    selectedPdfs = [];
    splitPdfFile = null;
    splitTotalPages = null;
    startPage = 1;
    endPage = 1;
    resultFile = null;
    resultFiles = null;
    lastDurationMs = 0;
    notifyListeners();
  }

  Future<void> execute() async {
    state = PdfToolsState.processing;
    error = null;
    notifyListeners();

    final sw = Stopwatch()..start();
    try {
      switch (mode) {
        case PdfToolMode.imagesToPdf:
          resultFile = await _repo.imagesToPdf(
            images: selectedImages,
            pageFormat: pageFormat,
            imageQuality: imageQuality,
          );
          sw.stop();
          lastDurationMs = sw.elapsedMilliseconds;
          await _history.saveJob(ConversionJob(
            id: const Uuid().v4(),
            inputFormat: '${selectedImages.length} images',
            outputFormat: 'PDF',
            category: 'pdf',
            inputFileName: '${selectedImages.length} images → PDF',
            outputFilePath: resultFile!.path,
            status: 'completed',
            inputSizeBytes:
                selectedImages.fold(0, (s, f) => s + f.lengthSync()),
            outputSizeBytes: await resultFile!.length(),
            durationMs: lastDurationMs,
            createdAt: DateTime.now(),
          ));

        case PdfToolMode.pdfToImages:
          resultFiles = await _repo.pdfToImages(
            pdfFile: selectedPdf!,
            format: outputImageFormat,
            dpi: dpi,
          );
          sw.stop();
          lastDurationMs = sw.elapsedMilliseconds;
          await _history.saveJob(ConversionJob(
            id: const Uuid().v4(),
            inputFormat: 'PDF',
            outputFormat: outputImageFormat.toUpperCase(),
            category: 'pdf',
            inputFileName: selectedPdf!.path.split(Platform.pathSeparator).last,
            outputFilePath:
                resultFiles!.isNotEmpty ? resultFiles!.first.path : '',
            status: 'completed',
            inputSizeBytes: selectedPdf!.lengthSync(),
            outputSizeBytes: resultFiles!.fold(0, (s, f) => s + f.lengthSync()),
            durationMs: lastDurationMs,
            createdAt: DateTime.now(),
          ));

        case PdfToolMode.mergePdfs:
          resultFile = await _repo.mergePdfs(selectedPdfs);
          sw.stop();
          lastDurationMs = sw.elapsedMilliseconds;
          await _history.saveJob(ConversionJob(
            id: const Uuid().v4(),
            inputFormat: '${selectedPdfs.length} PDFs',
            outputFormat: 'PDF',
            category: 'pdf',
            inputFileName: '${selectedPdfs.length} PDFs → Merged',
            outputFilePath: resultFile!.path,
            status: 'completed',
            inputSizeBytes: selectedPdfs.fold(0, (s, f) => s + f.lengthSync()),
            outputSizeBytes: await resultFile!.length(),
            durationMs: lastDurationMs,
            createdAt: DateTime.now(),
          ));

        case PdfToolMode.splitPdf:
          resultFile = await _repo.splitPdf(
            pdfFile: splitPdfFile!,
            startPage: startPage,
            endPage: endPage,
          );
          sw.stop();
          lastDurationMs = sw.elapsedMilliseconds;
          await _history.saveJob(ConversionJob(
            id: const Uuid().v4(),
            inputFormat: 'PDF',
            outputFormat: 'PDF (split)',
            category: 'pdf',
            inputFileName:
                splitPdfFile!.path.split(Platform.pathSeparator).last,
            outputFilePath: resultFile!.path,
            status: 'completed',
            inputSizeBytes: splitPdfFile!.lengthSync(),
            outputSizeBytes: await resultFile!.length(),
            durationMs: lastDurationMs,
            createdAt: DateTime.now(),
          ));
      }
      state = PdfToolsState.done;
    } catch (e) {
      sw.stop();
      error = UnknownFailure(e.toString());
      state = PdfToolsState.error;
    }
    notifyListeners();
  }
}
