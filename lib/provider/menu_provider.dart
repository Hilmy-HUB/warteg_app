import 'package:flutter_riverpod/legacy.dart';
import 'package:warteg_app/model/menu_model.dart';
import 'package:warteg_app/services/api_service.dart';

class MenuNotifier extends StateNotifier<List<MenuModel>> {
  MenuNotifier() : super([]) {
    fetchMenus();
  }

  Future<void> fetchMenus() async {
    try {
      final List data = await ApiService.get('/api/products');
      state = data.map((e) => MenuModel.fromJson(e)).toList();
    } catch (e) {
      state = [];
    }
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Future<void> addMenu(MenuModel menu) async {
    try {
      final data = await ApiService.post('/api/products', {
        'name': menu.name,
        'description': menu.description,
        'price': menu.price,
        'category': menu.category.name,
        'imageUrl': menu.imageUrl,
      });
      final newMenu = MenuModel.fromJson(data);
      state = [...state, newMenu];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateMenu(MenuModel updated) async {
    try {
      final data = await ApiService.put('/api/products/${updated.id}', {
        'name': updated.name,
        'description': updated.description,
        'price': updated.price,
        'category': updated.category.name,
        'isAvailable': updated.isAvailable,
        'imageUrl': updated.imageUrl,
      });
      final newMenu = MenuModel.fromJson(data);
      state = [
        for (final m in state)
          if (m.id == updated.id) newMenu else m,
      ];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMenu(String id) async {
    try {
      await ApiService.delete('/api/products/$id');
      state = state.where((m) => m.id != id).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleAvailability(String id) async {
    try {
      final menu = state.firstWhere((m) => m.id == id);
      await updateMenu(menu.copyWith(isAvailable: !menu.isAvailable));
    } catch (e) {
      rethrow;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  List<MenuModel> byCategory(MenuCategory cat) =>
      state.where((m) => m.category == cat).toList();

  List<MenuModel> get available => state.where((m) => m.isAvailable).toList();
}

final menuProvider =
    StateNotifierProvider<MenuNotifier, List<MenuModel>>(
  (_) => MenuNotifier(),
);