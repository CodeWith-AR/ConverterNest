import 'package:flutter/material.dart';
import '../../../data/models/conversion_job.dart';
import '../../../data/repositories/history_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final HistoryRepository _historyRepo;
  HomeViewModel(this._historyRepo);

  List<ConversionJob> _recentJobs = [];
  List<ConversionJob> get recentJobs => _recentJobs;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadRecentJobs() async {
    _isLoading = true;
    notifyListeners();
    try {
      final all = await _historyRepo.getJobs();
      _recentJobs = all.take(3).toList();
    } catch (_) {
      _recentJobs = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
