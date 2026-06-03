import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:warteg_app/model/order_model.dart';
import 'package:warteg_app/model/order_status_model.dart';
import 'package:warteg_app/extension/order_status_extension.dart';
import 'package:warteg_app/theme/color_theme.dart';

class ReceiptDetailPage extends StatefulWidget {
  final OrderModel order;

  const ReceiptDetailPage({super.key, required this.order});

  @override
  State<ReceiptDetailPage> createState() => _ReceiptDetailPageState();
}

class _ReceiptDetailPageState extends State<ReceiptDetailPage> {
  final GlobalKey _receiptKey = GlobalKey();
  bool _isSaving = false;

  static const _mono = 'Courier';

  Color get _statusColor {
    switch (widget.order.status) {
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

  // ── Capture & Share ──────────────────────────────────────────────────────

  Future<void> _captureAndShare() async {
    setState(() => _isSaving = true);

    try {
      // Capture widget as image
      final boundary =
          _receiptKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();

      final fileName =
          'struk_${widget.order.id}_${DateFormat('yyyyMMdd_HHmm').format(widget.order.createdAt)}.png';

      // Share langsung dari memory, tanpa tulis ke filesystem
      await Share.shareXFiles(
        [XFile.fromData(bytes, name: fileName, mimeType: 'image/png')],
        subject: 'Struk Pesanan ${widget.order.id}',
        text: 'Struk pesanan dari Warteg Barokah',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menyimpan struk: $e',
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Receipt hanya bisa dilihat saat pesanan selesai
    final canViewReceipt = widget.order.status == OrderStatusModel.selesai;

    if (!canViewReceipt) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F7F4),
        body: SafeArea(
          child: Column(
            children: [
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
                              color: Colors.black.withOpacity(0.08),
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
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.10),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.receipt_long_outlined,
                          size: 40,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Struk belum tersedia',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Struk hanya tersedia setelah\npesanan selesai',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFD6D3C8),
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
                            color: Colors.black.withOpacity(0.08),
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
                  const Expanded(
                    child: Text(
                      'Detail Struk',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  // ── Download Button ──────────────────────────────────
                  GestureDetector(
                    onTap: _isSaving ? null : _captureAndShare,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: ColorTheme.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: ColorTheme.primaryColor.withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: _isSaving
                          ? const Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.download_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Paper Receipt (wrapped in RepaintBoundary) ─────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 40),
                child: RepaintBoundary(
                  key: _receiptKey,
                  child: Container(
                    color: const Color(0xFFD6D3C8),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        // Top paper
                        _PaperSection(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                          child: _ReceiptContent(
                            order: widget.order,
                            statusColor: _statusColor,
                            mono: _mono,
                          ),
                        ),

                        // Jagged tear edge
                        CustomPaint(
                          size: const Size(double.infinity, 12),
                          painter: _TearEdgePainter(),
                        ),

                        // Stub
                        _PaperSection(
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(4),
                          ),
                          child: _ReceiptStub(
                            orderId: widget.order.id,
                            createdAt: widget.order.createdAt,
                            mono: _mono,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Bottom Share Bar ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _captureAndShare,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.share_rounded, size: 18),
                  label: Text(
                    _isSaving ? 'Menyimpan...' : 'Simpan / Bagikan Struk',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Paper wrapper ────────────────────────────────────────────────────────────

class _PaperSection extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  const _PaperSection({required this.child, required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFEFA),
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─── Tear Edge ────────────────────────────────────────────────────────────────

class _TearEdgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paperPaint = Paint()..color = const Color(0xFFFFFEFA);
    final bgPaint = Paint()..color = const Color(0xFFD6D3C8);

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 6), paperPaint);

    const tw = 8.0;
    const th = 6.0;
    final count = (size.width / tw).ceil() + 1;
    final path = Path()..moveTo(0, th);
    for (int i = 0; i < count; i++) {
      final x = i * tw.toDouble();
      path.lineTo(x + tw / 2, 0);
      path.lineTo(x + tw, th);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, bgPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Main Receipt Content ─────────────────────────────────────────────────────

class _ReceiptContent extends StatelessWidget {
  final OrderModel order;
  final Color statusColor;
  final String mono;

  const _ReceiptContent({
    required this.order,
    required this.statusColor,
    required this.mono,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd/MM/yy-HH:mm').format(order.createdAt);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Store Header ─────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Text(
                  'WARTEG ENDAH',
                  style: TextStyle(
                    fontFamily: mono,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Jl. Raya Tapos No.102, Ciriung, Kec. Cibinong, \nKabupaten Bogor, Jawa Barat 16918',
                  style: TextStyle(
                    fontFamily: mono,
                    fontSize: 10,
                    letterSpacing: 0.5,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          _Line(mono: mono),
          const SizedBox(height: 6),

          // ── Transaction Meta ─────────────────────────────────────
          Text(
            '$date/${order.id}',
            style: TextStyle(
              fontFamily: mono,
              fontSize: 9,
              color: Colors.black45,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.isPickup ? 'AMBIL SENDIRI' : 'DIANTAR',
                style: TextStyle(
                  fontFamily: mono,
                  fontSize: 9,
                  color: Colors.black45,
                ),
              ),
              Text(
                order.paymentMethod.name.toUpperCase(),
                style: TextStyle(
                  fontFamily: mono,
                  fontSize: 9,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
          if (!order.isPickup) ...[
            const SizedBox(height: 2),
            Text(
              order.address.fullAddress.toUpperCase(),
              style: TextStyle(
                fontFamily: mono,
                fontSize: 9,
                color: Colors.black45,
              ),
            ),
          ],

          const SizedBox(height: 6),
          _Line(mono: mono),
          const SizedBox(height: 6),

          // ── Column Headers ───────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  'NAMA ITEM',
                  style: TextStyle(
                    fontFamily: mono,
                    fontSize: 9,
                    color: Colors.black38,
                  ),
                ),
              ),
              SizedBox(
                width: 28,
                child: Text(
                  'QTY',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: mono,
                    fontSize: 9,
                    color: Colors.black38,
                  ),
                ),
              ),
              SizedBox(
                width: 56,
                child: Text(
                  'HARGA',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: mono,
                    fontSize: 9,
                    color: Colors.black38,
                  ),
                ),
              ),
              SizedBox(
                width: 62,
                child: Text(
                  'TOTAL',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: mono,
                    fontSize: 9,
                    color: Colors.black38,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // ── Items ────────────────────────────────────────────────
          ...order.items.expand((item) {
            final rows = <Widget>[];

            // Baris utama: nama item
            rows.add(
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.menuName.toUpperCase(),
                        style: TextStyle(
                          fontFamily: mono,
                          fontSize: 11,
                          color: Colors.black87,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${item.quantity}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: mono,
                          fontSize: 11,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 56,
                      child: Text(
                        NumberFormat('#,###').format(item.basePrice),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: mono,
                          fontSize: 11,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 62,
                      child: Text(
                        NumberFormat(
                          '#,###',
                        ).format(item.basePrice * item.quantity),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: mono,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );

            // Baris per add on
            for (final addOn in item.addOns) {
              rows.add(
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          '+ ${addOn.name}',
                          style: TextStyle(
                            fontFamily: mono,
                            fontSize: 10,
                            color: Colors.black45,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${item.quantity}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: mono,
                          fontSize: 10,
                          color: Colors.black38,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 56,
                      child: Text(
                        NumberFormat('#,###').format(addOn.price),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: mono,
                          fontSize: 10,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 62,
                      child: Text(
                        NumberFormat(
                          '#,###',
                        ).format(addOn.price * item.quantity),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: mono,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            rows.add(const SizedBox(height: 4));
            return rows;
          }).toList(),

          const SizedBox(height: 6),
          _Line(mono: mono),
          const SizedBox(height: 6),

          _CostLine(label: 'SUBTOTAL', value: order.subtotal, mono: mono),
          _CostLine(label: 'ONGKOS KIRIM', value: order.ongkir, mono: mono),
          if (order.discount > 0)
            _CostLine(
              label: 'DISKON',
              value: -order.discount,
              mono: mono,
              isDiscount: true,
            ),

          const SizedBox(height: 6),
          _Line(mono: mono),
          const SizedBox(height: 6),

          _CostLine(
            label: 'TOTAL BELANJA',
            value: order.total,
            mono: mono,
            isBold: true,
            fontSize: 13,
          ),

          const SizedBox(height: 8),
          _Line(mono: mono),
          const SizedBox(height: 18),

          // ── Status ───────────────────────────────────────────────
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'STATUS : ',
                style: TextStyle(
                  fontFamily: mono,
                  fontSize: 11,
                  color: Colors.black45,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: statusColor.withOpacity(0.4)),
                ),
                child: Text(
                  order.status.label.toUpperCase(),
                  style: TextStyle(
                    fontFamily: mono,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          if (order.sellerNote != null && order.sellerNote!.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              'CATATAN         : ${order.sellerNote!.toUpperCase()}',
              style: TextStyle(
                fontFamily: mono,
                fontSize: 10,
                color: Colors.black45,
              ),
            ),
          ],

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Receipt Stub ─────────────────────────────────────────────────────────────

class _ReceiptStub extends StatelessWidget {
  final String orderId;
  final DateTime createdAt;
  final String mono;

  const _ReceiptStub({
    required this.orderId,
    required this.createdAt,
    required this.mono,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: CustomPaint(
              size: const Size(double.infinity, 48),
              painter: _BarcodePainter(),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            orderId.toUpperCase(),
            style: TextStyle(
              fontFamily: mono,
              fontSize: 8,
              letterSpacing: 2,
              color: Colors.black38,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          _Line(mono: mono, dashed: false),
          const SizedBox(height: 10),
          Text(
            '*** TERIMA KASIH SUDAH MEMESAN ***',
            style: TextStyle(
              fontFamily: mono,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('dd MMM yyyy, HH:mm').format(createdAt),
            style: TextStyle(
              fontFamily: mono,
              fontSize: 9,
              color: Colors.black38,
              letterSpacing: 0.5,
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
    final widths = [
      2,
      1,
      3,
      1,
      2,
      1,
      1,
      3,
      2,
      1,
      2,
      2,
      1,
      3,
      1,
      2,
      1,
      1,
      2,
      3,
      1,
      2,
      1,
      2,
      3,
      1,
      1,
      2,
      1,
      3,
      2,
      1,
      2,
      1,
      1,
      3,
      2,
      1,
      3,
      1,
      2,
      1,
      2,
      3,
      1,
      1,
      2,
      1,
      3,
      2,
      1,
      2,
      1,
      1,
      3,
      2,
      1,
      3,
      1,
      2,
    ];
    final totalWidth = widths.fold(0, (a, b) => a + b).toDouble();
    final scale = size.width / totalWidth;
    double x = 0;
    for (int i = 0; i < widths.length; i++) {
      final w = widths[i] * scale;
      if (i.isEven) {
        final h = (i % 8 == 0) ? size.height : size.height * 0.82;
        canvas.drawRect(
          Rect.fromLTWH(x, size.height - h, (w - 0.8).clamp(0.5, w), h),
          paint,
        );
      }
      x += w;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _Line extends StatelessWidget {
  final String mono;
  final bool dashed;
  const _Line({required this.mono, this.dashed = true});

  @override
  Widget build(BuildContext context) {
    if (!dashed) return const Divider(height: 1, color: Colors.black26);
    return LayoutBuilder(
      builder: (ctx, c) {
        const dw = 5.0, gap = 3.0;
        final n = (c.maxWidth / (dw + gap)).floor();
        return Row(
          children: List.generate(
            n,
            (_) => Container(
              width: dw,
              height: 1,
              margin: const EdgeInsets.only(right: gap),
              color: Colors.black26,
            ),
          ),
        );
      },
    );
  }
}

class _CostLine extends StatelessWidget {
  final String label;
  final int value;
  final String mono;
  final bool isDiscount;
  final bool isBold;
  final double fontSize;

  const _CostLine({
    required this.label,
    required this.value,
    required this.mono,
    this.isDiscount = false,
    this.isBold = false,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    final display = isDiscount
        ? '(${NumberFormat('#,###').format(value.abs())})'
        : NumberFormat('#,###').format(value);
    final color = isDiscount ? const Color(0xFF16A34A) : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: mono,
                fontSize: fontSize,
                color: isBold ? Colors.black87 : Colors.black54,
                fontWeight: isBold ? FontWeight.w900 : FontWeight.normal,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(
              fontFamily: mono,
              fontSize: fontSize,
              color: Colors.black38,
            ),
          ),
          Text(
            display,
            style: TextStyle(
              fontFamily: mono,
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
