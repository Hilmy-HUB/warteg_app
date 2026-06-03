import 'package:warteg_app/model/addon_model.dart';

class CartItemModel {
  final String id;
  final String menuName;
  final String image;
  final int basePrice;
  final List<AddOnModel> addOns;
  final String? notes;
  int quantity;
  bool isSelected;

  CartItemModel({
    required this.id,
    required this.menuName,
    required this.image,
    required this.basePrice,
    required this.addOns,
    required this.notes,
    required this.quantity,
    this.isSelected = true,
  });

  // Total harga add on per item
  int get totalAddOns => addOns.fold(0, (sum, e) => sum + e.price);

  // Harga satuan = basePrice + semua add on
  int get hargaSatuan => basePrice + totalAddOns;

  // Total keseluruhan = hargaSatuan * quantity
  int get totalHarga => hargaSatuan * quantity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menuName': menuName,
      'image': image,
      'basePrice': basePrice,
      'addOns': addOns.map((e) => e.toJson()).toList(),
      'quantity': quantity,
      'isSelected': isSelected,
      'notes': notes,
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'],
      menuName: json['menuName'],
      image: json['image'],
      basePrice: json['basePrice'],
      addOns: (json['addOns'] as List)
          .map((e) => AddOnModel.fromJson(e))
          .toList(),
      quantity: json['quantity'],
      notes: json['notes'],
      isSelected: json['isSelected'] ?? true,
    );
  }
}