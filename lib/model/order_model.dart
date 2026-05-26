import 'package:warteg_app/model/address_model.dart';
import 'package:warteg_app/model/cart_item_model.dart';
import 'package:warteg_app/model/payment_method.model.dart';
import 'package:warteg_app/model/promo_model.dart';

class OrderModel {
  final String id;
  final List<CartItemModel> items;
  final AddressModel address;
  final PromoModel? promo;
  final PaymentMethodModel paymentMethod;
  final int subtotal;
  final int ongkir;
  final int discount;
  final int total;
  final String status;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.items,
    required this.address,
    this.promo,
    required this.paymentMethod,
    required this.subtotal,
    required this.ongkir,
    required this.discount,
    required this.total,
    this.status = "Diproses",
    required this.createdAt,
  });
}