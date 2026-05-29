import 'package:flutter_riverpod/legacy.dart';
import 'package:warteg_app/model/order_status_model.dart';

final orderTabProvider =
    StateProvider<OrderStatusModel>(
  (ref) => OrderStatusModel.bayar,
);