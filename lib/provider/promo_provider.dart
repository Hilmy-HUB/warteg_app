import 'package:flutter_riverpod/legacy.dart';
import 'package:warteg_app/model/promo_model.dart';
import 'package:warteg_app/services/api_service.dart';

class PromoNotifier extends StateNotifier<List<PromoModel>> {
  PromoNotifier() : super([]) {
    fetchPromos();
  }

  Future<void> fetchPromos() async {
    try {
      final List data = await ApiService.get('/api/promos');
      state = data.map((e) => PromoModel.fromJson(e)).toList();
    } catch (e) {
      state = [];
    }
  }

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

  List<PromoModel> get activePromos =>
      state.where((p) => p.isActive).toList();
}

final promoProvider =
    StateNotifierProvider<PromoNotifier, List<PromoModel>>(
  (ref) => PromoNotifier(),
);