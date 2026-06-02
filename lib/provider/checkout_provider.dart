import 'package:flutter_riverpod/legacy.dart';
import 'package:warteg_app/model/address_model.dart';
import 'package:warteg_app/model/cart_item_model.dart';
import 'package:warteg_app/model/payment_method.model.dart';
import 'package:warteg_app/model/promo_model.dart';

class CheckoutState {
  final List<CartItemModel> items;
  final AddressModel? selectedAddress;
  final PromoModel? selectedPromo;
  final PaymentMethodModel? paymentMethod;
  final String deliveryType; // 'delivery' atau 'pickup'

  CheckoutState({
    this.items = const [],
    this.selectedAddress,
    this.selectedPromo,
    this.paymentMethod,
    this.deliveryType = 'delivery',
  });

  int get subtotal => items.fold(0, (sum, item) => sum + item.totalHarga);

  int get ongkir => 0;

  int get promoDiscount {
    if (selectedPromo == null) return 0;
    return ((subtotal * selectedPromo!.discountPercent) / 100).round();
  }

  int get total => subtotal + ongkir - promoDiscount;

  CheckoutState copyWith({
    List<CartItemModel>? items,
    AddressModel? selectedAddress,
    PaymentMethodModel? paymentMethod,
    String? deliveryType,
    bool clearAddress = false,
    bool clearPromo = false,
    Object? selectedPromo = _sentinel,
  }) {
    return CheckoutState(
      items: items ?? this.items,
      selectedAddress: clearAddress
          ? null
          : (selectedAddress ?? this.selectedAddress),
      selectedPromo: selectedPromo == _sentinel
          ? this.selectedPromo
          : selectedPromo as PromoModel?,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      deliveryType: deliveryType ?? this.deliveryType,
    );
  }

  static const _sentinel = Object();
}

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  CheckoutNotifier() : super(CheckoutState());

  void setDefaultAddress(AddressModel address) {
    // Hanya set kalau mode delivery
    if (state.deliveryType == 'delivery') {
      state = state.copyWith(selectedAddress: address);
    }
  }

  void setItems(List<CartItemModel> items) {
    state = state.copyWith(items: items);
  }

  void selectAddress(AddressModel address) {
    state = state.copyWith(selectedAddress: address);
  }

  void selectPromo(PromoModel? promo) {
    state = state.copyWith(selectedPromo: promo);
  }

  void clearPromo() {
    state = CheckoutState(
      items: state.items,
      selectedAddress: state.selectedAddress,
      paymentMethod: state.paymentMethod,
      deliveryType: state.deliveryType,
    );
  }

  void selectPayment(PaymentMethodModel method) {
    state = state.copyWith(paymentMethod: method);
  }

  void setDeliveryType(String type) {
    // Kalau ganti ke pickup, clear alamat yang dipilih
    state = state.copyWith(deliveryType: type, clearAddress: type == 'pickup');
  }

  void clearCheckout() {
    state = CheckoutState();
  }
}

final checkoutProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>(
  (ref) => CheckoutNotifier(),
);
