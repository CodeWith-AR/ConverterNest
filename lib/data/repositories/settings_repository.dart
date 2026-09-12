import '../models/app_settings.dart';
import '../storage/local_store.dart';

class SettingsRepository {
  final LocalStore _store;
  SettingsRepository(this._store);

  static const _kBatteryWarn = 'batteryWarn';
  static const _kLargeWarn = 'largeWarn';
  static const _kThreshold = 'threshold';

  Future<AppSettings> getSettings() async {
    return AppSettings(
      showBatteryWarning: (await _store.getBool(_kBatteryWarn)) ?? true,
      showLargeFileWarning: (await _store.getBool(_kLargeWarn)) ?? true,
      largeFileThresholdMb: (await _store.getInt(_kThreshold)) ?? 200,
    );
  }

  Future<void> saveSettings(AppSettings s) async {
    await _store.setBool(_kBatteryWarn, s.showBatteryWarning);
    await _store.setBool(_kLargeWarn, s.showLargeFileWarning);
    await _store.setInt(_kThreshold, s.largeFileThresholdMb);
  }
}
