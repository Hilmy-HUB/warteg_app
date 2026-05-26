import 'dart:convert';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warteg_app/model/address_model.dart';

class AddressNotifier extends StateNotifier<List<AddressModel>> {
  AddressNotifier() : super([]) {
    loadAddresses();
  }

  static const String storageKey = 'saved_addresses';

  Future<void> loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(storageKey);

    if (data == null) {
      state = [];
      return;
    }

    final List decoded = jsonDecode(data);

    state = decoded.map((e) => AddressModel.fromJson(e)).toList();

    // auto ensure ada selected
    _ensureSelected();
  }

  Future<void> updateAddress(AddressModel updated) async {
    state = state.map((e) {
      if (e.id == updated.id) {
        return updated;
      }
      return e;
    }).toList();

    await saveAddresses();
  }

  Future<void> saveAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      storageKey,
      jsonEncode(state.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> addAddress(AddressModel address) async {
    state = [...state, address];
    await saveAddresses();
  }

  Future<void> removeAddress(String id) async {
    state = state.where((e) => e.id != id).toList();
    await saveAddresses();
  }

  Future<void> selectAddress(String id) async {
    state = state.map((address) {
      return address.copyWith(isSelected: address.id == id);
    }).toList();

    await saveAddresses();
  }

  void _ensureSelected() {
    if (state.isEmpty) return;

    final hasSelected = state.any((e) => e.isSelected);

    if (!hasSelected) {
      state = state
          .map((e) => e.copyWith(isSelected: e.id == state.first.id))
          .toList();

      saveAddresses();
    }
  }

  Future<void> clearAddresses() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKey);
  }
}

final addressProvider =
    StateNotifierProvider<AddressNotifier, List<AddressModel>>(
      (ref) => AddressNotifier(),
    );
