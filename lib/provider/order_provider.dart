import 'dart:convert';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warteg_app/model/driver_mode.dart';
import 'package:warteg_app/model/order_model.dart';
import 'package:warteg_app/model/order_status_model.dart';

const String _ordersKey = 'orders';

class OrderNotifier extends StateNotifier<List<OrderModel>> {
  bool initialized = false;

  OrderNotifier() : super([]) {
    _loadFromPrefs(); // Load saat pertama kali init
  }

   Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_ordersKey);

    if (raw != null) {
      final List decoded = jsonDecode(raw);

      state = decoded
          .map((e) => OrderModel.fromJson(e))
          .toList();
    }

    initialized = true;
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

  Future<void> updateOrderStatus(
    String orderId,
    OrderStatusModel newStatus,
  ) async {
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

  Future<void> acceptOrder(String orderId) async {
    state = [
      for (final order in state)
        if (order.id == orderId)
          order.copyWith(
            acceptedByAdmin: true,
            status: OrderStatusModel.diproses,
          )
        else
          order,
    ];
    await _saveToPrefs();
  }

  Future<void> rejectOrder(String orderId) async {
    state = [
      for (final order in state)
        if (order.id == orderId)
          order.copyWith(status: OrderStatusModel.dibatalkan)
        else
          order,
    ];
    await _saveToPrefs();
  }

  Future<void> assignDriver(String orderId, DriverModel driver) async {
    state = [
      for (final order in state)
        if (order.id == orderId)
          order.copyWith(status: OrderStatusModel.diantar, driver: driver)
        else
          order,
    ];

    await _saveToPrefs();
  }

  Future<void> completeOrder(String orderId) async {
    state = [
      for (final order in state)
        if (order.id == orderId)
          order.copyWith(status: OrderStatusModel.selesai)
        else
          order,
    ];

    await _saveToPrefs();
  }

  Future<void> updateOrderStatusWithDriver(
    String orderId,
    OrderStatusModel newStatus,
    DriverModel driver,
  ) async {
    state = state.map((order) {
      if (order.id == orderId) {
        return order.copyWith(status: newStatus, driver: driver);
      }
      return order;
    }).toList();

    await _saveToPrefs();
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, List<OrderModel>>(
  (ref) => OrderNotifier(),
);
