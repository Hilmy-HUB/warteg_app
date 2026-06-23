import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
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

  Future<String?> register(
    String username,
    String email,
    String password,
  ) async {
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

  Future<String?> login(String email, String password) async {
    try {
      state = const AsyncLoading();

      final result = await _service.login(email: email, password: password);
      if (result != null) return result;

      final user = _service.currentUser;
      if (user == null) return "Terjadi kesalahan saat memuat data profil";

      // Update provider
      ref.read(currentUserProvider.notifier).state = {
        'username': user['username'],
        'email': user['email'],
        'role': user['role'],
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
    await _service.logout();
    ref.read(currentUserProvider.notifier).state = null;
  }
}
