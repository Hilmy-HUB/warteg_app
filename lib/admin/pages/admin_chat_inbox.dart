import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:warteg_app/admin/pages/admin_chat_page.dart';
import 'package:warteg_app/model/chat_message_model.dart';
import 'package:warteg_app/model/order_model.dart';
import 'package:warteg_app/provider/chat_provider.dart';
import 'package:warteg_app/provider/order_provider.dart';
import 'package:warteg_app/theme/color_theme.dart';

class AdminChatInboxPage extends ConsumerWidget {
  const AdminChatInboxPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderProvider);

    // ── Group by phone number ──────────────────────────────
    final Map<String, List<OrderModel>> grouped = {};
    for (final o in orders) {
      if (ref.watch(chatProvider(o.id)).isEmpty) continue;
      grouped.putIfAbsent(o.address.phone, () => []).add(o);
    }

    // ── Sort: unread dulu, lalu by pesan terakhir ──────────
    final groupedList = grouped.entries.toList()
      ..sort((a, b) {
        final unreadA = a.value.fold<int>(
          0,
          (s, o) => s + ref.read(unreadCountProvider(o.id)),
        );
        final unreadB = b.value.fold<int>(
          0,
          (s, o) => s + ref.read(unreadCountProvider(o.id)),
        );
        if (unreadA != unreadB) return unreadB.compareTo(unreadA);

        DateTime lastA = a.value.first.createdAt;
        DateTime lastB = b.value.first.createdAt;
        for (final o in a.value) {
          final msgs = ref.read(chatProvider(o.id));
          if (msgs.isNotEmpty && msgs.last.createdAt.isAfter(lastA)) {
            lastA = msgs.last.createdAt;
          }
        }
        for (final o in b.value) {
          final msgs = ref.read(chatProvider(o.id));
          if (msgs.isNotEmpty && msgs.last.createdAt.isAfter(lastB)) {
            lastB = msgs.last.createdAt;
          }
        }
        return lastB.compareTo(lastA);
      });

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              decoration: const BoxDecoration(
                color: ColorTheme.primaryColor,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.forum_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Inbox Chat',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Total unread badge
                  Consumer(
                    builder: (_, ref, __) {
                      final totalUnread = orders.fold<int>(
                        0,
                        (sum, o) => sum + ref.watch(unreadCountProvider(o.id)),
                      );
                      if (totalUnread == 0) return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$totalUnread',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ── List ───────────────────────────────────────
            Expanded(
              child: groupedList.isEmpty
                  ? _buildEmpty()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      itemCount: groupedList.length, // ✅ pakai groupedList
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _ChatInboxTile(
                        orders: groupedList[i].value,
                      ), // ✅ konsisten
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: ColorTheme.primaryColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.forum_outlined,
              size: 34,
              color: ColorTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Belum ada percakapan',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tile ─────────────────────────────────────────────────────────────────────

class _ChatInboxTile extends ConsumerWidget {
  final List<OrderModel> orders;
  const _ChatInboxTile({required this.orders});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalUnread = orders.fold<int>(
      0,
      (s, o) => s + ref.watch(unreadCountProvider(o.id)),
    );

    ChatMessageModel? lastMsg;
    for (final o in orders) {
      final msgs = ref.watch(chatProvider(o.id));
      if (msgs.isNotEmpty) {
        if (lastMsg == null || msgs.last.createdAt.isAfter(lastMsg.createdAt)) {
          lastMsg = msgs.last;
        }
      }
    }

    final name = orders.first.address.receiverName;
    final initials = name
        .trim()
        .split(' ')
        .take(2)
        .map((e) => e[0])
        .join()
        .toUpperCase();
    final deliveryCount = orders
        .where((o) => o.deliveryType == 'delivery')
        .length;
    final pickupCount = orders.where((o) => o.deliveryType == 'pickup').length;
    final timeStr = lastMsg != null
        ? _formatTime(lastMsg.createdAt)
        : DateFormat('d MMM').format(orders.first.createdAt);

    return GestureDetector(
      onTap: () {
        if (orders.length == 1) {
          // Langsung buka jika hanya 1 order
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdminChatPage(order: orders.first),
            ),
          );
        } else {
          // Tampilkan picker jika lebih dari 1 order
          _showOrderPicker(context, orders);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Avatar ──────────────────────────────────────
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: ColorTheme.primaryColor.withOpacity(0.12),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: ColorTheme.primaryColor,
                    ),
                  ),
                ),
                // Dot jumlah order jika lebih dari 1
                if (orders.length > 1)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: ColorTheme.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          '${orders.length}',
                          style: const TextStyle(
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

            const SizedBox(width: 12),

            // ── Content ─────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: totalUnread > 0
                                ? FontWeight.w700
                                : FontWeight.w600,
                            fontSize: 13.5,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: totalUnread > 0
                              ? ColorTheme.primaryColor
                              : Colors.grey.shade400,
                          fontWeight: totalUnread > 0
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // ── Tag delivery / pickup ──────────────────
                  Row(
                    children: [
                      if (deliveryCount > 0)
                        _buildTag(
                          icon: Icons.delivery_dining_rounded,
                          label: '$deliveryCount Delivery',
                          color: Colors.orange,
                        ),
                      if (deliveryCount > 0 && pickupCount > 0)
                        const SizedBox(width: 5),
                      if (pickupCount > 0)
                        _buildTag(
                          icon: Icons.storefront_rounded,
                          label: '$pickupCount Pickup',
                          color: const Color(0xFF10B981),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // ── Preview pesan terakhir ─────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMsg != null
                              ? '${lastMsg.sender == ChatSender.admin ? 'Anda: ' : ''}${lastMsg.text}'
                              : 'Belum ada pesan',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: totalUnread > 0
                                ? Colors.black54
                                : Colors.grey.shade400,
                            fontWeight: totalUnread > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (totalUnread > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: const BoxDecoration(
                            color: ColorTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$totalUnread',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderPicker(BuildContext context, List<OrderModel> orders) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // ✅ wajib untuk DraggableScrollableSheet
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            // Handle bar — tidak ikut scroll
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Pilih Pesanan',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),

            // ✅ List bisa di-scroll
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  ...orders.map(
                    (o) => ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color:
                              (o.deliveryType == 'delivery'
                                      ? Colors.orange
                                      : const Color(0xFF10B981))
                                  .withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          o.deliveryType == 'delivery'
                              ? Icons.delivery_dining_rounded
                              : Icons.storefront_rounded,
                          size: 18,
                          color: o.deliveryType == 'delivery'
                              ? Colors.orange
                              : const Color(0xFF10B981),
                        ),
                      ),
                      title: Text(
                        '${o.deliveryType == 'delivery' ? 'Delivery' : 'Pickup'} · #${o.id.substring(8)}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        DateFormat('d MMM yyyy, HH:mm').format(o.createdAt),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminChatPage(order: o),
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

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inHours < 1) return '${diff.inMinutes}m lalu';
    if (diff.inDays < 1) return DateFormat('HH:mm').format(dt);
    if (diff.inDays < 7) return DateFormat('EEE', 'id').format(dt);
    return DateFormat('d MMM').format(dt);
  }
}
