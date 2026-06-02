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

    final sorted =
        [...orders]
            .where(
              (o) => ref.watch(chatProvider(o.id)).isNotEmpty,
            ) // ← filter ini
            .toList()
          ..sort((a, b) {
            final unreadA = ref.read(unreadCountProvider(a.id));
            final unreadB = ref.read(unreadCountProvider(b.id));
            if (unreadA != unreadB) return unreadB.compareTo(unreadA);
            final msgsA = ref.read(chatProvider(a.id));
            final msgsB = ref.read(chatProvider(b.id));
            final lastA = msgsA.isEmpty ? a.createdAt : msgsA.last.createdAt;
            final lastB = msgsB.isEmpty ? b.createdAt : msgsB.last.createdAt;
            return lastB.compareTo(lastA);
          });

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                  // total unread badge
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

            // List
            Expanded(
              child: sorted.isEmpty
                  ? _buildEmpty()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      itemCount: sorted.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _ChatInboxTile(order: sorted[i]),
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
  final OrderModel order;
  const _ChatInboxTile({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatProvider(order.id));
    final unread = ref.watch(unreadCountProvider(order.id));
    final hasMessages = messages.isNotEmpty;
    final lastMsg = hasMessages ? messages.last : null;
    final name = order.address.receiverName;
    final initials = name
        .trim()
        .split(' ')
        .take(2)
        .map((e) => e[0])
        .join()
        .toUpperCase();
    final isDelivery = order.deliveryType == 'delivery';
    final timeStr = lastMsg != null
        ? _formatTime(lastMsg.createdAt)
        : DateFormat('d MMM').format(order.createdAt);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AdminChatPage(order: order)),
      ),
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
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: isDelivery
                      ? ColorTheme.primaryColor.withOpacity(0.12)
                      : const Color(0xFF10B981).withOpacity(0.12),
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: isDelivery
                          ? ColorTheme.primaryColor
                          : const Color(0xFF10B981),
                    ),
                  ),
                ),
                // delivery/pickup dot
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: isDelivery
                          ? Colors.orange
                          : const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      isDelivery
                          ? Icons.delivery_dining_rounded
                          : Icons.storefront_rounded,
                      size: 8,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 12),

            // Content
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
                            fontWeight: unread > 0
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
                          color: unread > 0
                              ? ColorTheme.primaryColor
                              : Colors.grey.shade400,
                          fontWeight: unread > 0
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          hasMessages
                              ? '${lastMsg!.sender == ChatSender.admin ? 'Anda: ' : ''}${lastMsg.text}'
                              : 'Pesanan #${order.id.substring(8)} · ${isDelivery ? 'Delivery' : 'Pickup'}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: unread > 0
                                ? Colors.black54
                                : Colors.grey.shade400,
                            fontWeight: unread > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unread > 0)
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
                            '$unread',
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
