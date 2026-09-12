import 'package:flutter/material.dart';
import '../../../data/models/conversion_job.dart';
import '../../../data/repositories/history_repository.dart';
import '../../../core/errors/failure.dart';

enum HistoryFilter { all, image, audio, video, archive, text, pdf }

class HistoryViewModel extends ChangeNotifier {
  final HistoryRepository _repo;
  HistoryViewModel(this._repo);

  List<ConversionJob> _allJobs = [];
  List<ConversionJob> filteredJobs = [];
  HistoryFilter activeFilter = HistoryFilter.all;
  String searchQuery = '';
  bool isLoading = false;
  Failure? error;

  Future<void> loadHistory() async {
    isLoading = true;
    notifyListeners();
    try {
      _allJobs = await _repo.getJobs();
      _applyFilter();
      error = null;
    } catch (e) {
      error = UnknownFailure(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Keep backward compat with existing calls
  Future<void> loadJobs() => loadHistory();

  void setFilter(HistoryFilter filter) {
    activeFilter = filter;
    _applyFilter();
    notifyListeners();
  }

  void setSearch(String query) {
    searchQuery = query.toLowerCase();
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    var result = _allJobs;
    if (activeFilter != HistoryFilter.all) {
      result = result.where((j) => j.category == activeFilter.name).toList();
    }
    if (searchQuery.isNotEmpty) {
      result = result
          .where((j) =>
              j.inputFileName.toLowerCase().contains(searchQuery) ||
              j.inputFormat.toLowerCase().contains(searchQuery) ||
              j.outputFormat.toLowerCase().contains(searchQuery))
          .toList();
    }
    filteredJobs = result;
  }

  Future<void> deleteJob(String id) async {
    await _repo.deleteJob(id);
    _allJobs.removeWhere((j) => j.id == id);
    _applyFilter();
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _repo.clearHistory();
    _allJobs = [];
    filteredJobs = [];
    notifyListeners();
  }

  // Stats for the stats card
  int get totalConversions => _allJobs.length;
  int get successCount => _allJobs.where((j) => j.status == 'completed').length;
  int get totalSavedBytes => _allJobs.fold(
      0, (sum, j) => sum + (j.inputSizeBytes - j.outputSizeBytes).abs());
}
