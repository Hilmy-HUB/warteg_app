import 'dart:convert';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warteg_app/model/address_model.dart';

class AddressNotifier extends StateNotifier<List<AddressModel>> {
  AddressNotifier() : super([]) {
    loadAddresses();
  }

  static const String storageKey = 'saved_addresses';

  // =========================
  // LOAD
  // =========================
  Future<void> loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(storageKey);

    if (data == null) {
      state = [];
      return;
    }

    final List decoded = jsonDecode(data);

    state = decoded.map((e) => AddressModel.fromJson(e)).toList();

    _ensureSelected();
  }

  // =========================
  // ADD
  // =========================
  Future<void> addAddress(AddressModel address) async {
    state = [...state, address];
    await saveAddresses();
  }

  // =========================
  // UPDATE
  // =========================
  Future<void> updateAddress(AddressModel updated) async {
    state = state.map((e) {
      return e.id == updated.id ? updated : e;
    }).toList();

    await saveAddresses();
  }

  // =========================
  // REMOVE
  // =========================
  Future<void> removeAddress(String id) async {
    state = state.where((e) => e.id != id).toList();
    await saveAddresses();
  }

  // =========================
  // SELECT ADDRESS
  // =========================
  Future<void> selectAddress(String id) async {
    state = state.map((address) {
      return address.copyWith(isSelected: address.id == id);
    }).toList();

    await saveAddresses();
  }

  // =========================
  // SAVE
  // =========================
  Future<void> saveAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      storageKey,
      jsonEncode(state.map((e) => e.toJson()).toList()),
    );
  }

  // =========================
  // AUTO SELECT FIRST IF NONE
  // =========================
  void _ensureSelected() {
    if (state.isEmpty) return;

    final hasSelected = state.any((e) => e.isSelected);

    if (!hasSelected) {
      state = state.map((e) {
        return e.copyWith(isSelected: e.id == state.first.id);
      }).toList();

      saveAddresses();
    }
  }

  // =========================
  // GET DEFAULT ADDRESS (INI PENTING)
  // =========================
  AddressModel? get defaultAddress {
    try {
      return state.firstWhere((e) => e.isSelected);
    } catch (_) {
      return state.isNotEmpty ? state.first : null;
    }
  }

  // =========================
  // CLEAR
  // =========================
  Future<void> clearAddresses() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKey);
  }
}

// =========================
// PROVIDER
// =========================
final addressProvider =
    StateNotifierProvider<AddressNotifier, List<AddressModel>>(
  (ref) => AddressNotifier(),
);