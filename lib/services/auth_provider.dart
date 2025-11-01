import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  static final AuthProvider instance = AuthProvider._internal();
  AuthProvider._internal();

  static const _kKeyLoggedIn = 'logged_in';

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kKeyLoggedIn) ?? false;
  }

  Future<bool> login(String username, String password) async {
    // Replace with real backend auth later
    if (username == 'admin' && password == 'admin123') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kKeyLoggedIn, true);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kKeyLoggedIn);
    notifyListeners();
  }
}