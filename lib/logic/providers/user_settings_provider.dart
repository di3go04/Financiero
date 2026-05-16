import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettingsProvider extends ChangeNotifier {
  bool _isPrivacyMode = false;
  bool _useBiometrics = false;
  String _userName = 'Usuario';

  bool get isPrivacyMode => _isPrivacyMode;
  bool get useBiometrics => _useBiometrics;
  String get userName => _userName;

  UserSettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isPrivacyMode = prefs.getBool('privacy_mode') ?? false;
    _useBiometrics = prefs.getBool('use_biometrics') ?? false;
    _userName = prefs.getString('user_name') ?? 'Usuario';
    notifyListeners();
  }

  Future<void> togglePrivacyMode() async {
    _isPrivacyMode = !_isPrivacyMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('privacy_mode', _isPrivacyMode);
    notifyListeners();
  }

  Future<void> setUseBiometrics(bool value) async {
    _useBiometrics = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_biometrics', _useBiometrics);
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    notifyListeners();
  }
}


