// lib/model/menu_model.dart
//
// Model tunggal yang dipakai BAIK oleh halaman user maupun admin.
// ProductModel tidak lagi dibutuhkan — ganti semua referensinya ke MenuModel.

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

  /// Path asset ATAU URL gambar.
  /// Contoh asset  : 'assets/images/product/ayamkalio.png'
  /// Contoh network: 'https://example.com/img/ayam.jpg'
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
        id          : id          ?? this.id,
        name        : name        ?? this.name,
        description : description ?? this.description,
        price       : price       ?? this.price,
        category    : category    ?? this.category,
        isAvailable : isAvailable ?? this.isAvailable,
        imageUrl    : imageUrl    ?? this.imageUrl,
      );

  Map<String, dynamic> toJson() => {
        'id'         : id,
        'name'       : name,
        'description': description,
        'price'      : price,
        'category'   : category.name,
        'isAvailable': isAvailable,
        'imageUrl'   : imageUrl,
      };

  factory MenuModel.fromJson(Map<String, dynamic> json) => MenuModel(
        id          : json['id'] as String,
        name        : json['name'] as String,
        description : json['description'] as String? ?? '',
        price       : (json['price'] as num).toDouble(),
        category    : MenuCategory.values.byName(
                          json['category'] as String? ?? 'lauk'),
        isAvailable : json['isAvailable'] as bool? ?? true,
        imageUrl    : json['imageUrl'] as String?,
      );
}