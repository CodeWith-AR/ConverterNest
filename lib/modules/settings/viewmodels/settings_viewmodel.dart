import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/app_settings.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../data/repositories/history_repository.dart';

class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository _settingsRepo;
  final HistoryRepository _historyRepo;
  SettingsViewModel(this._settingsRepo, this._historyRepo);

  AppSettings _settings = const AppSettings();
  AppSettings get settings => _settings;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _historyCount = 0;
  int get historyCount => _historyCount;

  bool get isDarkMode => _settings.theme != 'light';

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();
    try {
      _settings = await _settingsRepo.getSettings();
      AppColors.isDark = isDarkMode;
      final jobs = await _historyRepo.getJobs();
      _historyCount = jobs.length;
    } catch (_) {
      _settings = const AppSettings();
      AppColors.isDark = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    final newTheme = isDarkMode ? 'light' : 'dark';
    await setTheme(newTheme);
  }

  Future<void> setTheme(String value) async {
    _settings = _settings.copyWith(theme: value);
    AppColors.isDark = value != 'light';
    notifyListeners();
    await _settingsRepo.saveSettings(_settings);
  }

  Future<void> setBatteryWarning(bool value) async {
    _settings = _settings.copyWith(showBatteryWarning: value);
    notifyListeners();
    await _settingsRepo.saveSettings(_settings);
  }

  Future<void> setLargeFileWarning(bool value) async {
    _settings = _settings.copyWith(showLargeFileWarning: value);
    notifyListeners();
    await _settingsRepo.saveSettings(_settings);
  }

  Future<void> setThreshold(int mb) async {
    _settings = _settings.copyWith(largeFileThresholdMb: mb);
    notifyListeners();
    await _settingsRepo.saveSettings(_settings);
  }

  Future<void> clearHistory() async {
    await _historyRepo.clearHistory();
    _historyCount = 0;
    notifyListeners();
  }

  void setHistoryCount(int count) {
    _historyCount = count;
    notifyListeners();
  }
}
