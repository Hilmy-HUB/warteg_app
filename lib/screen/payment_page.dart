import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warteg_app/provider/checkout_provider.dart';
import 'package:warteg_app/provider/payment_provider.dart';
import 'package:warteg_app/theme/color_theme.dart';

class PaymentPage extends ConsumerWidget {
  const PaymentPage({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final paymentMethods = ref.watch(paymentProvider);

    final checkout = ref.watch(checkoutProvider);

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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F4),

      // =========================
      // APPBAR
      // =========================
      body: SafeArea(
        child: Column(
          children: [
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
                    "Payment Method",
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

            // =========================
            // HEADER CARD
            // =========================
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
                            "Choose Payment",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),

                          SizedBox(height: 6),

                          Text(
                            "Select your preferred payment method for faster checkout experience.",
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

            // =========================
            // PAYMENT LIST
            // =========================
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                itemCount: paymentMethods.length,
                itemBuilder: (_, index) {
                  final method = paymentMethods[index];

                  final isSelected =
                      checkout.paymentMethod?.name == method.name;

                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(checkoutProvider.notifier)
                          .selectPayment(method);
                          _showSnack('Payment method selected successfully');
                          HapticFeedback.lightImpact();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),

                        border: Border.all(
                          color: isSelected
                              ? ColorTheme.buttonPrimary
                              : Colors.grey.shade200,
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
                          // =========================
                          // ICON
                          // =========================
                          AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 250),
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? ColorTheme.buttonPrimary
                                      .withOpacity(0.12)
                                  : Colors.grey.shade100,
                              borderRadius:
                                  BorderRadius.circular(18),
                            ),
                            child: Icon(
                              getPaymentIcon(method.name),
                              color: isSelected
                                  ? ColorTheme.buttonPrimary
                                  : Colors.grey.shade500,
                              size: 28,
                            ),
                          ),

                          const SizedBox(width: 16),

                          // =========================
                          // INFO
                          // =========================
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        method.name,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 15,
                                          fontWeight:
                                              FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),

                                    if (isSelected)
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: ColorTheme
                                              .buttonPrimary
                                              .withOpacity(0.10),
                                          borderRadius:
                                              BorderRadius.circular(
                                                  20),
                                        ),
                                        child: const Text(
                                          "Selected",
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 10,
                                            fontWeight:
                                                FontWeight.w700,
                                            color: ColorTheme
                                                .buttonPrimary,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  getPaymentDesc(method.name),
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
                                      Icons.flash_on_rounded,
                                      size: 14,
                                      color: Colors.amber.shade700,
                                    ),

                                    const SizedBox(width: 4),

                                    Text(
                                      getPaymentFeature(method.name),
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

                          // =========================
                          // CHECKBOX UI
                          // =========================
                          AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 250),
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
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // PAYMENT ICON
  // =========================

  IconData getPaymentIcon(String name) {
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

  // =========================
  // DESCRIPTION
  // =========================

  String getPaymentDesc(String name) {
    switch (name) {
      case "COD":
        return "Pay directly when your order arrives at your location.";

      case "BCA":
        return "Transfer payment via Bank Central Asia.";

      case "BNI":
        return "Secure payment using BNI virtual account.";

      case "Mandiri":
        return "Easy transfer through Bank Mandiri.";

      case "Mastercard":
        return "Fast payment using debit or credit card.";

      case "DANA":
        return "Digital wallet payment using DANA.";

      case "GoPay":
        return "Instant payment with GoPay e-wallet.";

      case "OVO":
        return "Quick cashless payment using OVO.";

      default:
        return "Available payment method";
    }
  }

  // =========================
  // FEATURE TEXT
  // =========================

  String getPaymentFeature(String name) {
    switch (name) {
      case "COD":
        return "Cash payment available";

      case "BCA":
      case "BNI":
      case "Mandiri":
        return "24/7 bank transfer";

      case "Mastercard":
        return "Secure payment gateway";

      case "DANA":
      case "GoPay":
      case "OVO":
        return "Instant verification";

      default:
        return "Safe & secure payment";
    }
  }
}