import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:warteg_app/services/auth_service.dart';

final authServiceProvider = Provider((ref) => AuthService());

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
      final service = ref.read(authServiceProvider);
      return AuthController(service);
    });


class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthService _service;

  AuthController(this._service) : super(const AsyncData(null));

  Future<void> register(String email, String password) async {
    state = const AsyncLoading();

    try {
      await _service.signup(email: email, password: password);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signin(String email, String password) async {
    state = const AsyncLoading();

    try {
      await _service.signin(email: email, password: password);
      state = AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> logout() async {
    await _service.logout();
  }
}
