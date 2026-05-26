class PaymentMethodModel {
  final String name;
  final String image;
  final bool isSelected;

  PaymentMethodModel({
    required this.name,
    required this.image,
    this.isSelected = false,
  });

  PaymentMethodModel copyWith({
    String? name,
    String? image,
    bool? isSelected,
  }) {
    return PaymentMethodModel(
      name: name ?? this.name,
      image: image ?? this.image,
      isSelected:
          isSelected ?? this.isSelected,
    );
  }
}