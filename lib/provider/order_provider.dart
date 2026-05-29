import 'dart:convert';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warteg_app/model/order_model.dart';
import 'package:warteg_app/model/order_status_model.dart';


const String _ordersKey = 'orders';

class OrderNotifier extends StateNotifier <List<OrderModel>> {
  OrderNotifier() : super([]) {
    _loadFromPrefs(); // Load saat pertama kali init
  }

  // =========================
  // LOAD DARI PREFS
  // =========================

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_ordersKey);

    if (raw == null) return;

    final List decoded = jsonDecode(raw);
    state = decoded.map((e) => OrderModel.fromJson(e)).toList();
  }

  // =========================
  // SIMPAN KE PREFS
  // =========================

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(state.map((e) => e.toJson()).toList());
    await prefs.setString(_ordersKey, encoded);
  }

  // =========================
  // ADD ORDER
  // =========================

  Future<void> addOrder(OrderModel order) async {
    state = [order, ...state];
    await _saveToPrefs();
  }

  // =========================
  // UPDATE STATUS
  // =========================

  Future<void> updateOrderStatus(String orderId, OrderStatusModel newStatus) async {
    state = [
      for (final order in state)
        if (order.id == orderId) order.copyWith(status: newStatus) else order,
    ];
    await _saveToPrefs();
  }

  // =========================
  // GET LATEST ORDER
  // =========================

  OrderModel? getLatestOrder() {
    if (state.isEmpty) return null;
    return state.first;
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, List<OrderModel>>(
  (ref) => OrderNotifier(),
);