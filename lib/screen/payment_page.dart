import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warteg_app/provider/checkout_provider.dart';
import 'package:warteg_app/provider/payment_detail_provider.dart';
import 'package:warteg_app/provider/payment_provider.dart';
import 'package:warteg_app/screen/payment_input_page.dart';
import 'package:warteg_app/theme/color_theme.dart';

class PaymentPage extends ConsumerStatefulWidget {
  const PaymentPage({super.key});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  bool bankExpanded = false;
  bool ewalletExpanded = false;

  // Methods that require a form
  static const _digitalMethods = {"Mastercard", "DANA", "GoPay", "OVO"};
  // Methods that are Bank VA
  static const _bankMethods = {"BCA", "BNI", "Mandiri"};

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              msg,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
            ),
          ],
        ),
        backgroundColor: isError
            ? const Color(0xFFEF4444)
            : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleTap(dynamic method) {
    final name = method.name as String;

    final saved = ref.read(paymentDetailProvider.notifier).getByMethod(name);

    // selalu set payment dulu
    ref.read(checkoutProvider.notifier).selectPayment(method);

    if (_digitalMethods.contains(name)) {
      // ✅ kalau sudah ada data → skip input page
      if (saved != null) {
        _showSnack("Payment sudah tersimpan");
        HapticFeedback.lightImpact();
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PaymentInputPage(methodName: name)),
      );
      return;
    }

    _showSnack('Metode pembayaran sukses dipilih');
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final paymentMethods = ref.watch(paymentProvider);
    final checkout = ref.watch(checkoutProvider);
    final savedDetails = ref.watch(paymentDetailProvider);

    final cod = paymentMethods.where((e) => e.name == "COD").toList();
    final banks = paymentMethods
        .where((e) => _bankMethods.contains(e.name))
        .toList();
    final digitalPayments = paymentMethods
        .where((e) => _digitalMethods.contains(e.name))
        .toList();

    // Build a set of method names that have saved details
    final configuredMethods = savedDetails.map((e) => e.methodName).toSet();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F4),
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
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
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    "Metode Pembayaran",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ),

            // ── Header card ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      ColorTheme.primaryColor,
                      ColorTheme.secondaryColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: ColorTheme.primaryColor.withOpacity(0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                    const SizedBox(width: 18),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pilih Metode Pembayaran",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Pilih metode pembayaran yang Anda inginkan untuk pengalaman checkout yang lebih cepat.",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12.5,
                              height: 1.5,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── List ──────────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                children: [
                  // COD
                  const _SectionTitle(title: "Cash On Delivery"),
                  const SizedBox(height: 12),
                  ...cod.map(
                    (method) => _PaymentTile(
                      method: method,
                      isSelected: checkout.paymentMethod?.name == method.name,
                      isConfigured: false, // COD never needs config
                      requiresForm: false,
                      onTap: () => _handleTap(method),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Bank Transfer
                  _DropdownHeader(
                    title: "Bank Transfer",
                    expanded: bankExpanded,
                    onTap: () => setState(() => bankExpanded = !bankExpanded),
                  ),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 250),
                    crossFadeState: bankExpanded
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Column(
                      children: banks
                          .map(
                            (method) => Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: _PaymentTile(
                                method: method,
                                isSelected:
                                    checkout.paymentMethod?.name == method.name,
                                isConfigured: false, // Bank VA no form
                                requiresForm: false,
                                onTap: () => _handleTap(method),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    secondChild: const SizedBox(),
                  ),

                  const SizedBox(height: 22),

                  // Digital Payment
                  _DropdownHeader(
                    title: "Digital Payment",
                    expanded: ewalletExpanded,
                    onTap: () =>
                        setState(() => ewalletExpanded = !ewalletExpanded),
                  ),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 250),
                    crossFadeState: ewalletExpanded
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Column(
                      children: digitalPayments
                          .map(
                            (method) => Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: _PaymentTile(
                                method: method,
                                isSelected:
                                    checkout.paymentMethod?.name == method.name,
                                // Show "Configured" badge if saved data exists
                                isConfigured: configuredMethods.contains(
                                  method.name,
                                ),
                                requiresForm: true,
                                onTap: () => _handleTap(method),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    secondChild: const SizedBox(),
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

// ─── Section Title ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }
}

// ─── Dropdown Header ──────────────────────────────────────────────────────────

class _DropdownHeader extends StatelessWidget {
  final String title;
  final bool expanded;
  final VoidCallback onTap;

  const _DropdownHeader({
    required this.title,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: ColorTheme.buttonPrimary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: ColorTheme.buttonPrimary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            AnimatedRotation(
              duration: const Duration(milliseconds: 250),
              turns: expanded ? 0.5 : 0,
              child: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Payment Tile ─────────────────────────────────────────────────────────────

class _PaymentTile extends StatelessWidget {
  final dynamic method;
  final bool isSelected;
  final bool isConfigured;
  final bool requiresForm;
  final VoidCallback onTap;

  const _PaymentTile({
    required this.method,
    required this.isSelected,
    required this.isConfigured,
    required this.requiresForm,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? ColorTheme.buttonPrimary : Colors.grey.shade200,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? ColorTheme.buttonPrimary.withOpacity(0.10)
                  : Colors.black.withOpacity(0.04),
              blurRadius: isSelected ? 18 : 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: isSelected
                    ? ColorTheme.buttonPrimary.withOpacity(0.12)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                _getIcon(method.name),
                color: isSelected
                    ? ColorTheme.buttonPrimary
                    : Colors.grey.shade500,
                size: 28,
              ),
            ),

            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          method.name,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      // "Selected" badge
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: ColorTheme.buttonPrimary.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Dipilih",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: ColorTheme.buttonPrimary,
                            ),
                          ),
                        ),
                      // "Configured ✓" badge for digital methods with saved data
                      if (!isSelected && isConfigured) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.10),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 11,
                                color: Color(0xFF10B981),
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Tersimpan",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    _getDesc(method.name),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.5,
                      height: 1.4,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Icon(
                        requiresForm
                            ? Icons.edit_rounded
                            : Icons.flash_on_rounded,
                        size: 14,
                        color: requiresForm
                            ? Colors.grey.shade500
                            : Colors.amber.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        requiresForm
                            ? "Klik untuk melihat detail"
                            : _getFeature(method.name),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Circle checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? ColorTheme.buttonPrimary
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? ColorTheme.buttonPrimary
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case "COD":
        return Icons.payments_rounded;
      case "BCA":
      case "BNI":
      case "Mandiri":
        return Icons.account_balance_rounded;
      case "Mastercard":
        return Icons.credit_card_rounded;
      case "DANA":
      case "GoPay":
      case "OVO":
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  String _getDesc(String name) {
    switch (name) {
      case "COD":
        return "Bayar saat pesanan tiba di lokasi Anda.";
      case "BCA":
        return "Pembayaran mudah melalui Bank BCA virtual account.";
      case "BNI":
        return "Pembayaran aman menggunakan virtual account BNI.";
      case "Mandiri":
        return "Transfer mudah melalui Bank Mandiri.";
      case "Mastercard":
        return "Pembayaran aman menggunakan Mastercard.";
      case "DANA":
        return "Pembayaran digital menggunakan DANA.";
      case "GoPay":
        return "Pembayaran instan dengan dompet elektronik GoPay.";
      case "OVO":
        return "Pembayaran cashless cepat menggunakan OVO.";
      default:
        return "Metode pembayaran yang aman dan terpercaya.";
    }
  }

  String _getFeature(String name) {
    switch (name) {
      case "COD":
        return "Pembayaran tunai tersedia";
      case "BCA":
      case "BNI":
      case "Mandiri":
        return "Transfer bank 24/7";
      case "Mastercard":
        return "Pembayaran dengan kartu kredit/debit";
      case "DANA":
      case "GoPay":
      case "OVO":
        return "Pembayaran digital cepat";
      default:
        return "Pembayaran mudah dan aman";
    }
  }
}
