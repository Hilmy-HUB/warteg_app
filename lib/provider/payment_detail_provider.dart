import 'dart:convert';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warteg_app/model/payment_detail_mode.dart';

class PaymentDetailNotifier extends StateNotifier<List<PaymentDetailModel>> {
  PaymentDetailNotifier() : super([]) {
    loadData();
  }

  static const _key = "payment_details";

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw != null) {
      final decoded = jsonDecode(raw) as List;
      state = decoded
          .map((e) => PaymentDetailModel.fromJson(e))
          .toList();
    }
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(state.map((e) => e.toJson()).toList()),
    );
  }

  void saveOrUpdate(PaymentDetailModel data) {
    final index =
        state.indexWhere((e) => e.methodName == data.methodName);

    if (index >= 0) {
      state = [
        ...state.sublist(0, index),
        data,
        ...state.sublist(index + 1),
      ];
    } else {
      state = [...state, data];
    }

    saveData();
  }

  PaymentDetailModel? getByMethod(String method) {
    try {
      return state.firstWhere((e) => e.methodName == method);
    } catch (_) {
      return null;
    }
  }
}

final paymentDetailProvider =
    StateNotifierProvider<PaymentDetailNotifier, List<PaymentDetailModel>>(
  (ref) => PaymentDetailNotifier(),
);