import 'package:warteg_app/model/address_model.dart';
import 'package:warteg_app/model/cart_item_model.dart';
import 'package:warteg_app/model/driver_mode.dart';
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
  final String? sellerNote;
  final DateTime createdAt;
  final OrderStatusModel status;
  final String? vaNumber;
  final DateTime expiredAt;
  final DateTime? cancelExpiredAt;
  final bool acceptedByAdmin;
  final DriverModel? driver;
  final String deliveryType; // 'delivery' atau 'pickup'

  OrderModel({
    required this.id,
    required this.items,
    required this.address,
    required this.paymentMethod,
    required this.subtotal,
    required this.ongkir,
    required this.discount,
    required this.total,
    this.sellerNote,
    required this.createdAt,
    required this.status,
    required this.expiredAt,
    required this.vaNumber,
    this.cancelExpiredAt,
    this.acceptedByAdmin = false,
    this.driver,
    this.deliveryType = 'delivery',
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
    String? sellerNote,
    DateTime? createdAt,
    OrderStatusModel? status,
    String? vaNumber,
    DateTime? expiredAt,
    DateTime? cancelExpiredAt,
    bool? acceptedByAdmin,
    DriverModel? driver,
    String? deliveryType,
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
      sellerNote: sellerNote ?? this.sellerNote,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      vaNumber: vaNumber ?? this.vaNumber,
      expiredAt: expiredAt ?? this.expiredAt,
      cancelExpiredAt: cancelExpiredAt ?? this.cancelExpiredAt,
      acceptedByAdmin: acceptedByAdmin ?? this.acceptedByAdmin,
      driver: driver ?? this.driver,
      deliveryType: deliveryType ?? this.deliveryType,
    );
  }

  bool get isPickup => deliveryType == 'pickup';

  // ================= TO JSON =================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((e) => e.toJson()).toList(),
      'address': address.toJson(),
      'paymentMethod': {
        'name': paymentMethod.name,
        'image': paymentMethod.image,
        'isSelected': paymentMethod.isSelected,
      },
      'subtotal': subtotal,
      'ongkir': ongkir,
      'discount': discount,
      'total': total,
      'sellerNote': sellerNote,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'vaNumber': vaNumber,
      'expiredAt': expiredAt.toIso8601String(),
      'cancelExpiredAt': cancelExpiredAt?.toIso8601String(),
      'acceptedByAdmin': acceptedByAdmin,
      'driver': driver?.toJson(),
      'deliveryType': deliveryType,
    };
  }

  // ================= FROM JSON =================

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      items: (json['items'] as List)
          .map((e) => CartItemModel.fromJson(e))
          .toList(),
      address: AddressModel.fromJson(json['address']),
      paymentMethod: PaymentMethodModel(
        name: json['paymentMethod']['name'],
        image: json['paymentMethod']['image'],
        isSelected: json['paymentMethod']['isSelected'] ?? false,
      ),
      subtotal: json['subtotal'],
      ongkir: json['ongkir'],
      discount: json['discount'],
      total: json['total'],
      sellerNote: json['sellerNote'] as String?,
      createdAt: DateTime.parse(json['createdAt']),
      status: OrderStatusModel.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      vaNumber: json['vaNumber'],
      expiredAt: DateTime.parse(json['expiredAt']),
      cancelExpiredAt: json['cancelExpiredAt'] != null
          ? DateTime.parse(json['cancelExpiredAt'])
          : null,
      acceptedByAdmin: json['acceptedByAdmin'] as bool? ?? false,
      driver: json['driver'] != null
          ? DriverModel.fromJson(json['driver'])
          : null,
      deliveryType: json['deliveryType'] ?? 'delivery',
    );
  }
}