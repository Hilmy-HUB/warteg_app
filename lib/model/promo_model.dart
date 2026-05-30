class PromoModel {
  final String code;
  final String title;
  final int discountPercent;
  final bool freeShipping;
  final bool isActive;

  const PromoModel({
    required this.code,
    required this.title,
    required this.discountPercent,
    this.freeShipping = false,
    this.isActive = true,
  });

  PromoModel copyWith({
    String? code,
    String? title,
    int? discountPercent,
    bool? freeShipping,
    bool? isActive,
  }) =>
      PromoModel(
        code: code ?? this.code,
        title: title ?? this.title,
        discountPercent: discountPercent ?? this.discountPercent,
        freeShipping: freeShipping ?? this.freeShipping,
        isActive: isActive ?? this.isActive,
      );
}