import 'package:flutter_riverpod/legacy.dart';
import 'package:warteg_app/model/driver_mode.dart';
import 'package:warteg_app/model/order_model.dart';
import 'package:warteg_app/model/order_status_model.dart';
import 'package:warteg_app/services/api_service.dart';

class OrderNotifier extends StateNotifier<List<OrderModel>> {
  bool initialized = false;

  OrderNotifier() : super([]) {
    loadOrders();
  }

  Future<void> loadOrders() async {
    try {
      final List data = await ApiService.get('/api/orders');
      state = data.map((e) => OrderModel.fromJson(e)).toList();
    } catch (e) {
      state = [];
    }
    initialized = true;
  }

  // =========================
  // ADD ORDER (Checkout)
  // =========================

  Future<OrderModel> addOrder(OrderModel order) async {
    try {
      final payload = {
        "deliveryType": order.deliveryType,
        "addressId": order.deliveryType == 'pickup' ? null : order.address.id,
        "paymentMethodName": order.paymentMethod.name,
        "paymentMethodImage": order.paymentMethod.image,
        "subtotal": order.subtotal,
        "ongkir": order.ongkir,
        "discount": order.discount,
        "total": order.total,
        "sellerNote": order.sellerNote,
        "items": order.items.map((item) {
          return {
            "productId": item.productId,
            "quantity": item.quantity,
            "price": item.basePrice,
            "addOns": item.addOns.map((a) => {
              "name": a.name,
              "price": a.price,
            }).toList(),
          };
        }).toList(),
      };

      final data = await ApiService.post('/api/orders', payload);
      
      final newOrder = order.copyWith(
        id: data['orderId'] ?? order.id,
        vaNumber: data['vaNumber'],
        expiredAt: data['expiredAt'] != null ? DateTime.parse(data['expiredAt']) : order.expiredAt,
        status: OrderStatusModel.bayar,
      );

      state = [newOrder, ...state];
      return newOrder;
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // UPDATE STATUS
  // =========================

  Future<void> updateOrderStatus(
    String orderId,
    OrderStatusModel newStatus,
  ) async {
    if (newStatus == OrderStatusModel.selesai) {
      await completeOrder(orderId);
      return;
    }
    if (newStatus == OrderStatusModel.siapDiambil) {
      await markReadyForPickup(orderId);
      return;
    }
    if (newStatus == OrderStatusModel.dibatalkan) {
      await rejectOrder(orderId);
      return;
    }
    
    state = [
      for (final order in state)
        if (order.id == orderId) order.copyWith(status: newStatus) else order,
    ];
  }

  // =========================
  // GET LATEST ORDER
  // =========================

  OrderModel? getLatestOrder() {
    if (state.isEmpty) return null;
    return state.first;
  }

  // =========================
  // ACTIONS (ADMIN / USER)
  // =========================

  Future<void> acceptOrder(String orderId) async {
    try {
      await ApiService.put('/api/orders/$orderId/confirm', {'action': 'accept'});
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
    } catch (e) {
      rethrow;
    }
  }

  Future<void> rejectOrder(String orderId) async {
    try {
      await ApiService.put('/api/orders/$orderId/confirm', {'action': 'reject'});
      state = [
        for (final order in state)
          if (order.id == orderId)
            order.copyWith(status: OrderStatusModel.dibatalkan)
          else
            order,
      ];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> assignDriver(String orderId, DriverModel driver) async {
    try {
      await ApiService.put('/api/orders/$orderId/assign-driver', {
        'driverName': driver.name,
        'driverPhone': driver.phone,
        'vehicleNumber': driver.vehicleNumber,
      });
      state = [
        for (final order in state)
          if (order.id == orderId)
            order.copyWith(status: OrderStatusModel.diantar, driver: driver)
          else
            order,
      ];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markReadyForPickup(String orderId) async {
    try {
      await ApiService.put('/api/orders/$orderId/assign-driver', {
        'driverName': 'Ambil Sendiri',
        'driverPhone': '0000000000',
        'vehicleNumber': 'Ambil Sendiri',
      });
      state = [
        for (final order in state)
          if (order.id == orderId)
            order.copyWith(status: OrderStatusModel.siapDiambil)
          else
            order,
      ];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> completeOrder(String orderId) async {
    try {
      await ApiService.put('/api/orders/$orderId/complete', {});
      state = [
        for (final order in state)
          if (order.id == orderId)
            order.copyWith(status: OrderStatusModel.selesai)
          else
            order,
      ];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateOrderStatusWithDriver(
    String orderId,
    OrderStatusModel newStatus,
    DriverModel driver,
  ) async {
    await assignDriver(orderId, driver);
  }

  Future<void> updateSellerNote(String orderId, String note) async {
    state = [
      for (final order in state)
        if (order.id == orderId) order.copyWith(sellerNote: note) else order,
    ];
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, List<OrderModel>>(
  (ref) => OrderNotifier(),
);
