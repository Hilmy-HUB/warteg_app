class AddOnModel {
  final String name;
  final int price;

  const AddOnModel({required this.name, required this.price});

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
      };

  factory AddOnModel.fromJson(Map<String, dynamic> json) => AddOnModel(
        name: json['name'],
        price: json['price'] ?? 0,
      );
}