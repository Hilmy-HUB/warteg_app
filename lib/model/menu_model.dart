// lib/model/menu_model.dart

enum MenuCategory { nasi, lauk, sayur, minuman, snack }

extension MenuCategoryX on MenuCategory {
  String get label => switch (this) {
        MenuCategory.nasi    => 'Nasi',
        MenuCategory.lauk    => 'Lauk',
        MenuCategory.sayur   => 'Sayur',
        MenuCategory.minuman => 'Minuman',
        MenuCategory.snack   => 'Snack',
      };
}

class MenuModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final MenuCategory category;
  final bool isAvailable;
  final String? imageUrl;

  const MenuModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.isAvailable = true,
    this.imageUrl,
  });

  MenuModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    MenuCategory? category,
    bool? isAvailable,
    String? imageUrl,
  }) =>
      MenuModel(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        price: price ?? this.price,
        category: category ?? this.category,
        isAvailable: isAvailable ?? this.isAvailable,
        imageUrl: imageUrl ?? this.imageUrl,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'category': category.name,
        'isAvailable': isAvailable,
        'imageUrl': imageUrl,
      };

  factory MenuModel.fromJson(Map<String, dynamic> json) => MenuModel(
        id: json['id'],
        name: json['name'],
        description: json['description'] ?? '',
        price: (json['price'] as num).toDouble(),
        category: MenuCategory.values.byName(json['category'] ?? 'nasi'),
        isAvailable: json['isAvailable'] ?? true,
        imageUrl: json['imageUrl'],
      );
}