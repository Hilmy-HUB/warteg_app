import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warteg_app/extension/order_status_extension.dart';
import 'package:warteg_app/model/order_model.dart';
import 'package:warteg_app/model/order_status_model.dart';
import 'package:warteg_app/provider/chat_provider.dart';
import 'package:warteg_app/provider/order_provider.dart';
import 'package:warteg_app/screen/invoice_page.dart';
import 'package:warteg_app/screen/user_chat_page.dart';
import 'package:warteg_app/theme/color_theme.dart';

class PickupPage extends ConsumerStatefulWidget {
  const PickupPage({super.key});

  @override
  ConsumerState<PickupPage> createState() => _PickupPageState();
}

class _PickupPageState extends ConsumerState<PickupPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _timer;

  final List<_PickupTab> tabs = const [
    _PickupTab(label: 'Bayar', status: OrderStatusModel.bayar),
    _PickupTab(label: 'Menunggu', status: OrderStatusModel.tungguKonfirmasi),
    _PickupTab(label: 'Diproses', status: OrderStatusModel.diproses),
    _PickupTab(label: 'Siap Diambil', status: OrderStatusModel.siapDiambil),
    _PickupTab(label: 'Selesai', status: OrderStatusModel.selesai),
    _PickupTab(label: 'Dibatalkan', status: OrderStatusModel.dibatalkan),
  ];

  bool _canCancelCOD(OrderModel order) {
    if (order.paymentMethod.name != "COD") return false;
    if (order.status != OrderStatusModel.tungguKonfirmasi) return false;
    if (order.cancelExpiredAt == null) return false;
    return DateTime.now().isBefore(order.cancelExpiredAt!);
  }

  String _getRemainingCancelTime(OrderModel order) {
    if (order.cancelExpiredAt == null) return "00:00";
    final diff = order.cancelExpiredAt!.difference(DateTime.now());
    if (diff.isNegative) return "00:00";
    final minutes = diff.inMinutes.toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void _openChat(BuildContext context, List<OrderModel> allPickupOrders) {
    if (allPickupOrders.isEmpty) return;

    // Prioritas: order yang masih aktif
    final activeOrders = allPickupOrders
        .where(
          (o) =>
              o.status != OrderStatusModel.selesai &&
              o.status != OrderStatusModel.dibatalkan,
        )
        .toList();

    final targetOrders = activeOrders.isNotEmpty
        ? activeOrders
        : allPickupOrders;

    if (targetOrders.length == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserChatPage(order: targetOrders.first),
        ),
      );
    } else {
      _showChatOrderPicker(context, targetOrders);
    }
  }

  void _showChatOrderPicker(BuildContext context, List<OrderModel> orders) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // ✅ tambah ini
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pilih Pesanan',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  ...orders.map(
                    (o) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: ColorTheme.buttonPrimary,
                        child: Icon(
                          o.deliveryType == 'delivery'
                              ? Icons.delivery_dining_rounded
                              : Icons.storefront_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        'Order #${o.id.substring(8)}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${o.deliveryType == 'delivery' ? 'Delivery' : 'Pickup'} · ${o.status.label}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserChatPage(order: o),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancelCOD(OrderModel order) async {
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Batalkan Pesanan?',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Apakah kamu yakin ingin membatalkan pesanan ini?',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Tidak',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Ya',
              style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
            ),
          ),
        ],
      ),
    );
    if (firstConfirm != true) return;

    final secondConfirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Konfirmasi Terakhir',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Pesanan yang dibatalkan tidak dapat dikembalikan.',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Kembali',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Batalkan',
              style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
            ),
          ),
        ],
      ),
    );
    if (secondConfirm != true) return;

    ref
        .read(orderProvider.notifier)
        .updateOrderStatus(order.id, OrderStatusModel.dibatalkan);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Pesanan berhasil dibatalkan',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        ),
      );
      final batalIndex = tabs.indexWhere(
        (t) => t.status == OrderStatusModel.dibatalkan,
      );
      if (batalIndex != -1) _tabController.animateTo(batalIndex);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  List<OrderModel> _getPickupOrders(
    List<OrderModel> all,
    OrderStatusModel status,
  ) => all
      .where((o) => o.status == status && o.deliveryType == 'pickup')
      .toList();

  Color _statusColor(OrderStatusModel status) => switch (status) {
    OrderStatusModel.tungguKonfirmasi => const Color(0xFF8B5CF6),
    OrderStatusModel.diproses => Colors.blue,
    OrderStatusModel.siapDiambil => const Color(0xFF10B981),
    OrderStatusModel.selesai => Colors.green,
    OrderStatusModel.dibatalkan => Colors.red,
    _ => Colors.grey,
  };

  String _formatRupiah(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();
    final mod = s.length % 3;
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (i - mod) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  Widget _buildOrderCard(OrderModel order) {
    final isTunggu = order.status == OrderStatusModel.tungguKonfirmasi;
    final isDiproses = order.status == OrderStatusModel.diproses;
    final isSiapDiambil = order.status == OrderStatusModel.siapDiambil;

    return GestureDetector(
      onTap: () {
        if (order.status == OrderStatusModel.bayar) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  InvoicePage(order: order, vaNumber: order.vaNumber),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status strip
            Container(
              height: 5,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _statusColor(order.status),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Order #${order.id.substring(8)}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.storefront_rounded,
                        size: 12,
                        color: Color(0xFF10B981),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Pickup',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(order.status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    tabs
                        .firstWhere(
                          (t) => t.status == order.status,
                          orElse: () =>
                              _PickupTab(label: '-', status: order.status),
                        )
                        .label,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(order.status),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Items
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(
                        item.image,
                        width: 74,
                        height: 74,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 74,
                          height: 74,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(18),
                          ),
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
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${item.quantity} x Rp ${_formatRupiah(item.hargaSatuan)}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (item.addOns.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: item.addOns
                                    .map(
                                      (e) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: ColorTheme.buttonPrimary
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        child: Text(
                                          '+ ${e.name}',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontFamily: 'Poppins',
                                            color: ColorTheme.buttonPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          if (item.notes != null && item.notes!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.amber.withOpacity(0.25),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.sticky_note_2_outlined,
                                      size: 13,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        item.notes!,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rp ${_formatRupiah(item.totalHarga)}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: ColorTheme.buttonPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 30),

            // Lokasi & pembayaran
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.storefront_rounded,
                        color: Colors.grey.shade600,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Pickup di',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Expanded(
                        child: Text(
                          order.address.label,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Icon(
                        Icons.payments_outlined,
                        color: Colors.grey.shade600,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Pembayaran',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        order.paymentMethod.name,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Total
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: ColorTheme.buttonPrimary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Text(
                    'Total Belanja',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Rp ${_formatRupiah(order.total)}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: ColorTheme.buttonPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // ── Bayar ────────────────────────────────────────
            if (order.status == OrderStatusModel.bayar) ...[
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.red),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Silakan selesaikan pembayaran virtual account',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    ref
                        .read(orderProvider.notifier)
                        .updateOrderStatus(
                          order.id,
                          OrderStatusModel.tungguKonfirmasi,
                        );
                    final tungguIndex = tabs.indexWhere(
                      (t) => t.status == OrderStatusModel.tungguKonfirmasi,
                    );
                    if (tungguIndex != -1)
                      _tabController.animateTo(tungguIndex);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Pembayaran berhasil! Menunggu konfirmasi restoran.',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorTheme.buttonPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Bayar Sekarang',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],

            // ── Tunggu Konfirmasi ────────────────────────────
            if (isTunggu) ...[
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.hourglass_top_rounded,
                      color: Color(0xFF8B5CF6),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Pesanan sedang menunggu konfirmasi dari restoran',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_canCancelCOD(order)) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: Colors.orange),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Batalkan pesanan dalam ${_getRemainingCancelTime(order)}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _cancelCOD(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Batalkan Pesanan',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ],

            // ── Diproses ──────────────────────────────────────
            if (isDiproses) ...[
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.restaurant_rounded, color: Colors.blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Pesananmu sedang disiapkan. Segera datang ke restoran!',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── Siap Diambil ──────────────────────────────────
            if (isSiapDiambil) ...[
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF10B981),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Pesananmu sudah siap! Segera datang ke restoran untuk mengambil.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.storefront_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text(
                    'Saya Sudah Ambil',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  onPressed: () => _confirmPickup(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmPickup(OrderModel order) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Konfirmasi Pengambilan',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Konfirmasi bahwa kamu sudah mengambil pesanan ini?',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text(
              'Ya, Sudah Ambil',
              style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    ref
        .read(orderProvider.notifier)
        .updateOrderStatus(order.id, OrderStatusModel.selesai);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Pesanan selesai! Terima kasih sudah pickup.',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        ),
      );
      final selesaiIndex = tabs.indexWhere(
        (t) => t.status == OrderStatusModel.selesai,
      );
      if (selesaiIndex != -1) _tabController.animateTo(selesaiIndex);
    }
  }

  Widget _buildTabContent(OrderStatusModel status) {
    final allOrders = ref.watch(orderProvider);
    final orders = _getPickupOrders(allOrders, status);

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Icon(
                Icons.storefront_outlined,
                size: 60,
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Belum ada pesanan pickup',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pesanan pickup kamu akan muncul di sini',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 70),
      itemCount: orders.length,
      itemBuilder: (_, i) => _buildOrderCard(orders[i]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Pesanan Pickup',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        actions: [
          Consumer(
            builder: (_, ref, __) {
              final pickupOrders = ref
                  .watch(orderProvider)
                  .where((o) => o.deliveryType == 'pickup')
                  .toList();

              // Total unread dari admin untuk semua order pickup
              final totalUnread = pickupOrders.fold<int>(
                0,
                (sum, o) => sum + ref.watch(unreadAdminCountProvider(o.id)),
              );

              // Tombol chat hanya tampil jika ada order pickup
              if (pickupOrders.isEmpty) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => _openChat(context, pickupOrders),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chat_rounded,
                          color: ColorTheme.buttonPrimary,
                          size: 20,
                        ),
                      ),
                      if (totalUnread > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$totalUnread',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Container(
              height: 52,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TabBar(
                tabAlignment: TabAlignment.start,
                controller: _tabController,
                isScrollable: true,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                splashBorderRadius: BorderRadius.circular(16),
                indicator: BoxDecoration(
                  color: ColorTheme.buttonPrimary.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                labelColor: ColorTheme.textSecondary,
                unselectedLabelColor: Colors.grey.shade500,
                labelStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 12.5,
                ),
                labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                tabs: tabs
                    .map(
                      (e) => SizedBox(
                        height: 42,
                        child: Center(child: Text(e.label)),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: tabs.map((e) => _buildTabContent(e.status)).toList(),
      ),
    );
  }
}

class _PickupTab {
  final String label;
  final OrderStatusModel status;
  const _PickupTab({required this.label, required this.status});
}
