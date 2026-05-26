import 'package:flutter_riverpod/legacy.dart';
import 'package:warteg_app/model/order_model.dart';

class OrderNotifier
    extends StateNotifier<List<OrderModel>> {
  OrderNotifier() : super([]);

  void addOrder(OrderModel order) {
    state = [order, ...state];
  }
}

final orderProvider =
    StateNotifierProvider<
        OrderNotifier,
        List<OrderModel>>(
  (ref) => OrderNotifier(),
);