import 'package:flutter/material.dart';
import 'package:warteg_app/model/order_status_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warteg_app/model/cart_item_model.dart';
import 'package:warteg_app/model/order_model.dart';
import 'package:warteg_app/provider/address_provider.dart';
import 'package:warteg_app/provider/checkout_provider.dart';
import 'package:warteg_app/provider/order_provider.dart';
import 'package:warteg_app/provider/payment_detail_provider.dart';
import 'package:warteg_app/screen/address_page.dart';
import 'package:warteg_app/screen/home.dart';
import 'package:warteg_app/screen/invoice_page.dart';
import 'package:warteg_app/screen/payment_page.dart';
import 'package:warteg_app/screen/promo_page.dart';
import 'package:warteg_app/theme/color_theme.dart';
import 'package:warteg_app/provider/cart_provider.dart';
import 'package:warteg_app/provider/notification_provider.dart';

class OrderDetailPage extends ConsumerStatefulWidget {
  final List<CartItemModel> items;

  const OrderDetailPage({super.key, required this.items});

  @override
  ConsumerState<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends ConsumerState<OrderDetailPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final checkoutNotifier = ref.read(checkoutProvider.notifier);

      checkoutNotifier.setItems(widget.items);

      // =========================
      // AMBIL DEFAULT ADDRESS
      // =========================
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

  Future<bool> _showPinDialog() async {
    final controller = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text("Security PIN"),
          content: TextField(
            controller: controller,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Masukkan PIN"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final savedPin = "123456"; // 🔥 nanti ambil dari user profile
                if (controller.text == savedPin) {
                  Navigator.pop(context, true);
                } else {
                  Navigator.pop(context, false);
                }
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _placeOrder(dynamic checkout) async {
    if (checkout.selectedAddress == null) {
      _showSnack('Please select a delivery address first', isError: true);
      return;
    }

    if (checkout.paymentMethod == null) {
      _showSnack('Please select a payment method first', isError: true);
      return;
    }

    final paymentName = checkout.paymentMethod!.name as String;

    // Only digital payments require saved account details
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
    }

    final vaNumber = "8808${DateTime.now().millisecondsSinceEpoch}";

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 400));
    final isBankVA =
        paymentName == "BCA" ||
        paymentName == "BNI" ||
        paymentName == "Mandiri";

    final isCOD = paymentName == "COD";

    final isDigital = digitalMethods.contains(paymentName);

