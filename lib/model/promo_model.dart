class PromoModel {
  final String code;
  final String title;
  final int discountPercent;
  final bool freeShipping;

  PromoModel({
    required this.code,
    required this.title,
    required this.discountPercent,
    this.freeShipping = false,
  });
}