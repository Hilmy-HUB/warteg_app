// lib/provider/menu_provider.dart

import 'dart:convert';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warteg_app/model/menu_model.dart';

const String _menuKey = 'menu_v1';

class MenuNotifier extends StateNotifier<List<MenuModel>> {
  MenuNotifier() : super([]) {
    _loadFromPrefs();
  }

  // ── Load ──────────────────────────────────────────────
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_menuKey);

    if (raw == null) {
      state = _seedMenu();
      await _saveToPrefs();
      return;
    }

    final List decoded = jsonDecode(raw);
    state = decoded.map((e) => MenuModel.fromJson(e)).toList();
  }

  // ── Save ──────────────────────────────────────────────
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(state.map((e) => e.toJson()).toList());
    await prefs.setString(_menuKey, encoded);
  }

  // ── Add ───────────────────────────────────────────────
  Future<void> addMenu(MenuModel menu) async {
    state = [...state, menu];
    await _saveToPrefs();
  }

  // ── Update ────────────────────────────────────────────
  Future<void> updateMenu(MenuModel updated) async {
    state = [
      for (final m in state) if (m.id == updated.id) updated else m,
    ];
    await _saveToPrefs();
  }

  // ── Toggle Availability ───────────────────────────────
  Future<void> toggleAvailability(String id) async {
    state = [
      for (final m in state)
        if (m.id == id) m.copyWith(isAvailable: !m.isAvailable) else m,
    ];
    await _saveToPrefs();
  }

  // ── Delete ────────────────────────────────────────────
  Future<void> deleteMenu(String id) async {
    state = state.where((m) => m.id != id).toList();
    await _saveToPrefs();
  }

  // ── Helper ────────────────────────────────────────────
  String generateId() => 'menu_${DateTime.now().millisecondsSinceEpoch}';

  // ── Seed Data ─────────────────────────────────────────
  List<MenuModel> _seedMenu() => [
        MenuModel(
          id: 'menu_1',
          name: 'Nasi Putih',
          description: 'Nasi putih pulen porsi sedang',
          price: 5000,
          category: MenuCategory.nasi,
        ),
        MenuModel(
          id: 'menu_2',
          name: 'Ayam Goreng',
          description: 'Ayam goreng bumbu kuning renyah',
          price: 15000,
          category: MenuCategory.lauk,
        ),
        MenuModel(
          id: 'menu_3',
          name: 'Tempe Orek',
          description: 'Tempe orek manis pedas',
          price: 8000,
          category: MenuCategory.lauk,
        ),
        MenuModel(
          id: 'menu_4',
          name: 'Sayur Lodeh',
          description: 'Sayur lodeh santan segar',
          price: 7000,
          category: MenuCategory.sayur,
        ),
        MenuModel(
          id: 'menu_5',
          name: 'Es Teh Manis',
          description: 'Teh manis dingin segar',
          price: 5000,
          category: MenuCategory.minuman,
        ),
        MenuModel(
          id: 'menu_6',
          name: 'Tahu Goreng',
          description: 'Tahu goreng garing bumbu bawang',
          price: 5000,
          category: MenuCategory.lauk,
        ),
      ];
}

final menuProvider =
    StateNotifierProvider<MenuNotifier, List<MenuModel>>(
  (ref) => MenuNotifier(),
);