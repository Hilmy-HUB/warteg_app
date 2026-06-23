import 'package:flutter_riverpod/legacy.dart';
import 'package:warteg_app/model/address_model.dart';
import 'package:warteg_app/services/api_service.dart';

class AddressNotifier extends StateNotifier<List<AddressModel>> {
  AddressNotifier() : super([]) {
    loadAddresses();
  }

  // =========================
  // LOAD
  // =========================
  Future<void> loadAddresses() async {
    try {
      final List data = await ApiService.get('/api/addresses');
      state = data.map((e) => AddressModel.fromJson(e)).toList();
      _ensureSelected();
    } catch (e) {
      state = [];
    }
  }

  // =========================
  // ADD
  // =========================
  Future<void> addAddress(AddressModel address) async {
    try {
      final data = await ApiService.post('/api/addresses', {
        'label': address.label,
        'receiverName': address.receiverName,
        'phoneNumber': address.phone,
        'fullAddress': address.fullAddress,
        'note': address.note,
      });
      final newAddress = AddressModel.fromJson(data);
      state = [...state, newAddress];
      _ensureSelected();
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // UPDATE
  // =========================
  Future<void> updateAddress(AddressModel updated) async {
    try {
      final data = await ApiService.put('/api/addresses/${updated.id}', {
        'label': updated.label,
        'receiverName': updated.receiverName,
        'phoneNumber': updated.phone,
        'fullAddress': updated.fullAddress,
        'note': updated.note,
      });
      final newAddress = AddressModel.fromJson(data);
      state = state.map((e) => e.id == updated.id ? newAddress : e).toList();
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // REMOVE
  // =========================
  Future<void> removeAddress(String id) async {
    try {
      await ApiService.delete('/api/addresses/$id');
      state = state.where((e) => e.id != id).toList();
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // SELECT ADDRESS
  // =========================
  Future<void> selectAddress(String id) async {
    try {
      await ApiService.put('/api/addresses/$id/select', {});
      state = state.map((address) {
        return address.copyWith(isSelected: address.id == id);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // AUTO SELECT FIRST IF NONE
  // =========================
  void _ensureSelected() {
    if (state.isEmpty) return;

    final hasSelected = state.any((e) => e.isSelected);

    if (!hasSelected) {
      final firstId = state.first.id;
      selectAddress(firstId);
    }
  }

  // =========================
  // GET DEFAULT ADDRESS
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
  }
}

final addressProvider =
    StateNotifierProvider<AddressNotifier, List<AddressModel>>(
  (ref) => AddressNotifier(),
);