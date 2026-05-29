import 'package:warteg_app/model/address_model.dart';
import 'package:warteg_app/model/cart_item_model.dart';
import 'package:warteg_app/model/order_status_model.dart';
import 'package:warteg_app/model/payment_method.model.dart';

class OrderModel {
  final String id;
  final List<CartItemModel> items;
  final AddressModel address;
  final PaymentMethodModel paymentMethod;

  final int subtotal;
  final int ongkir;
  final int discount;
  final int total;

  final DateTime createdAt;

  final OrderStatusModel status;

  final String? vaNumber;

  final DateTime expiredAt;

  final DateTime? cancelExpiredAt;

  OrderModel({
    required this.id,
    required this.items,
    required this.address,
    required this.paymentMethod,
    required this.subtotal,
    required this.ongkir,
    required this.discount,
    required this.total,
    required this.createdAt,
    required this.status,
    required this.expiredAt,
    required this.vaNumber,
    this.cancelExpiredAt,
  });

  OrderModel copyWith({
    String? id,
    List<CartItemModel>? items,
    AddressModel? address,
    PaymentMethodModel? paymentMethod,
    int? subtotal,
    int? ongkir,
    int? discount,
    int? total,
    DateTime? createdAt,
    OrderStatusModel? status,
    String? vaNumber,
    DateTime? expiredAt,
    DateTime? cancelExpiredAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      items: items ?? this.items,
      address: address ?? this.address,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      subtotal: subtotal ?? this.subtotal,
      ongkir: ongkir ?? this.ongkir,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      vaNumber: vaNumber ?? this.vaNumber,
      expiredAt: expiredAt ?? this.expiredAt,
      cancelExpiredAt: cancelExpiredAt ?? this.cancelExpiredAt,
    );
  }
}