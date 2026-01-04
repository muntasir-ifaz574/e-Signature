import 'package:shared_preferences/shared_preferences.dart';

import '../../error/exceptions.dart';
import '../../utils/constants.dart';

class LocalData {
  final SharedPreferences _pref;
  LocalData(this._pref);

  /// Generic helper to safely write async values
  Future<void> _safeWrite(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      throw CacheException(message: 'Failed to save data locally: $e');
    }
  }

  /// Generic helper to safely read values
  T _safeRead<T>(T? Function() getter, T defaultValue) {
    try {
      return getter() ?? defaultValue;
    } catch (e) {
      // print('Cache read failed: $e\n$st');
      throw CacheException(message: 'Failed to read data locally: $e');
    }
  }

  // Token
  String getAccessToken() =>
      _safeRead(() => _pref.getString(AppConstants.accessTokenKey), '');

  Future<void> setAccessToken(String token) async =>
      _safeWrite(() => _pref.setString(AppConstants.accessTokenKey, token));

  // Login status
  bool getLoginStatus() =>
      _safeRead(() => _pref.getBool(AppConstants.isLoggedInKey), false);

  Future<void> setLoginStatus(bool loginStatus) async =>
      _safeWrite(() => _pref.setBool(AppConstants.isLoggedInKey, loginStatus));

  // Theme mode
  String getThemeMode() =>
      _safeRead(() => _pref.getString(AppConstants.themeKey), 'system');

  Future<void> setThemeMode(String themeMode) async =>
      _safeWrite(() => _pref.setString(AppConstants.themeKey, themeMode));

  // Language
  String getLanguage() =>
      _safeRead(() => _pref.getString(AppConstants.languageKey), 'en');

  Future<void> setLanguage(String language) async =>
      _safeWrite(() => _pref.setString(AppConstants.languageKey, language));

  // Onboarding
  bool getOnboardingComplete() =>
      _safeRead(() => _pref.getBool(AppConstants.onboardingKey), false);

  Future<void> setOnboardingComplete(bool isComplete) async =>
      _safeWrite(() => _pref.setBool(AppConstants.onboardingKey, isComplete));

  // Clear all cached data
  Future<void> clearAll() async {
    try {
      await _pref.clear();
    } catch (e) {
      throw CacheException(message: 'Failed to clear local data: $e');
    }
  }
}
