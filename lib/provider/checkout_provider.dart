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

  CheckoutState({
    this.items = const [],
    this.selectedAddress,
    this.selectedPromo,
    this.paymentMethod,
  });

  int get subtotal => items.fold(0, (sum, item) => sum + item.totalHarga);

  int get ongkir => selectedPromo?.freeShipping == true ? 0 : 10000;

  int get promoDiscount {
    if (selectedPromo == null) return 0;
    return ((subtotal * selectedPromo!.discountPercent) / 100).round();
  }

  int get total => subtotal + ongkir - promoDiscount;

  CheckoutState copyWith({
    List<CartItemModel>? items,
    AddressModel? selectedAddress,
    PromoModel? selectedPromo,
    PaymentMethodModel? paymentMethod,
  }) {
    return CheckoutState(
      items: items ?? this.items,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedPromo: selectedPromo ?? this.selectedPromo,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  CheckoutNotifier() : super(CheckoutState());

  void setDefaultAddress(AddressModel address) {
    state = state.copyWith(selectedAddress: address);
  }

  void setItems(List<CartItemModel> items) {
    state = state.copyWith(items: items);
  }

  void selectAddress(AddressModel address) {
    state = state.copyWith(selectedAddress: address);
  }

  void selectPromo(PromoModel promo) {
    state = state.copyWith(selectedPromo: promo);
  }

  // tambahkan method ini di dalam CheckoutNotifier
  void clearPromo() {
    state = CheckoutState(
      items: state.items,
      selectedAddress: state.selectedAddress,
      paymentMethod: state.paymentMethod,
      // selectedPromo dikosongkan
    );
  }

  void selectPayment(PaymentMethodModel method) {
    state = state.copyWith(paymentMethod: method);
  }

  void clearCheckout() {
    state = CheckoutState();
  }
}

final checkoutProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>(
  (ref) => CheckoutNotifier(),
);
