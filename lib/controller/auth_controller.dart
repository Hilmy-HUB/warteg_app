import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warteg_app/services/auth_service.dart';

final authServiceProvider = Provider((ref) => AuthService());

final currentUserProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>(
      (ref) => AuthController(ref.read(authServiceProvider), ref),
    );

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthService _service;
  final Ref ref;

  AuthController(this._service, this.ref) : super(const AsyncData(null));

  // ======================================
  // REGISTER
  // ======================================

  Future<String?> register(String username, String email, String password) async {
    state = const AsyncLoading();
    final result = await _service.register(
      username: username,
      email: email,
      password: password,
    );
    state = const AsyncData(null);
    return result;
  }

  // ======================================
  // LOGIN
  // ======================================

  // 🔐 Hardcode admin credentials
  static const String _adminEmail    = 'admin@warteg.com';
  static const String _adminPassword = 'admin123';

  Future<String?> login(String email, String password) async {
    try {
      state = const AsyncLoading();

      String role;
      String username;

      // ✅ Cek apakah admin
      if (email == _adminEmail && password == _adminPassword) {
        role     = 'admin';
        username = 'Admin';
      } else {
        // ✅ Cek user biasa via AuthService
        final result = await _service.login(email: email, password: password);
        if (result != null) return result; // return pesan error

        role     = 'user';
        username = email.split('@')[0]; // ambil nama dari email
      }

      // Simpan ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLogin',   true);
      await prefs.setString('email',    email);
      await prefs.setString('username', username);
      await prefs.setString('role',     role);

      // Update provider
      ref.read(currentUserProvider.notifier).state = {
        'username': username,
        'email':    email,
        'role':     role,
      };

      return null; // sukses

    } catch (e) {
      return e.toString();
    } finally {
      state = const AsyncData(null);
    }
  }

  // ======================================
  // LOGOUT
  // ======================================

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    ref.read(currentUserProvider.notifier).state = null;
  }
}