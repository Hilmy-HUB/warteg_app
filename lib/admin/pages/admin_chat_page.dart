import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:warteg_app/model/chat_message_model.dart';
import 'package:warteg_app/model/order_model.dart';
import 'package:warteg_app/model/order_status_model.dart';
import 'package:warteg_app/provider/chat_provider.dart';
import 'package:warteg_app/theme/color_theme.dart';

class AdminChatPage extends ConsumerStatefulWidget {
  final OrderModel order;
  const AdminChatPage({super.key, required this.order});

  @override
  ConsumerState<AdminChatPage> createState() => _AdminChatPageState();
}

class _AdminChatPageState extends ConsumerState<AdminChatPage> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();

  // Quick replies admin
  static const _quickReplies = [
    'Pesanan diterima ✅',
    'Estimasi 15 menit',
    'Pesanan siap diantar 🛵',
    'Mohon tunggu sebentar',
    'Pesanan siap diambil 🎉',
  ];

  @override
  void initState() {
    super.initState();
    // Mark all user messages as read
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider(widget.order.id).notifier).markAllRead();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send(String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    ref
        .read(chatProvider(widget.order.id).notifier)
        .sendMessage(t, ChatSender.admin);
    _ctrl.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Color _statusColor(OrderStatusModel s) => switch (s) {
        OrderStatusModel.diproses => Colors.blue,
        OrderStatusModel.diantar => Colors.teal,
        OrderStatusModel.siapDiambil => const Color(0xFF10B981),
        OrderStatusModel.selesai => ColorTheme.primaryColor,
        OrderStatusModel.dibatalkan => Colors.red,
        _ => Colors.orange,
      };

  String _statusLabel(OrderStatusModel s) => switch (s) {
        OrderStatusModel.tungguKonfirmasi => 'Tunggu Konfirmasi',
        OrderStatusModel.diproses => 'Diproses',
        OrderStatusModel.diantar => 'Diantar',
        OrderStatusModel.siapDiambil => 'Siap Diambil',
        OrderStatusModel.selesai => 'Selesai',
        OrderStatusModel.dibatalkan => 'Dibatalkan',
        _ => '-',
      };

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider(widget.order.id));
    final statusColor = _statusColor(widget.order.status);
    final name = widget.order.address.receiverName;
    final initials = name.trim().split(' ').take(2).map((e) => e[0]).join();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              decoration: const BoxDecoration(
                color: ColorTheme.primaryColor,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  Row(
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
                      const Expanded(
                        child: Text(
                          'Chat dengan Pelanggan',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Order info card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white,
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
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${widget.order.address.phone} · #${widget.order.id.substring(8)}',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.75),
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
                            color: statusColor.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            _statusLabel(widget.order.status),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Messages ─────────────────────────────────────
            Expanded(
              child: messages.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                      itemCount: messages.length,
                      itemBuilder: (_, i) => _ChatBubble(
                        message: messages[i],
                        customerName: name,
                      ),
                    ),
            ),

            // ── Quick Replies ────────────────────────────────
            Container(
              height: 44,
              color: Colors.white,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: _quickReplies.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => _send(_quickReplies[i]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ColorTheme.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: ColorTheme.primaryColor.withOpacity(0.25),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      _quickReplies[i],
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: ColorTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Input ─────────────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(
                16,
                10,
                16,
                MediaQuery.of(context).padding.bottom + 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _ctrl,
                        textInputAction: TextInputAction.send,
                        onSubmitted: _send,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13.5,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Ketik pesan ke pelanggan...',
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13.5,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _send(_ctrl.text),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        color: ColorTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
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
              Icons.chat_bubble_outline_rounded,
              size: 34,
              color: ColorTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Belum ada pesan',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Mulai chat dengan pelanggan',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bubble ───────────────────────────────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final String customerName;

  const _ChatBubble({required this.message, required this.customerName});

  @override
  Widget build(BuildContext context) {
    final isAdmin = message.sender == ChatSender.admin;
    final time = DateFormat('HH:mm').format(message.createdAt);

    return Align(
      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 3, left: 2, right: 2),
            child: Text(
              isAdmin ? 'Admin Warteg' : customerName,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                color: Colors.grey.shade400,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isAdmin ? ColorTheme.primaryColor : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isAdmin ? 18 : 4),
                bottomRight: Radius.circular(isAdmin ? 4 : 18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: isAdmin
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.5,
                    color: isAdmin ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        color: isAdmin
                            ? Colors.white.withOpacity(0.65)
                            : Colors.grey.shade400,
                      ),
                    ),
                    if (isAdmin) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.isRead
                            ? Icons.done_all_rounded
                            : Icons.done_rounded,
                        size: 12,
                        color: Colors.white.withOpacity(0.65),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}