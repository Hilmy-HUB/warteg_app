import 'dart:convert';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kHistoryKey = 'purchase_history';

class PurchaseHistoryNotifier extends StateNotifier<Map<String, int>> {
  PurchaseHistoryNotifier() : super({}) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kHistoryKey);
    if (raw != null) {
      final Map decoded = jsonDecode(raw);
      state = decoded.map((k, v) => MapEntry(k as String, v as int));
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kHistoryKey, jsonEncode(state));
  }

  // Panggil ini saat order berhasil
  void recordPurchase(List<String> menuNames) {
    final updated = Map<String, int>.from(state);
    for (final name in menuNames) {
      updated[name] = (updated[name] ?? 0) + 1;
    }
    state = updated;
    _save();
  }

  // Return nama menu diurutkan dari yang paling sering dibeli
  List<String> get topMenuNames {
    final sorted = state.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) => e.key).toList();
  }
}

final purchaseHistoryProvider =
    StateNotifierProvider<PurchaseHistoryNotifier, Map<String, int>>(
  (_) => PurchaseHistoryNotifier(),
);