import 'dart:convert';

import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warteg_app/model/cart_item_model.dart';

class CartNotifier extends StateNotifier<List<CartItemModel>> {
  CartNotifier() : super([]) {
    loadCart();
  }

  // ================= LOAD CART =================

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString('cart_items');

    if (data != null) {
      final List decoded = jsonDecode(data);

      state = decoded
          .map((e) => CartItemModel.fromJson(e))
          .toList();
    }
  }

  // ================= SAVE CART =================

  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();

    final encoded =
        jsonEncode(state.map((e) => e.toJson()).toList());

    await prefs.setString('cart_items', encoded);
  }

  // ================= ADD TO CART =================

  void addToCart(CartItemModel item) {
    final index = state.indexWhere(
      (element) =>
          element.menuName == item.menuName &&
          element.addOns.map((a) => a.name).join(', ') == item.addOns.map((a) => a.name).join(', '),
    );

    // kalau item sama → quantity ditambah
    if (index != -1) {
      state[index].quantity += item.quantity;
      state = [...state];
    } else {
      state = [...state, item];
    }

    saveCart();
  }

  // ================= REMOVE ITEM =================

  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();

    saveCart();
  }

  // ================= INCREASE QTY =================

  void increaseQty(String id) {
    state = state.map((item) {
      if (item.id == id) {
        item.quantity++;
      }
      return item;
    }).toList();

    saveCart();
  }

  // ================= DECREASE QTY =================

  void decreaseQty(String id) {
    state = state.map((item) {
      if (item.id == id && item.quantity > 1) {
        item.quantity--;
      }
      return item;
    }).toList();

    saveCart();
  }

  // ================= UPDATE CART =================

  void updateCart(List<CartItemModel> items) {
    state = [...items];

    saveCart();
  }

  // ================= CLEAR CART =================

  void clearCart() {
    state = [];

    saveCart();
  }

  // ================= TOTAL PRICE =================

  int get totalCartPrice {
    return state.fold(
      0,
      (total, item) => total + item.totalHarga,
    );
  }
}

final cartProvider =
    StateNotifierProvider<CartNotifier, List<CartItemModel>>(
  (ref) => CartNotifier(),
);