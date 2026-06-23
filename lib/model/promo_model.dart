class PromoModel {
  final String code;
  final String title;
  final int discountPercent;
  final bool freeShipping;
  final bool isActive;
  final int minPurchase;

  const PromoModel({
    required this.code,
    required this.title,
    required this.discountPercent,
    this.freeShipping = false,
    this.isActive = true,
    this.minPurchase = 20000,
  });

  PromoModel copyWith({
    String? code,
    String? title,
    int? discountPercent,
    bool? freeShipping,
    bool? isActive,
    int? minPurchase,
  }) =>
      PromoModel(
        code: code ?? this.code,
        title: title ?? this.title,
        discountPercent: discountPercent ?? this.discountPercent,
        freeShipping: freeShipping ?? this.freeShipping,
        isActive: isActive ?? this.isActive,
        minPurchase: minPurchase ?? this.minPurchase,
      );

  factory PromoModel.fromJson(Map<String, dynamic> json) {
    return PromoModel(
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      discountPercent: json['discountPercent'] ?? 0,
      freeShipping: json['freeShipping'] ?? false,
      isActive: json['isActive'] ?? true,
      minPurchase: json['minPurchase'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'title': title,
      'discountPercent': discountPercent,
      'freeShipping': freeShipping,
      'isActive': isActive,
      'minPurchase': minPurchase,
    };
  }
}