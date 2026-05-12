class CartItemModel {
  final String id;
  final String menuName;
  final String image;
  final int basePrice;
  final List<String> addOns;
  final int hargaSatuan;
  int quantity;
  bool isSelected;
 
  CartItemModel({
    required this.id,
    required this.menuName,
    required this.image,
    required this.basePrice,
    required this.addOns,
    required this.hargaSatuan,
    required this.quantity,
    this.isSelected = true,
  });
 
  int get totalHarga => hargaSatuan * quantity;
}
 