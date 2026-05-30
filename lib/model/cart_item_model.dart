class CartItemModel {
  final String id;
  final String menuName;
  final String image;
  final int basePrice;
  final List<String> addOns;
  final int hargaSatuan;
  final String? notes;
  int quantity;
  bool isSelected;

  CartItemModel({
    required this.id,
    required this.menuName,
    required this.image,
    required this.basePrice,
    required this.addOns,
    required this.hargaSatuan,
    required this.notes,
    required this.quantity,
    this.isSelected = true,
  });

  int get totalHarga => hargaSatuan * quantity;

  // ================= TO JSON =================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menuName': menuName,
      'image': image,
      'basePrice': basePrice,
      'addOns': addOns,
      'hargaSatuan': hargaSatuan,
      'quantity': quantity,
      'isSelected': isSelected,
    };
  }

  // ================= FROM JSON =================

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'],
      menuName: json['menuName'],
      image: json['image'],
      basePrice: json['basePrice'],
      addOns: List<String>.from(json['addOns']),
      hargaSatuan: json['hargaSatuan'],
      quantity: json['quantity'],
      notes: json['notes'],
      isSelected: json['isSelected'] ?? true,
    );
  }
}