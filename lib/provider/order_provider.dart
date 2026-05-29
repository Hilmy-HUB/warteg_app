import 'package:flutter_riverpod/legacy.dart';
import 'package:warteg_app/model/order_model.dart';
import 'package:warteg_app/model/order_status_model.dart';

class OrderNotifier extends StateNotifier<List<OrderModel>> {
  OrderNotifier() : super([]);

  void addOrder(OrderModel order) {
    state = [order, ...state];
  }

  void updateOrderStatus(String orderId, OrderStatusModel newStatus) {
    state = [
      for (final order in state)
        if (order.id == orderId) order.copyWith(status: newStatus) else order,
    ];
  }

  OrderModel? getLatestOrder() {
    if (state.isEmpty) return null;
    return state.first;
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, List<OrderModel>>(
  (ref) => OrderNotifier(),
);
