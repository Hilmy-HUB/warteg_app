import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warteg_app/services/api_service.dart';

class AuthService {
  static const String currentUserKey = "current_user";
  static const String keyIsLoggedIn = 'isLogin';
  static const String keyToken = 'token';

  Map<String, dynamic>? currentUser;

  Future<String?> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      await ApiService.post('/api/auth/register', {
        'username': username,
        'email': email,
        'password': password,
      }, requireAuth: false);
      return null; // Success
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final data = await ApiService.post('/api/auth/login', {
        'email': email,
        'password': password,
      }, requireAuth: false);

      final token = data['token'] as String;
      final user = data['user'] as Map<String, dynamic>;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyToken, token);
      await prefs.setString(currentUserKey, jsonEncode(user));
      await prefs.setBool(keyIsLoggedIn, true);
      await prefs.setString("username", user['username'] ?? '');
      await prefs.setString("email", user['email'] ?? '');
      await prefs.setString("role", user['role'] ?? 'user');

      currentUser = user;
      return null; // Success
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<Map<String, dynamic>?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(currentUserKey);
    if (userString == null) return null;
    currentUser = jsonDecode(userString);
    return currentUser;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(currentUserKey);
    await prefs.remove(keyIsLoggedIn);
    await prefs.remove("username");
    await prefs.remove("email");
    await prefs.remove("role");
    await prefs.remove(keyToken);
    currentUser = null;
  }
}