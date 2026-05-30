import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warteg_app/model/order_model.dart';
import 'package:warteg_app/model/order_status_model.dart';
import 'package:warteg_app/provider/order_provider.dart';
import 'package:warteg_app/theme/color_theme.dart';
import 'package:warteg_app/provider/notification_provider.dart';
import 'package:warteg_app/provider/navbar_provider.dart';
import 'package:warteg_app/provider/order_tab_provider.dart';

class InvoicePage extends ConsumerStatefulWidget {
  final OrderModel order;
  final String? vaNumber;

  const InvoicePage({super.key, required this.order, this.vaNumber});

  @override
  ConsumerState<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends ConsumerState<InvoicePage> {
  late Duration remainingTime;

  Timer? timer;

  bool mobileExpanded = true;
  bool atmExpanded = false;
  bool internetExpanded = false;

  @override
  void initState() {
    super.initState();

    remainingTime = widget.order.expiredAt.difference(DateTime.now());

    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (widget.order.status == OrderStatusModel.dibatalkan) {
        timer?.cancel();
        return;
      }

      final diff = widget.order.expiredAt.difference(DateTime.now());

      if (diff.isNegative) {
        timer?.cancel();
      }

      setState(() {
        remainingTime = diff.isNegative ? Duration.zero : diff;
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    if (duration.isNegative) {
      return "00:00:00";
    }

    final hours = duration.inHours.toString().padLeft(2, '0');

    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');

    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    return "$hours:$minutes:$seconds";
  }

  String formatRupiah(int amount) {
    final s = amount.toString();

    final buf = StringBuffer();

    final mod = s.length % 3;

    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (i - mod) % 3 == 0) {
        buf.write('.');
      }

      buf.write(s[i]);
    }

    return buf.toString();
  }

  void copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Copied successfully",
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void cancelOrder() {
    ref
        .read(orderProvider.notifier)
        .updateOrderStatus(widget.order.id, OrderStatusModel.dibatalkan);

    ref
        .read(notificationProvider.notifier)
        .addNotification(
          title: 'Pesanan Dibatalkan',
          message:
              'Pesanan #${widget.order.id.substring(8)} berhasil dibatalkan',
          orderId: widget.order.id,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Pesanan berhasil dibatalkan",
          style: TextStyle(fontFamily: 'Poppins'),
        ),
      ),
    );

    Navigator.pop(context);
  }

  void showCancelDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            "Batalkan Pesanan?",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "Pesanan yang belum dibayar akan dihapus dari daftar pesanan.",
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Tidak",
                style: TextStyle(fontFamily: 'Poppins'),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                cancelOrder();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Ya, Batalkan",
                style: TextStyle(fontFamily: 'Poppins', color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentName = widget.order.paymentMethod.name;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F4),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.order.status == OrderStatusModel.bayar) ...[
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: showCancelDialog,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      "Batalkan Pesanan",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      ref.read(orderTabProvider.notifier).state =
                          OrderStatusModel.bayar;
                      ref.read(navbarIndexProvider.notifier).state =
                          widget.order.deliveryType == 'pickup' ? 3 : 2;
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  const Expanded(
                    child: Text(
                      "Pembayaran",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Belum Dibayar",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          ColorTheme.primaryColor,
                          ColorTheme.secondaryColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.access_time_filled_rounded,
                          color: Colors.white,
                          size: 42,
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          "Selesaikan pembayaran sebelum",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          formatDuration(remainingTime),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: ColorTheme.buttonPrimary.withOpacity(
                                  0.10,
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Icon(
                                Icons.account_balance_rounded,
                                color: ColorTheme.buttonPrimary,
                                size: 32,
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    paymentName,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    "Virtual Account",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 26),

                        const Text(
                          "Nomor Virtual Account",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.vaNumber ?? "-",
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),

                            GestureDetector(
                              onTap: () {
                                copyText(widget.vaNumber ?? "-");
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: ColorTheme.buttonPrimary,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Text(
                                  "Salin",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        _invoiceRow(
                          "Total Pembayaran",
                          "Rp ${formatRupiah(widget.order.total)}",
                          valueColor: ColorTheme.buttonPrimary,
                          isBig: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _invoiceRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBig = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: isBig ? 22 : 15,
            fontWeight: FontWeight.w700,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
