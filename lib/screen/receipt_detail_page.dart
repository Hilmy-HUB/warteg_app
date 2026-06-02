import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:warteg_app/model/order_model.dart';
import 'package:warteg_app/model/order_status_model.dart';
import 'package:warteg_app/extension/order_status_extension.dart';
import 'package:warteg_app/theme/color_theme.dart';

class ReceiptDetailPage extends StatelessWidget {
  final OrderModel order;

  const ReceiptDetailPage({super.key, required this.order});

  Color get _statusColor {
    switch (order.status) {
      case OrderStatusModel.selesai:
        return const Color(0xFF16A34A);
      case OrderStatusModel.dibatalkan:
        return const Color(0xFFDC2626);
      case OrderStatusModel.bayar:
      case OrderStatusModel.tungguKonfirmasi:
        return const Color(0xFFD97706);
      case OrderStatusModel.diproses:
      case OrderStatusModel.diantar:
      case OrderStatusModel.siapDiambil:
        return const Color(0xFF4F46E5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEECE6),
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 38,
                      height: 38,
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
                        size: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Detail Struk',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ),

            // ── Receipt ────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                child: Column(
                  children: [
                    // Top half of receipt
                    _ReceiptTop(order: order, statusColor: _statusColor),

                    // Jagged tear edge (top)
                    CustomPaint(
                      size: const Size(double.infinity, 14),
                      painter: _JaggedEdgePainter(isTop: true),
                    ),

                    // Middle body
                    _ReceiptBody(order: order),

                    // Jagged tear edge (bottom)
                    CustomPaint(
                      size: const Size(double.infinity, 14),
                      painter: _JaggedEdgePainter(isTop: false),
                    ),

                    // Bottom stub (barcode area)
                    _ReceiptBottom(orderId: order.id),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Jagged Edge Painter ──────────────────────────────────────────────────────

class _JaggedEdgePainter extends CustomPainter {
  final bool isTop;
  const _JaggedEdgePainter({required this.isTop});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final bgPaint = Paint()..color = const Color(0xFFEEECE6);

    const toothWidth = 10.0;
    const toothHeight = 7.0;
    final toothCount = (size.width / toothWidth).ceil() + 1;

    if (isTop) {
      // White rectangle below teeth
      canvas.drawRect(
        Rect.fromLTWH(0, toothHeight, size.width, size.height - toothHeight),
        paint,
      );
      // Teeth cut from background color
      final path = Path();
      path.moveTo(0, 0);
      for (int i = 0; i < toothCount; i++) {
        final x = i * toothWidth;
        path.lineTo(x + toothWidth / 2, toothHeight);
        path.lineTo(x + toothWidth, 0);
      }
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
      canvas.drawPath(path, bgPaint);
    } else {
      // White rectangle above teeth
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height - toothHeight),
        paint,
      );
      // Teeth cut from background color
      final path = Path();
      path.moveTo(0, size.height);
      for (int i = 0; i < toothCount; i++) {
        final x = i * toothWidth;
        path.lineTo(x + toothWidth / 2, size.height - toothHeight);
        path.lineTo(x + toothWidth, size.height);
      }
      path.lineTo(size.width, 0);
      path.lineTo(0, 0);
      path.close();
      canvas.drawPath(path, bgPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Receipt Top ──────────────────────────────────────────────────────────────

class _ReceiptTop extends StatelessWidget {
  final OrderModel order;
  final Color statusColor;

  const _ReceiptTop({required this.order, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
      child: Column(
        children: [
          // Store logo / icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: ColorTheme.primaryColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.storefront_rounded,
              color: ColorTheme.primaryColor,
              size: 26,
            ),
          ),
          const SizedBox(height: 10),

          // Store name
          const Text(
            'WARTEG BAROKAH',
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Jl. Manunggal No. 17',
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 10,
              letterSpacing: 1,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 14),

          // Dashed divider
          _DashedDivider(),
          const SizedBox(height: 12),

          // Order ID & Date row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NO ORDER',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 9,
                      letterSpacing: 2,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    order.id.length > 18
                        ? order.id.substring(0, 18)
                        : order.id,
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'TANGGAL',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 9,
                      letterSpacing: 2,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('dd MMM yyyy, HH:mm').format(order.createdAt),
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Status pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  order.status.label.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ─── Receipt Body ─────────────────────────────────────────────────────────────

class _ReceiptBody extends StatelessWidget {
  final OrderModel order;
  const _ReceiptBody({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Info Pesanan ───────────────────────────────────────────
          _ReceiptSectionLabel(label: 'INFO PESANAN'),
          _ReceiptInfoRow(
            label: 'Metode Bayar',
            value: order.paymentMethod.name,
          ),
          _ReceiptInfoRow(
            label: 'Tipe Pengiriman',
            value: order.isPickup ? 'Ambil Sendiri' : 'Diantar',
          ),
          if (!order.isPickup)
            _ReceiptInfoRow(
              label: 'Alamat',
              value: order.address.fullAddress,
            ),
          const SizedBox(height: 4),

          // ── Daftar Pesanan ─────────────────────────────────────────
          _DashedDivider(),
          _ReceiptSectionLabel(label: 'DAFTAR PESANAN'),

          // Header row
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'ITEM',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 9,
                      letterSpacing: 2,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                Text(
                  'QTY',
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 9,
                    letterSpacing: 2,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 90,
                  child: Text(
                    'HARGA',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 9,
                      letterSpacing: 2,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Items
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.menuName,
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      '${item.quantity}x',
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 90,
                      child: Text(
                        'Rp ${NumberFormat('#,###').format(item.totalHarga)}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 8),
          _DashedDivider(),
          const SizedBox(height: 8),

          // ── Ringkasan Biaya ────────────────────────────────────────
          _CostLine(label: 'Subtotal', value: order.subtotal),
          _CostLine(label: 'Ongkos Kirim', value: order.ongkir),
          if (order.discount > 0)
            _CostLine(
              label: 'Diskon',
              value: -order.discount,
              isDiscount: true,
            ),

          const SizedBox(height: 10),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL',
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Rp ${NumberFormat('#,###').format(order.total)}',
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: ColorTheme.primaryColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          // Catatan penjual
          if (order.sellerNote != null && order.sellerNote!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _DashedDivider(),
            const SizedBox(height: 8),
            Text(
              'CATATAN',
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 9,
                letterSpacing: 2,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              order.sellerNote!,
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─── Receipt Bottom (barcode) ─────────────────────────────────────────────────

class _ReceiptBottom extends StatelessWidget {
  final String orderId;
  const _ReceiptBottom({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        children: [
          // Barcode visual
          SizedBox(
            height: 44,
            child: CustomPaint(
              size: const Size(double.infinity, 44),
              painter: _BarcodePainter(),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            orderId.replaceAll('-', ' ').toUpperCase(),
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 9,
              letterSpacing: 3,
              color: Colors.grey.shade400,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Text(
            '— Terima kasih sudah memesan! —',
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 10,
              letterSpacing: 1,
              color: Colors.grey.shade400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Barcode Painter ──────────────────────────────────────────────────────────

class _BarcodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87;
    final widths = [2, 1, 3, 1, 2, 1, 1, 3, 2, 1, 2, 2, 1, 3, 1, 2, 1, 1, 2, 3, 1, 2, 1, 2, 3, 1, 1, 2, 1, 3, 2, 1, 2, 1, 1, 3, 2, 1];
    double x = 0;
    final totalWidth = widths.fold(0, (a, b) => a + b).toDouble();
    final scale = size.width / totalWidth;

    for (int i = 0; i < widths.length; i++) {
      final w = widths[i] * scale;
      if (i.isEven) {
        final height = i % 6 == 0 ? size.height : size.height * 0.85;
        canvas.drawRect(
          Rect.fromLTWH(x, size.height - height, w - 0.8, height),
          paint,
        );
      }
      x += w;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _DashedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      const dashWidth = 6.0;
      const dashSpace = 4.0;
      final count = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
      return Row(
        children: List.generate(
          count,
          (_) => Container(
            width: dashWidth,
            height: 1,
            margin: const EdgeInsets.only(right: dashSpace),
            color: Colors.grey.shade200,
          ),
        ),
      );
    });
  }
}

class _ReceiptSectionLabel extends StatelessWidget {
  final String label;
  const _ReceiptSectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Courier',
          fontSize: 9,
          letterSpacing: 2.5,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}

class _ReceiptInfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _ReceiptInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Courier',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CostLine extends StatelessWidget {
  final String label;
  final int value;
  final bool isDiscount;

  const _CostLine({
    required this.label,
    required this.value,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    final display = isDiscount
        ? '- Rp ${NumberFormat('#,###').format(value.abs())}'
        : 'Rp ${NumberFormat('#,###').format(value)}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          Text(
            display,
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDiscount ? const Color(0xFF16A34A) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}