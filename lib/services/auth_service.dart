import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {

  // =========================
  // KEYS
  // =========================

  static const String usersKey = "users";
  static const String currentUserKey = "current_user";

  // =========================
  // CURRENT USER
  // =========================

  Map<String, dynamic>? currentUser;

  // =========================
  // REGISTER
  // =========================

  Future<String?> register({
    required String username,
    required String email,
    required String password,
  }) async {

    final prefs = await SharedPreferences.getInstance();

    final usersString = prefs.getString(usersKey);

    List users = [];

    // AMBIL USER LAMA
    if (usersString != null) {
      users = jsonDecode(usersString);
    }

    // CEK EMAIL SUDAH ADA
    final exists = users.any(
      (u) =>
          u['email']
              .toString()
              .toLowerCase() ==
          email.toLowerCase(),
    );

    if (exists) {
      return "Email sudah terdaftar";
    }

    // DATA USER BARU
    final newUser = {
      "username": username,
      "email": email,
      "password": password,
    };

    // TAMBAH USER
    users.add(newUser);

    // SIMPAN SEMUA USER
    await prefs.setString(
      usersKey,
      jsonEncode(users),
    );

    return null;
  }

  // =========================
  // LOGIN
  // =========================

  Future<String?> login({
    required String email,
    required String password,
  }) async {

    final prefs = await SharedPreferences.getInstance();

    final usersString = prefs.getString(usersKey);

    // BELUM ADA USER
    if (usersString == null) {
      return "Belum ada akun";
    }

    List users = jsonDecode(usersString);

    try {

      // CARI USER
      final user = users.firstWhere(
        (u) =>
            u['email']
                .toString()
                .toLowerCase() ==
            email.toLowerCase(),
      );

      // PASSWORD SALAH
      if (user['password'] != password) {
        return "Password salah";
      }

      // SIMPAN CURRENT USER
      currentUser = user;

      // SIMPAN SESSION LOGIN
      await prefs.setString(
        currentUserKey,
        jsonEncode(user),
      );

      return null;

    } catch (e) {
      return "Akun tidak ditemukan";
    }
  }

  // =========================
  // GET LOGGED IN USER
  // =========================

  Future<Map<String, dynamic>?> getLoggedInUser() async {

    final prefs = await SharedPreferences.getInstance();

    final userString = prefs.getString(currentUserKey);

    if (userString == null) {
      return null;
    }

    currentUser = jsonDecode(userString);

    return currentUser;
  }

  // =========================
  // LOGOUT
  // =========================

  Future<void> logout() async {

    final prefs = await SharedPreferences.getInstance();

    currentUser = null;

    await prefs.remove(currentUserKey);
  }
}