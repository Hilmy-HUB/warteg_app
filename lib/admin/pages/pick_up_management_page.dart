import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:warteg_app/admin/pages/admin_chat_page.dart';
import 'package:warteg_app/model/cart_item_model.dart';
import 'package:warteg_app/model/chat_message_model.dart';
import 'package:warteg_app/model/order_model.dart';
import 'package:warteg_app/model/order_status_model.dart';
import 'package:warteg_app/provider/chat_provider.dart';
import 'package:warteg_app/provider/notification_provider.dart';
import 'package:warteg_app/provider/order_provider.dart';
import 'package:warteg_app/theme/color_theme.dart';

class PickupOrderPage extends ConsumerStatefulWidget {
  const PickupOrderPage({super.key});

  @override
  ConsumerState<PickupOrderPage> createState() => _PickupOrderPageState();
}

class _PickupOrderPageState extends ConsumerState<PickupOrderPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(orderProvider);
    final pickupOrders = orders
        .where((o) => o.deliveryType == 'pickup')
        .toList();

    final incoming = pickupOrders
        .where(
          (o) =>
              o.status == OrderStatusModel.tungguKonfirmasi &&
              !o.acceptedByAdmin,
        )
        .toList();

    final processing = pickupOrders
        .where(
          (o) => o.acceptedByAdmin && o.status == OrderStatusModel.diproses,
        )
        .toList();

    final siapDiambil = pickupOrders
        .where((o) => o.status == OrderStatusModel.siapDiambil)
        .toList();

    final done = pickupOrders
        .where((o) => o.status == OrderStatusModel.selesai)
        .toList();

    final cancelled = pickupOrders
        .where((o) => o.status == OrderStatusModel.dibatalkan)
        .toList();

    return Scaffold(
      backgroundColor: ColorTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.maybePop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 17,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Icon(
                        Icons.storefront_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Pesanan Pickup',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TabBar(
                    controller: _tab,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withOpacity(0.55),
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    tabs: [
                      Tab(text: 'Masuk (${incoming.length})'),
                      Tab(text: 'Diproses (${processing.length})'),
                      Tab(text: 'Siap Diambil (${siapDiambil.length})'),
                      Tab(text: 'Selesai (${done.length})'),
                      Tab(text: 'Dibatalkan (${cancelled.length})'),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _PickupList(orders: incoming, mode: _PickupMode.incoming),
                  _PickupList(orders: processing, mode: _PickupMode.processing),
                  _PickupList(
                    orders: siapDiambil,
                    mode: _PickupMode.siapDiambil,
                  ),
                  _PickupList(orders: done, mode: _PickupMode.done),
                  _PickupList(orders: cancelled, mode: _PickupMode.cancelled),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mode ──────────────────────────────────────────────────────────────────────

enum _PickupMode { incoming, processing, siapDiambil, done, cancelled }

// ── List ──────────────────────────────────────────────────────────────────────

class _PickupList extends ConsumerWidget {
  final List<OrderModel> orders;
  final _PickupMode mode;

  const _PickupList({required this.orders, required this.mode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.storefront_outlined,
                size: 38,
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada pesanan pickup',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: orders.length,
      itemBuilder: (_, i) => _PickupCard(order: orders[i], mode: mode),
    );
  }
}

// ── Card ──────────────────────────────────────────────────────────────────────

class _PickupCard extends ConsumerWidget {
  final OrderModel order;
  final _PickupMode mode;

  const _PickupCard({required this.order, required this.mode});

  static String _fmt(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();
    final mod = s.length % 3;
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (i - mod) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  Color _statusColor(OrderStatusModel s) => switch (s) {
    OrderStatusModel.tungguKonfirmasi => const Color(0xFF8B5CF6),
    OrderStatusModel.diproses => Colors.blue,
    OrderStatusModel.siapDiambil => const Color(0xFF10B981),
    OrderStatusModel.selesai => const Color(0xFF10B981),
    OrderStatusModel.dibatalkan => Colors.red,
    _ => Colors.grey,
  };

  String _statusLabel(OrderStatusModel s) => switch (s) {
    OrderStatusModel.tungguKonfirmasi => 'Tunggu Konfirmasi',
    OrderStatusModel.diproses => 'Diproses',
    OrderStatusModel.siapDiambil => 'Siap Diambil',
    OrderStatusModel.selesai => 'Selesai',
    OrderStatusModel.dibatalkan => 'Dibatalkan',
    _ => '-',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ BERSIH — tidak ada auto-chat di sini
    final notifier = ref.read(orderProvider.notifier);
    final notifNotifier = ref.read(notificationProvider.notifier);
    final chatNotifier = ref.read(chatProvider(order.id).notifier);
    final statusColor = _statusColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Status strip
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.6),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminChatPage(order: order),
                        ),
                      ),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: ColorTheme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          children: [
                            const Center(
                              child: Icon(
                                Icons.chat_rounded,
                                size: 18,
                                color: ColorTheme.primaryColor,
                              ),
                            ),
                            Consumer(
                              builder: (_, ref, __) {
                                final unread = ref.watch(
                                  unreadCountProvider(order.id),
                                );
                                if (unread == 0) return const SizedBox.shrink();
                                return Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$unread',
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.address.receiverName,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            order.address.phone,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _statusLabel(order.status),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('d MMM yyyy, HH:mm').format(order.createdAt),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Pickup info banner
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.storefront_rounded,
                        size: 12,
                        color: Color(0xFF10B981),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Ambil langsung · ${order.address.label}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),
                Divider(color: Colors.grey.shade100, thickness: 1),
                const SizedBox(height: 10),

                ...order.items.map((item) => _ItemRow(item: item)),

                const SizedBox(height: 10),
                Divider(color: Colors.grey.shade100, thickness: 1),
                const SizedBox(height: 10),

                if (order.discount > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_offer_rounded,
                          size: 13,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Diskon',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '- Rp ${_fmt(order.discount)}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Pembayaran',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Rp ${_fmt(order.total)}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),

                // ── Action Buttons ────────────────────────────

                // Tab Masuk: Terima / Tolak
                if (mode == _PickupMode.incoming) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final confirm = await _confirmDialog(
                              context,
                              title: 'Tolak Pesanan?',
                              message:
                                  'Pesanan ini akan dibatalkan dan user akan mendapat notifikasi.',
                              confirmLabel: 'Tolak',
                              confirmColor: Colors.red,
                            );
                            if (confirm != true) return;
                            await notifier.updateOrderStatus(
                              order.id,
                              OrderStatusModel.dibatalkan,
                            );
                            notifNotifier.addNotification(
                              title: 'Pesanan Ditolak',
                              message:
                                  'Maaf, pesanan pickup #${order.id.substring(8)} tidak dapat kami proses.',
                              orderId: order.id,
                            );
                            if (confirm != true) return;
                            await notifier.updateOrderStatus(
                              order.id,
                              OrderStatusModel.dibatalkan,
                            );
                            // ✅ Tambahkan ini
                            chatNotifier.sendMessage(
                              '❌ Maaf, pesanan pickup kamu tidak dapat kami terima saat ini. Silakan coba lagi nanti.',
                              ChatSender.admin,
                            );
                            notifNotifier.addNotification(
                              title: 'Pesanan Ditolak',
                              message:
                                  'Maaf, pesanan pickup #${order.id.substring(8)} tidak dapat kami proses.',
                              orderId: order.id,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: Colors.redAccent,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Tolak',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final confirm = await _confirmDialog(
                              context,
                              title: 'Terima Pesanan?',
                              message:
                                  'Pesanan pickup akan masuk ke antrian dapur.',
                              confirmLabel: 'Terima',
                              confirmColor: const Color(0xFF10B981),
                            );
                            if (confirm != true) return;
                            await notifier.acceptOrder(order.id);
                            // ✅ Auto-chat terima pickup
                            chatNotifier.sendMessage(
                              '✅ Pesanan pickup kamu telah diterima! Sedang kami siapkan. Silakan datang ke restoran untuk mengambil.',
                              ChatSender.admin,
                            );
                            notifNotifier.addNotification(
                              title: 'Pesanan Diterima ✅',
                              message:
                                  'Pesanan pickup #${order.id.substring(8)} sedang diproses. Segera datang ke restoran!',
                              orderId: order.id,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: Color(0xFF10B981),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Terima',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // Tab Diproses: Tandai Siap Diambil
                if (mode == _PickupMode.processing) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: () async {
                        final confirm = await _confirmDialog(
                          context,
                          title: 'Pesanan Siap Diambil?',
                          message:
                              'Notifikasi akan dikirim ke pelanggan untuk segera mengambil pesanan.',
                          confirmLabel: 'Siap Diambil',
                          confirmColor: const Color(0xFF10B981),
                        );
                        if (confirm != true) return;
                        await notifier.updateOrderStatus(
                          order.id,
                          OrderStatusModel.siapDiambil,
                        );
                        // ✅ Auto-chat siap diambil
                        chatNotifier.sendMessage(
                          '🎉 Pesanan pickup kamu sudah siap! Silakan datang ke restoran untuk mengambil.',
                          ChatSender.admin,
                        );
                        notifNotifier.addNotification(
                          title: 'Pesanan Siap Diambil! 🎉',
                          message:
                              'Pesanan pickup #${order.id.substring(8)} sudah siap. Silakan ambil di restoran.',
                          orderId: order.id,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              size: 18,
                              color: Color(0xFF10B981),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Tandai Siap Diambil',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              confirmLabel,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Item Row ──────────────────────────────────────────────────────────────────

class _ItemRow extends StatelessWidget {
  final CartItemModel item;
  const _ItemRow({required this.item});

  static String _fmt(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();
    final mod = s.length % 3;
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (i - mod) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${item.quantity}x',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF10B981),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.menuName,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (item.addOns.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: item.addOns
                        .map(
                          (a) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '+ ${a.name}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (item.notes != null && item.notes!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.amber.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.sticky_note_2_outlined,
                          size: 13,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.notes!,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: Colors.amber.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            'Rp ${_fmt(item.totalHarga)}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
