import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warteg_app/model/payment_method.model.dart';

final paymentProvider =
    Provider<List<PaymentMethodModel>>(
  (ref) {
    return [
      PaymentMethodModel(
        name: "COD",
        image: "",
      ),

      PaymentMethodModel(
        name: "BCA",
        image: "",
      ),

      PaymentMethodModel(
        name: "BNI",
        image: "",
      ),

      PaymentMethodModel(
        name: "Mandiri",
        image: "",
      ),

      PaymentMethodModel(
        name: "Mastercard",
        image: "",
      ),

      PaymentMethodModel(
        name: "DANA",
        image: "",
      ),

      PaymentMethodModel(
        name: "GoPay",
        image: "",
      ),

      PaymentMethodModel(
        name: "OVO",
        image: "",
      ),
    ];
  },
);