    final order = OrderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: checkout.items,
      address: checkout.selectedAddress!,
      paymentMethod: checkout.paymentMethod!,
      subtotal: checkout.subtotal,
      ongkir: checkout.ongkir,
      discount: checkout.promoDiscount,
      total: checkout.total,
      createdAt: DateTime.now(),
      status: (isCOD || isDigital)
          ? OrderStatusModel.diproses
          : OrderStatusModel.bayar,
      vaNumber: (isCOD || isDigital) ? null : vaNumber,
      expiredAt: DateTime.now().add(const Duration(hours: 24)),
      cancelExpiredAt: isCOD || isDigital
          ? DateTime.now().add(const Duration(minutes: 2))
          : null,
    );

    ref.read(orderProvider.notifier).addOrder(order);

    ref
        .read(notificationProvider.notifier)
        .addNotification(
          title: 'Pesanan Baru',
          message: 'Pesanan #${order.id.substring(8)} berhasil dibuat',
          orderId: order.id,
        );

    ref
        .read(notificationProvider.notifier)
        .addNotification(
          title: 'Pesanan Dibuat',
          message:
              'Pesanan berhasil dibuat dengan total Rp ${_formatRupiah(order.total)}',
        );

    if (isBankVA) {
      ref.read(cartProvider.notifier).clearCart();
      ref.read(checkoutProvider.notifier).clearCheckout();
      setState(() => _isLoading = false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InvoicePage(order: order, vaNumber: vaNumber),
        ),
      );
      return;
    }

    // Auto status progression for non-bank orders
    Future.delayed(const Duration(seconds: 5), () {
      ref
          .read(orderProvider.notifier)
          .updateOrderStatus(order.id, OrderStatusModel.diproses);
    });
    Future.delayed(const Duration(seconds: 10), () {
      ref
          .read(orderProvider.notifier)
          .updateOrderStatus(order.id, OrderStatusModel.dijemput);
    });
    Future.delayed(const Duration(seconds: 15), () {
      ref
          .read(orderProvider.notifier)
          .updateOrderStatus(order.id, OrderStatusModel.diantar);
    });
    Future.delayed(const Duration(seconds: 20), () {
      ref
          .read(orderProvider.notifier)
          .updateOrderStatus(order.id, OrderStatusModel.selesai);
    });

    ref.read(cartProvider.notifier).clearCart();
    ref.read(checkoutProvider.notifier).clearCheckout();
    setState(() => _isLoading = false);

    if (mounted) {
      _showSnack('Order placed successfully!');
      await Future.delayed(const Duration(milliseconds: 600));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => Home()),
        (route) => false,
      );
    }
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
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final checkout = ref.watch(checkoutProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F4),

      // ── Bottom Bar ──────────────────────────────────────────
      bottomNavigationBar: _BottomBar(
        total: checkout.total,
        isLoading: _isLoading,
        onOrder: () => _placeOrder(checkout),
        formatRupiah: _formatRupiah,
      ),

      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──────────────────────────────────────
            _AppBar(),

            // ── Scrollable Body ──────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                children: [
                  // 1. Delivery Address
                  _SectionCard(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddressPage()),
                    ),
                    icon: Icons.location_on_rounded,
                    iconColor: ColorTheme.buttonPrimary,
                    title: 'Delivery Address',
                    subtitle: checkout.selectedAddress == null
                        ? 'Select a delivery address'
                        : checkout.selectedAddress!.fullAddress,
                    subtitleColor: checkout.selectedAddress == null
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2. Order Items
                  _SectionLabel(
                    label: 'Order Items (${checkout.items.length})',
                  ),
                  const SizedBox(height: 12),

                  ...checkout.items.map(
                    (item) =>
                        _ItemCard(item: item, formatRupiah: _formatRupiah),
                  ),

                  const SizedBox(height: 20),

                  // 3. Promo & Discount
                  _SectionLabel(label: 'Promo & Discount'),
                  const SizedBox(height: 12),
                  _SectionCard(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PromoPage()),
                    ),
                    icon: Icons.local_offer_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    iconBg: const Color(0xFFFFFBEB),
                    title: 'Use a Promo Code',
                    subtitle: checkout.selectedPromo == null
                        ? 'Tap to browse available promos'
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

                  // 4. Payment Method
                  _SectionLabel(label: 'Payment Method'),
                  const SizedBox(height: 12),

                  _SectionCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PaymentPage()),
                      );
                    },
                    icon: Icons.payment_rounded,
                    iconColor: ColorTheme.buttonPrimary,
                    title: 'Payment Method',
                    subtitle: checkout.paymentMethod == null
                        ? 'Choose payment method'
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

                  // 5. Order Summary
                  _SectionLabel(label: 'Order Summary'),
                  const SizedBox(height: 12),
                  _PriceSummary(
                    subtotal: checkout.subtotal,
                    ongkir: checkout.ongkir,
                    promoDiscount: checkout.promoDiscount,
                    total: checkout.total,
                    paymentMethod: checkout.paymentMethod?.name,
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

// ─── App Bar ─────────────────────────────────────────────────────────────────

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
            'Order Details',
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

// ─── Section Label ────────────────────────────────────────────────────────────

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

// ─── Section Card (Address / Promo) ──────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color iconColor;
  final Color? iconBg;
  final String title;
  final String subtitle;
  final Color subtitleColor;
  final Widget trailing;

  const _SectionCard({
    required this.onTap,
    required this.icon,
    required this.iconColor,
    this.iconBg,
    required this.title,
    required this.subtitle,
    required this.subtitleColor,
    required this.trailing,
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

// ─── Payment Chip ─────────────────────────────────────────────────────────────

class _PaymentChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentChip({
    required this.label,
    required this.selected,
    required this.onTap,
    x,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: selected ? ColorTheme.buttonPrimary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? ColorTheme.buttonPrimary : Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: ColorTheme.buttonPrimary.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.payment_rounded,
              size: 16,
              color: selected ? Colors.white : Colors.grey.shade400,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: selected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Item Card ────────────────────────────────────────────────────────────────

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
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
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

          // Details
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
                              '+ $e',
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
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Price
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

// ─── Price Summary ────────────────────────────────────────────────────────────

class _PriceSummary extends StatelessWidget {
  final int subtotal;
  final int ongkir;
  final int promoDiscount;
  final int total;
  final String? paymentMethod;
  final String Function(int) formatRupiah;

  const _PriceSummary({
    required this.subtotal,
    required this.ongkir,
    required this.promoDiscount,
    required this.total,
    required this.paymentMethod,
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
          const SizedBox(height: 10),
          _SummaryRow(
            label: 'Delivery Fee',
            icon: Icons.directions_bike_rounded,
            value: 'Rp ${formatRupiah(ongkir)}',
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            label: 'Promo Discount',
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
            label: 'Payment Method',
            icon: Icons.payment_rounded,
            value: paymentMethod ?? 'Not selected',
            valueColor: paymentMethod != null
                ? ColorTheme.buttonPrimary
                : Colors.grey.shade400,
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

// ─── Bottom Bar ───────────────────────────────────────────────────────────────

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
          // Total
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Payment',
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

          // Button
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
                          'Place Order',
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
