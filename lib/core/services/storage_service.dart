import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError();
});

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static const String _onboardingKey = 'onboarding_complete';
  static const String _userNameKey = 'user_name';

  Future<void> setOnboardingComplete() async {
    await _prefs.setBool(_onboardingKey, true);
  }

  bool get isOnboardingComplete => _prefs.getBool(_onboardingKey) ?? false;

  Future<void> setUserName(String name) async {
    await _prefs.setString(_userNameKey, name);
  }

  String get userName => _prefs.getString(_userNameKey) ?? 'Unknown';
}
