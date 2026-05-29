class PaymentDetailModel {
  final String methodName;

  // Card (Mastercard)
  final String? cardNumber;
  final String? expiry;
  final String? cvv;

  // E-wallet
  final String? phoneNumber;
  final String? pin;

  PaymentDetailModel({
    required this.methodName,
    this.cardNumber,
    this.expiry,
    this.cvv,
    this.phoneNumber,
    this.pin,
  });

  PaymentDetailModel copyWith({
    String? cardNumber,
    String? expiry,
    String? cvv,
    String? phoneNumber,
    String? pin,
  }) {
    return PaymentDetailModel(
      methodName: methodName,
      cardNumber: cardNumber ?? this.cardNumber,
      expiry: expiry ?? this.expiry,
      cvv: cvv ?? this.cvv,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      pin: pin ?? this.pin,
    );
  }

  Map<String, dynamic> toJson() => {
        "methodName": methodName,
        "cardNumber": cardNumber,
        "expiry": expiry,
        "cvv": cvv,
        "phoneNumber": phoneNumber,
        "pin": pin,
      };

  factory PaymentDetailModel.fromJson(Map<String, dynamic> json) {
    return PaymentDetailModel(
      methodName: json["methodName"],
      cardNumber: json["cardNumber"],
      expiry: json["expiry"],
      cvv: json["cvv"],
      phoneNumber: json["phoneNumber"],
      pin: json["pin"],
    );
  }
}