import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warteg_app/model/promo_model.dart';

final promoProvider =
    Provider<List<PromoModel>>((ref) {
  return [
    PromoModel(
      code: "SAVE5",
      title: "Diskon 5%",
      discountPercent: 5,
    ),

    PromoModel(
      code: "HEMAT10",
      title: "Diskon 10%",
      discountPercent: 10,
    ),

    PromoModel(
      code: "ONGKIR0",
      title: "Gratis Ongkir",
      discountPercent: 0,
      freeShipping: true,
    ),
  ];
});