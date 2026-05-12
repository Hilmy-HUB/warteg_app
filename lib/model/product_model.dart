class ProductModel {
  final String id;
  final String menuName;
  final String description;
  final int price;
  String? notes;
  final String image;


  ProductModel({
    required this.id,
    required this.menuName,
    required this.description,
    required this.price,
    required this.image,
  });
}