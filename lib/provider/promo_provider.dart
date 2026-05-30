import 'package:flutter_riverpod/legacy.dart';
import 'package:warteg_app/model/promo_model.dart';

class PromoNotifier extends StateNotifier<List<PromoModel>> {
  PromoNotifier()
      : super([
          const PromoModel(code: 'SAVE5',   title: 'Diskon 5%',    discountPercent: 5),
          const PromoModel(code: 'HEMAT10', title: 'Diskon 10%',   discountPercent: 10),
          const PromoModel(code: 'ONGKIR0', title: 'Gratis Ongkir',discountPercent: 0, freeShipping: true),
        ]);

  void addPromo(PromoModel promo) {
    state = [...state, promo];
  }

  void toggleActive(String code) {
    state = [
      for (final p in state)
        if (p.code == code) p.copyWith(isActive: !p.isActive) else p,
    ];
  }

  void deletePromo(String code) {
    state = state.where((p) => p.code != code).toList();
  }

  // Hanya promo aktif yang bisa dipakai user
  List<PromoModel> get activePromos =>
      state.where((p) => p.isActive).toList();
}

final promoProvider =
    StateNotifierProvider<PromoNotifier, List<PromoModel>>(
  (ref) => PromoNotifier(),
);