import 'package:flutter/material.dart';
import 'package:warteg_app/model/order_status_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warteg_app/model/cart_item_model.dart';
import 'package:warteg_app/model/order_model.dart';
import 'package:warteg_app/provider/address_provider.dart';
import 'package:warteg_app/provider/chat_provider.dart';
import 'package:warteg_app/provider/checkout_provider.dart';
import 'package:warteg_app/provider/navbar_provider.dart';
import 'package:warteg_app/provider/order_provider.dart';
import 'package:warteg_app/provider/order_tab_provider.dart';
import 'package:warteg_app/provider/payment_detail_provider.dart';
import 'package:warteg_app/screen/address_page.dart';
import 'package:warteg_app/screen/home.dart';
import 'package:warteg_app/screen/invoice_page.dart';
import 'package:warteg_app/screen/payment_page.dart';
import 'package:warteg_app/screen/promo_page.dart';
import 'package:warteg_app/theme/color_theme.dart';
import 'package:warteg_app/provider/cart_provider.dart';
import 'package:warteg_app/provider/notification_provider.dart';
import 'package:warteg_app/provider/purchase_history_provider.dart';

// ─── Konstanta lokasi pickup restoran ────────────────────────────────────────
// Ganti sesuai alamat warteg kamu
const String _kPickupAddress =
    'Warteg Bahari — Jl. Raya Tapos No.102, Ciriung, Kec. Cibinong, Kabupaten Bogor, Jawa Barat 16918';
const String _kPickupEstimate =
    'Pesanan siap dalam ±15–20 menit setelah dikonfirmasi';
// Jarak dummy — nanti bisa diganti dengan kalkulasi GPS asli
const double _kJarakDummy = 2.4; // dalam km

// // Koordinat dummy warteg
// const double _kWartegsLat = -6.4833;
// const double _kWartegLng = 106.8317;

// Hitung jarak dummy (Haversine formula)
// double _hitungJarak(double userLat, double userLng) {
//   const double earthRadius = 6371;
//   final double dLat = (userLat - _kWartegsLat) * (3.14159265358979 / 180);
//   final double dLng = (userLng - _kWartegLng) * (3.14159265358979 / 180);
//   final double a =
//       (dLat / 2 * dLat / 2) +
//       (_kWartegsLat * 3.14159265358979 / 180).cos() *
//           (userLat * 3.14159265358979 / 180).cos() *
//           (dLng / 2 * dLng / 2);
//   final double c = 2 * (a.abs() < 1 ? a : 1).asin();
//   return earthRadius * c;
// }

class OrderDetailPage extends ConsumerStatefulWidget {
  final List<CartItemModel> items;

  const OrderDetailPage({super.key, required this.items});

