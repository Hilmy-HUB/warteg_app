import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:warteg_app/services/auth_service.dart';

// ======================================
// AUTH SERVICE
// ======================================

final authServiceProvider = Provider(
  (ref) => AuthService(),
);

// ======================================
// CURRENT USER
// ======================================

final currentUserProvider =
    StateProvider<Map<String, dynamic>?>(
  (ref) => null,
);

// ======================================
// AUTH CONTROLLER
// ======================================

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>(
  (ref) => AuthController(
    ref.read(authServiceProvider),
    ref,
  ),
);

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthService _service;
  final Ref ref;

  AuthController(this._service, this.ref)
      : super(const AsyncData(null));

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

  Future<String?> login(
    String email,
    String password,
  ) async {
    state = const AsyncLoading();

    final result = await _service.login(
      email: email,
      password: password,
    );

    // LOGIN BERHASIL
    if (result == null) {

      // AMBIL DATA USER DARI SERVICE
      final user = _service.currentUser;

      // SIMPAN USER LOGIN
      ref.read(currentUserProvider.notifier).state = {
        "username": user?["username"],
        "email": user?["email"],
      };
    }

    state = const AsyncData(null);

    return result;
  }

  // ======================================
  // LOGOUT
  // ======================================

  Future<void> logout() async {

  await Supabase.instance.client.auth.signOut();

  ref.read(currentUserProvider.notifier).state = null;
}
}