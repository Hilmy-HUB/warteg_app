// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:warteg_app/model/cart_item_model.dart';

class CartNotifier extends StateNotifier<List<CartItemModel>> {
  CartNotifier() : super([]);

  // tambah item ke cart
  void addToCart(CartItemModel item) {
    final index = state.indexWhere(
      (element) =>
          element.menuName == item.menuName &&
          element.addOns.toString() == item.addOns.toString(),
    );

    // kalau item sama → quantity ditambah
    if (index != -1) {
      state[index].quantity += item.quantity;
      state = [...state];
    } else {
      state = [...state, item];
    }
  }

  // hapus item
  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  // tambah quantity
  void increaseQty(String id) {
    state = state.map((item) {
      if (item.id == id) {
        item.quantity++;
      }
      return item;
    }).toList();
  }

  // kurang quantity
  void decreaseQty(String id) {
    state = state.map((item) {
      if (item.id == id && item.quantity > 1) {
        item.quantity--;
      }
      return item;
    }).toList();
  }

  // total semua
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