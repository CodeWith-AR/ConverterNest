import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../repositories/archive_repository.dart';
import '../../../data/models/conversion_job.dart';
import '../../../data/repositories/history_repository.dart';
import '../../../core/errors/failure.dart';

enum ArchiveMode { create, extract }

enum ArchiveState { idle, processing, done, error }

class ArchiveViewModel extends ChangeNotifier {
  final ArchiveRepository _repo;
  final HistoryRepository _history;
  ArchiveViewModel(this._repo, this._history);

  ArchiveMode mode = ArchiveMode.create;
  ArchiveState state = ArchiveState.idle;
  Failure? error;

  // Create mode
  List<File> selectedFiles = [];
  String archiveName = 'archive';
  String outputFormat = 'ZIP';
  File? resultArchive;

  // Extract mode
  File? archiveFile;
  List<String> archiveContents = [];
  Directory? extractedDir;
  int lastDurationMs = 0;

  int get totalSizeBytes =>
      selectedFiles.fold(0, (sum, f) => sum + f.lengthSync());

  void setMode(ArchiveMode m) {
    mode = m;
    state = ArchiveState.idle;
    error = null;
    notifyListeners();
  }

  void addFiles(List<File> files) {
    selectedFiles.addAll(files);
    notifyListeners();
  }

  void removeFile(int index) {
    selectedFiles.removeAt(index);
    notifyListeners();
  }

  void setArchiveName(String name) {
    archiveName = name;
    notifyListeners();
  }

  void setOutputFormat(String fmt) {
    outputFormat = fmt;
    notifyListeners();
  }

  Future<void> setArchiveFile(File file) async {
    archiveFile = file;
    state = ArchiveState.idle;
    error = null;
    try {
      archiveContents = await _repo.listContents(file);
    } catch (_) {
      archiveContents = [];
    }
    notifyListeners();
  }

  void reset() {
    state = ArchiveState.idle;
    error = null;
    selectedFiles = [];
    archiveName = 'archive';
    outputFormat = 'ZIP';
    resultArchive = null;
    archiveFile = null;
    archiveContents = [];
    extractedDir = null;
    lastDurationMs = 0;
    notifyListeners();
  }

  bool get canCreate => selectedFiles.isNotEmpty && archiveName.isNotEmpty;
  bool get canExtract => archiveFile != null;

  Future<void> createArchive() async {
    if (!canCreate) return;
    state = ArchiveState.processing;
    error = null;
    notifyListeners();

    final sw = Stopwatch()..start();
    try {
      if (outputFormat == 'ZIP') {
        resultArchive = await _repo.createZip(selectedFiles, archiveName);
      } else {
        resultArchive = await _repo.createTar(selectedFiles, archiveName);
      }
      sw.stop();
      lastDurationMs = sw.elapsedMilliseconds;

      await _history.saveJob(ConversionJob(
        id: const Uuid().v4(),
        inputFormat: '${selectedFiles.length} files',
        outputFormat: outputFormat,
        category: 'archive',
        inputFileName:
            '${selectedFiles.length} files → $archiveName.$outputFormat',
        outputFilePath: resultArchive!.path,
        status: 'completed',
        inputSizeBytes: totalSizeBytes,
        outputSizeBytes: await resultArchive!.length(),
        durationMs: lastDurationMs,
        createdAt: DateTime.now(),
      ));

      state = ArchiveState.done;
    } catch (e) {
      sw.stop();
      error = UnknownFailure(e.toString());
      state = ArchiveState.error;
    }
    notifyListeners();
  }

  Future<void> extractArchive() async {
    if (!canExtract) return;
    state = ArchiveState.processing;
    error = null;
    notifyListeners();

    final sw = Stopwatch()..start();
    try {
      extractedDir = await _repo.extract(archiveFile!);
      sw.stop();

      await _history.saveJob(ConversionJob(
        id: const Uuid().v4(),
        inputFormat: archiveFile!.path.split('.').last.toUpperCase(),
        outputFormat: 'FOLDER',
        category: 'archive',
        inputFileName: archiveFile!.path.split(Platform.pathSeparator).last,
        outputFilePath: extractedDir!.path,
        status: 'completed',
        inputSizeBytes: archiveFile!.lengthSync(),
        outputSizeBytes: 0,
        durationMs: sw.elapsedMilliseconds,
        createdAt: DateTime.now(),
      ));

      state = ArchiveState.done;
    } catch (e) {
      sw.stop();
      error = UnknownFailure(e.toString());
      state = ArchiveState.error;
    }
    notifyListeners();
  }
}
