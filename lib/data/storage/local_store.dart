import 'package:shared_preferences/shared_preferences.dart';

class LocalStore {
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> setString(String key, String value) async =>
      (await _prefs).setString(key, value);
  Future<String?> getString(String key) async => (await _prefs).getString(key);
  Future<void> setBool(String key, bool value) async =>
      (await _prefs).setBool(key, value);
  Future<bool?> getBool(String key) async => (await _prefs).getBool(key);
  Future<void> setInt(String key, int value) async =>
      (await _prefs).setInt(key, value);
  Future<int?> getInt(String key) async => (await _prefs).getInt(key);
}
