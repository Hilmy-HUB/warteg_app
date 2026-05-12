import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // Register
  Future<String?> signup ({
    required String email,
    required String password,
  }) async {
    try {
      final res = await supabase.auth.signUp(
        email: email,
        password: password
      );
        
      if (res.user != null) {
        return null;
      }
      return 'Registrasi Gagal';
    } catch (e) {
      return e.toString();
    }
  }

  // Login
  Future<String?> signin ({
    required String email,
    required String password,
  }) async {
    try {
      final res = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
      if (res.user != null) {
        return null;
      }
      return 'Login Gagal';

    } catch (e) {
      return e.toString();
    }
  }

  // LogOut
  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  // Get Current User
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }
}