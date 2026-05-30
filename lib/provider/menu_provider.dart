import 'dart:convert';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warteg_app/data/menu_data.dart';
import 'package:warteg_app/model/menu_model.dart';

const _kMenuKey = 'saved_menus';

class MenuNotifier extends StateNotifier<List<MenuModel>> {
  MenuNotifier() : super([]) {
    _load();
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kMenuKey);
    if (raw == null) {
      // Pertama kali: pakai data awal
      state = List.from(initialMenus);
      await _save();
    } else {
      final List decoded = jsonDecode(raw);
      state = decoded.map((e) => MenuModel.fromJson(e)).toList();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(state.map((m) => m.toJson()).toList());
    await prefs.setString(_kMenuKey, encoded);
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  void addMenu(MenuModel menu) {
    state = [...state, menu];
    _save();
  }

  void updateMenu(MenuModel updated) {
    state = [
      for (final m in state)
        if (m.id == updated.id) updated else m,
    ];
    _save();
  }

  void deleteMenu(String id) {
    state = state.where((m) => m.id != id).toList();
    _save();
  }

  void toggleAvailability(String id) {
    state = [
      for (final m in state)
        if (m.id == id) m.copyWith(isAvailable: !m.isAvailable) else m,
    ];
    _save();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String generateId() {
    final existingIds = state.map((m) => int.tryParse(m.id) ?? 0).toList();
    final maxId =
        existingIds.isEmpty ? 0 : existingIds.reduce((a, b) => a > b ? a : b);
    return (maxId + 1).toString();
  }

  List<MenuModel> byCategory(MenuCategory cat) =>
      state.where((m) => m.category == cat).toList();

  List<MenuModel> get available => state.where((m) => m.isAvailable).toList();
}

final menuProvider =
    StateNotifierProvider<MenuNotifier, List<MenuModel>>(
  (_) => MenuNotifier(),
);