  @override
  ConsumerState<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends ConsumerState<OrderDetailPage> {
  bool _isLoading = false;

  Future<bool> _showPinDialog(String paymentName) async {
    final paymentDetail = ref
        .read(paymentDetailProvider.notifier)
        .getByMethod(paymentName);

    if (paymentDetail == null || paymentDetail.pin == null) return false;

    bool result = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _PinDialog(
        paymentName: paymentName,
        correctPin: paymentDetail.pin!,
        onSuccess: () {
          result = true;
          Navigator.pop(ctx);
        },
        onCancel: () {
          result = false;
          Navigator.pop(ctx);
        },
      ),
    );

    return result;
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final checkoutNotifier = ref.read(checkoutProvider.notifier);
      checkoutNotifier.setItems(widget.items);

      final defaultAddress = ref.read(addressProvider.notifier).defaultAddress;
      if (defaultAddress != null) {
        checkoutNotifier.setDefaultAddress(defaultAddress);
      }
    });
  }

  static String _formatRupiah(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();
    final mod = s.length % 3;
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (i - mod) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  Future<void> _placeOrder(dynamic checkout) async {
    final isPickup = checkout.deliveryType == 'pickup';

    // Validasi alamat hanya untuk delivery
    if (!isPickup && checkout.selectedAddress == null) {
      _showSnack('Pilih alamat pengiriman terlebih dahulu', isError: true);
      return;
    }

    if (checkout.paymentMethod == null) {
      _showSnack('Pilih metode pembayaran terlebih dahulu', isError: true);
      return;
    }

    final paymentName = checkout.paymentMethod!.name as String;
    const digitalMethods = {"Mastercard", "DANA", "GoPay", "OVO"};

    if (digitalMethods.contains(paymentName)) {
      final paymentDetail = ref
          .read(paymentDetailProvider.notifier)
          .getByMethod(paymentName);
      if (paymentDetail == null) {
        _showSnack(
          'Please enter your $paymentName account details first',
          isError: true,
        );
        return;
      }

      // PIN dulu sebelum loading dan addOrder
      final pinValid = await _showPinDialog(paymentName);
      if (!pinValid) return;
    }

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(milliseconds: 400));

      final isBankVA =
          paymentName == "BCA" ||
          paymentName == "BNI" ||
          paymentName == "Mandiri";
      final isCOD = paymentName == "COD";
      final vaNumber = "8808${DateTime.now().millisecondsSinceEpoch}";

      // Pickup langsung tunggu konfirmasi (skip bayar VA)
      final initialStatus = isBankVA
          ? OrderStatusModel.bayar
          : OrderStatusModel.tungguKonfirmasi;

      // Untuk pickup, buat AddressModel dummy berisi info lokasi restoran
      final orderAddress = isPickup
          ? _buildPickupAddress()
          : checkout.selectedAddress!;

      final order = OrderModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        items: checkout.items,
        address: orderAddress,
        paymentMethod: checkout.paymentMethod!,
        subtotal: checkout.subtotal,
        ongkir: checkout.ongkir, // sudah 0 kalau pickup dari CheckoutState
        discount: checkout.promoDiscount,
        total: checkout.total,
        createdAt: DateTime.now(),
        status: initialStatus,
        vaNumber: isBankVA ? vaNumber : null,
        expiredAt: DateTime.now().add(const Duration(hours: 24)),
        cancelExpiredAt: isCOD
            ? DateTime.now().add(const Duration(minutes: 2))
            : null,
        deliveryType: checkout.deliveryType,
      );

      await ref.read(orderProvider.notifier).addOrder(order);

      final itemLines = order.items
          .map((item) {
            final addOnText = item.addOns.isNotEmpty
                ? '\n   + ${item.addOns.map((a) => a.name).join(', ')}'
                : '';
            return '• ${item.menuName} x${item.quantity}$addOnText';
          })
          .join('\n');

      final deliveryLabel = order.deliveryType == 'delivery'
          ? 'Delivery'
          : 'Pickup';
      final systemText =
          '🛒 Pesanan Baru ($deliveryLabel)\n$itemLines\n\nTotal: Rp ${_formatRupiah(order.total)}';

      ref.read(chatProvider(order.id).notifier).sendSystemMessage(systemText);

      ref
          .read(notificationProvider.notifier)
          .addNotification(
            title: isPickup
                ? 'Pesanan Pickup Dibuat'
                : 'Pesanan Berhasil Dibuat',
            message: isPickup
                ? 'Pesanan #${order.id.substring(8)} siap diambil setelah dikonfirmasi restoran.'
                : (!isPickup && isBankVA)
                ? 'Selesaikan pembayaran virtual account untuk pesanan #${order.id.substring(8)}.'
                : 'Pesanan #${order.id.substring(8)} menunggu konfirmasi restoran.',
            orderId: order.id,
          );

      ref
          .read(purchaseHistoryProvider.notifier)
          .recordPurchase(
            checkout.items
                .map((item) => item.menuName as String)
                .toList()
                .cast<String>(),
          );

      ref
          .read(cartProvider.notifier)
          .removeCheckedOutItems(widget.items.map((e) => e.id).toList());
      ref.read(checkoutProvider.notifier).clearCheckout();

      if (!mounted) return;

      // Bank VA tetap ke invoice page
      if (isBankVA) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => InvoicePage(order: order, vaNumber: vaNumber),
          ),
        );
        return;
      }

      _showSnack(
        isPickup
            ? 'Pesanan pickup berhasil! Menunggu konfirmasi restoran.'
            : 'Pesanan berhasil dibuat! Menunggu konfirmasi restoran.',
      );
      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;

      if (isPickup) {
        ref.read(navbarIndexProvider.notifier).state =
            3; // ganti 3 dengan index PickupPage kamu
      } else {
        ref.read(orderTabProvider.notifier).state =
            OrderStatusModel.tungguKonfirmasi;
        ref.read(navbarIndexProvider.notifier).state =
            2; // ganti 2 dengan index OrderPage kamu
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => Home()),
        (route) => false,
      );
    } catch (e, s) {
      debugPrint('ERROR ORDER: $e');
      debugPrintStack(stackTrace: s);
      _showSnack('Terjadi kesalahan: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Buat AddressModel dummy untuk pickup
  /// (OrderModel butuh address, tapi pickup tidak pakai alamat user)
  dynamic _buildPickupAddress() {
    // Import AddressModel di atas sudah ada lewat checkout_provider
    return (ref.read(addressProvider.notifier).defaultAddress)?.copyWith(
          fullAddress: _kPickupAddress,
          label: 'Pickup',
          note: _kPickupEstimate,
        ) ??
        // Fallback kalau user belum punya alamat sama sekali
        _PickupAddressModel(
          fullAddress: _kPickupAddress,
          note: _kPickupEstimate,
        );
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        backgroundColor: isError
            ? const Color(0xFFEF4444)
            : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final checkout = ref.watch(checkoutProvider);
    final isPickup = checkout.deliveryType == 'pickup';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F4),
      bottomNavigationBar: _BottomBar(
        total: checkout.total,
        isLoading: _isLoading,
        onOrder: () => _placeOrder(checkout),
        formatRupiah: _formatRupiah,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _AppBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                children: [
                  // ── Toggle Dikirim / Pickup ──────────────────────────────
                  _DeliveryToggle(
                    selected: checkout.deliveryType,
                    onChanged: (val) {
                      ref.read(checkoutProvider.notifier).setDeliveryType(val);
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Alamat / Info Pickup ─────────────────────────────────
                  if (isPickup)
                    const _PickupInfoCard()
                  else
                    _SectionCard(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddressPage()),
                      ),
                      icon: Icons.location_on_rounded,
                      iconColor: ColorTheme.buttonPrimary,
                      title: 'Alamat Pengiriman',
                      subtitle: checkout.selectedAddress == null
                          ? 'Pilih alamat pengiriman'
                          : checkout.selectedAddress!.fullAddress,

                      subtitleColor: checkout.selectedAddress == null
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                      // ── TAMBAHAN: badge jarak ──
                      distanceLabel: checkout.selectedAddress == null
                          ? null
                          : 'Jarak ke warteg: ${_kJarakDummy.toStringAsFixed(1)} km dari kamu',
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey,
                      ),
                    ),

                  const SizedBox(height: 20),
                  _SectionLabel(
                    label: 'Item Pesanan (${checkout.items.length})',
                  ),
                  const SizedBox(height: 12),
                  ...checkout.items.map(
                    (item) =>
                        _ItemCard(item: item, formatRupiah: _formatRupiah),
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel(label: 'Promo & Diskon'),
                  const SizedBox(height: 12),
                  _SectionCard(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PromoPage()),
                    ),
                    icon: Icons.local_offer_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    iconBg: const Color(0xFFFFFBEB),
                    title: 'Gunakan Kode Promo',
                    subtitle: checkout.selectedPromo == null
                        ? 'Ketuk untuk melihat promo yang tersedia'
                        : checkout.selectedPromo!.code,

                    subtitleColor: checkout.selectedPromo == null
                        ? Colors.grey.shade400
                        : const Color(0xFFF59E0B),
                    trailing: checkout.selectedPromo != null
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '- Rp ${_formatRupiah(checkout.promoDiscount)}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFF59E0B),
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.grey,
                          ),
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel(label: 'Payment Method'),
                  const SizedBox(height: 12),
                  _SectionCard(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PaymentPage()),
                    ),
                    icon: Icons.payment_rounded,
                    iconColor: ColorTheme.buttonPrimary,
                    title: 'Metode Pembayaran',
                    subtitle: checkout.paymentMethod == null
                        ? 'Pilih metode pembayaran'
                        : checkout.paymentMethod!.name,
                    subtitleColor: checkout.paymentMethod == null
                        ? Colors.grey.shade400
                        : Colors.black87,
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel(label: 'Order Summary'),
                  const SizedBox(height: 12),
                  _PriceSummary(
                    subtotal: checkout.subtotal,
                    ongkir: checkout.ongkir,
                    promoDiscount: checkout.promoDiscount,
                    total: checkout.total,
                    paymentMethod: checkout.paymentMethod?.name,
                    isPickup: isPickup,
                    formatRupiah: _formatRupiah,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pickup address fallback (kalau user belum punya alamat) ─────────────────
// Ini hanya dipakai internal di _buildPickupAddress()
class _PickupAddressModel {
  final String fullAddress;
  final String note;
  _PickupAddressModel({required this.fullAddress, required this.note});
}

// ─── Toggle Dikirim / Pickup ─────────────────────────────────────────────────

class _DeliveryToggle extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _DeliveryToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _ToggleOption(
            label: 'Dikirim',
            icon: Icons.delivery_dining_rounded,
            isSelected: selected == 'delivery',
            onTap: () => onChanged('delivery'),
          ),
          _ToggleOption(
            label: 'Ambil Sendiri',
            icon: Icons.storefront_rounded,
            isSelected: selected == 'pickup',
            onTap: () => onChanged('pickup'),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? ColorTheme.buttonPrimary
                    : Colors.grey.shade400,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? ColorTheme.buttonPrimary
                      : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Info Card Pickup ────────────────────────────────────────────────────────

class _PickupInfoCard extends StatelessWidget {
  const _PickupInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: Color(0xFF10B981),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lokasi Pickup',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _kPickupAddress,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  _kPickupEstimate,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.5,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets (tidak berubah) ─────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 17,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Detail Pesanan',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
        letterSpacing: -0.2,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color iconColor;
  final Color? iconBg;
  final String title;
  final String subtitle;
  final Color subtitleColor;
  final Widget trailing;
  final String? distanceLabel;

  const _SectionCard({
    required this.onTap,
    required this.icon,
    required this.iconColor,
    this.iconBg,
    required this.title,
    required this.subtitle,
    required this.subtitleColor,
    required this.trailing,
    this.distanceLabel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg ?? iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.5,
                      color: subtitleColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Di dalam Column > children, setelah Text(subtitle, ...)
                  if (distanceLabel != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.directions_walk_rounded,
                          size: 12,
                          color: ColorTheme.buttonPrimary.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          distanceLabel!,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: ColorTheme.buttonPrimary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final CartItemModel item;
  final String Function(int) formatRupiah;

  const _ItemCard({required this.item, required this.formatRupiah});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: item.image.startsWith('http')
                ? Image.network(
                    item.image,
                    width: 78,
                    height: 78,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 78,
                      height: 78,
                      color: Colors.grey.shade100,
                      child: Icon(
                        Icons.image_not_supported_rounded,
                        color: Colors.grey.shade300,
                        size: 28,
                      ),
                    ),
                  )
                : Image.asset(
                    item.image,
                    width: 78,
                    height: 78,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 78,
                      height: 78,
                      color: Colors.grey.shade100,
                      child: Icon(
                        Icons.image_not_supported_rounded,
                        color: Colors.grey.shade300,
                        size: 28,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.menuName,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity}× Rp ${formatRupiah(item.hargaSatuan)}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    color: Colors.grey.shade500,
                  ),
                ),
                if (item.addOns.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    children: item.addOns
                        .map(
                          (e) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: ColorTheme.buttonPrimary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '+ ${e.name}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: ColorTheme.buttonPrimary,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (item.notes != null && item.notes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.sticky_note_2_outlined,
                          size: 13,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            item.notes!,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11.5,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Rp ${formatRupiah(item.totalHarga)}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w800,
              fontSize: 13.5,
              color: ColorTheme.buttonPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceSummary extends StatelessWidget {
  final int subtotal;
  final int ongkir;
  final int promoDiscount;
  final int total;
  final String? paymentMethod;
  final bool isPickup;
  final String Function(int) formatRupiah;

  const _PriceSummary({
    required this.subtotal,
    required this.ongkir,
    required this.promoDiscount,
    required this.total,
    required this.paymentMethod,
    required this.isPickup,
    required this.formatRupiah,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _SummaryRow(label: 'Subtotal', value: 'Rp ${formatRupiah(subtotal)}'),
          if (!isPickup) ...[
            const SizedBox(height: 10),
            _SummaryRow(
              label: 'Ongkos Kirim',
              icon: Icons.directions_bike_rounded,
              value: 'Gratis',
              valueColor: const Color(0xFF10B981),
            ),
          ],
          const SizedBox(height: 10),
          _SummaryRow(
            label: 'Promo Diskon',
            icon: Icons.local_offer_rounded,
            value: promoDiscount == 0
                ? 'Rp 0'
                : '- Rp ${formatRupiah(promoDiscount)}',
            valueColor: promoDiscount > 0
                ? const Color(0xFF10B981)
                : Colors.grey.shade600,
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            label: 'Metode Pembayaran',
            icon: Icons.payment_rounded,
            value: paymentMethod ?? 'Tidak dipilih',
            valueColor: paymentMethod != null
                ? ColorTheme.buttonPrimary
                : Colors.grey.shade400,
            fontSize: 13,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: List.generate(
                30,
                (i) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 1,
                    color: i.isEven ? Colors.grey.shade200 : Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
          _SummaryRow(
            label: 'Total',
            value: 'Rp ${formatRupiah(total)}',
            isBold: true,
            valueColor: ColorTheme.buttonPrimary,
            fontSize: 16,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final bool isBold;
  final Color? valueColor;
  final double fontSize;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.icon,
    this.isBold = false,
    this.valueColor,
    this.fontSize = 13.5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: Colors.grey.shade400),
          const SizedBox(width: 6),
        ],
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: Colors.grey.shade600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int total;
  final bool isLoading;
  final VoidCallback onOrder;
  final String Function(int) formatRupiah;

  const _BottomBar({
    required this.total,
    required this.isLoading,
    required this.onOrder,
    required this.formatRupiah,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Pembayaran',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.5,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Rp ${formatRupiah(total)}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    color: ColorTheme.buttonPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTheme.buttonPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 28),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: isLoading ? null : onOrder,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.2,
                      ),
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_bag_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Pesan Sekarang',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── PIN Dialog ───────────────────────────────────────────────────────────────

class _PinDialog extends StatefulWidget {
  final String paymentName;
  final String correctPin;
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const _PinDialog({
    required this.paymentName,
    required this.correctPin,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(6, (_) => TextEditingController());
    _focusNodes = List.generate(6, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _checkPin() {
    final entered = _controllers.map((c) => c.text).join();
    if (entered.length < 6) return;

    if (entered == widget.correctPin) {
      widget.onSuccess();
    } else {
      setState(() => _hasError = true);
      for (final c in _controllers) c.clear();
      _focusNodes[0].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: ColorTheme.buttonPrimary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_rounded,
                color: ColorTheme.buttonPrimary,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Masukkan PIN ${widget.paymentName}',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Konfirmasi pembayaran dengan PIN kamu',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (i) {
                return SizedBox(
                  width: 38,
                  height: 44,
                  child: TextField(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    obscureText: true,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                    autofillHints: const [],
                    enableSuggestions: false,
                    autocorrect: false,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: _hasError
                          ? Colors.red.shade50
                          : Colors.grey.shade100,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _hasError
                              ? Colors.red
                              : ColorTheme.buttonPrimary,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _hasError
                              ? Colors.red.shade200
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                    ),
                    onChanged: (val) {
                      if (!mounted) return;
                      setState(() => _hasError = false);

                      if (val.isEmpty) {
                        if (i > 0) _focusNodes[i - 1].requestFocus();
                        return;
                      }

                      if (!RegExp(r'^\d$').hasMatch(val)) {
                        _controllers[i].clear();
                        return;
                      }

                      if (i < 5) {
                        _focusNodes[i + 1].requestFocus();
                      } else {
                        _checkPin();
                      }
                    },
                  ),
                );
              }),
            ),
            if (_hasError) ...[
              const SizedBox(height: 12),
              Text(
                'PIN salah, coba lagi',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Colors.red.shade400,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: widget.onCancel,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _checkPin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorTheme.buttonPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Konfirmasi',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
