// lib/data/datasources/local/auth_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _kToken = 'session_token';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kToken);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
  }
}
