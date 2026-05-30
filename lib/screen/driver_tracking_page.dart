import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:warteg_app/model/driver_mode.dart';
import 'package:warteg_app/model/order_model.dart';
import 'package:warteg_app/model/order_status_model.dart';
import 'package:warteg_app/provider/notification_provider.dart';
import 'package:warteg_app/provider/order_provider.dart';
import 'package:warteg_app/theme/color_theme.dart';

// ─── Chat message model ───────────────────────────────────────────────────────

enum _Sender { user, driver }

class _ChatMessage {
  final String text;
  final _Sender sender;
  final DateTime time;

  _ChatMessage({required this.text, required this.sender, required this.time});
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class DriverTrackingPage extends ConsumerStatefulWidget {
  final OrderModel order;

  const DriverTrackingPage({super.key, required this.order});

  @override
  ConsumerState<DriverTrackingPage> createState() => _DriverTrackingPageState();
}

class _DriverTrackingPageState extends ConsumerState<DriverTrackingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final TextEditingController _chatCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<_ChatMessage> _messages = [];
  Timer? _driverReplyTimer;

  // Estimasi ETA countdown (dummy 15 menit)
  int _etaSeconds = 15 * 60;
  Timer? _etaTimer;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);

    // Seed pesan awal dari driver
    _messages.add(_ChatMessage(
      text: 'Halo! Saya sudah pickup pesanan kamu. Segera meluncur ya! 🛵',
      sender: _Sender.driver,
      time: DateTime.now(),
    ));

    // ETA countdown
    _etaTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_etaSeconds > 0) {
        setState(() => _etaSeconds--);
      } else {
        _etaTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    _chatCtrl.dispose();
    _scrollCtrl.dispose();
    _driverReplyTimer?.cancel();
    _etaTimer?.cancel();
    super.dispose();
  }

  String get _etaLabel {
    final m = (_etaSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_etaSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _sendMessage() {
    final text = _chatCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        sender: _Sender.user,
        time: DateTime.now(),
      ));
    });
    _chatCtrl.clear();
    _scrollToBottom();

    // Simulasi balasan driver setelah 2–4 detik
    final delay = 2 + (DateTime.now().millisecond % 3);
    _driverReplyTimer?.cancel();
    _driverReplyTimer = Timer(Duration(seconds: delay), () {
      if (!mounted) return;
      final replies = [
        'Siap, hampir sampai! 😊',
        'Baik, noted! 👍',
        'Oke, saya melaju sekarang.',
        'Estimasi 5 menit lagi ya!',
      ];
      final reply =
          replies[DateTime.now().millisecond % replies.length];
      setState(() {
        _messages.add(_ChatMessage(
          text: reply,
          sender: _Sender.driver,
          time: DateTime.now(),
        ));
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _callDriver(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka aplikasi telepon')),
        );
      }
    }
  }

  Future<void> _waDriver(DriverModel driver) async {
    final phone = driver.phone.replaceAll(RegExp(r'\D'), '');
    final intl = phone.startsWith('0') ? '62${phone.substring(1)}' : phone;
    final uri = Uri.parse('https://wa.me/$intl');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _confirmDelivery() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Konfirmasi Penerimaan?',
            style: TextStyle(
                fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        content: const Text(
            'Pastikan pesananmu sudah diterima dengan lengkap.',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal',
                style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTheme.primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sudah Diterima',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    await ref
        .read(orderProvider.notifier)
        .updateOrderStatus(widget.order.id, OrderStatusModel.selesai);

    ref.read(notificationProvider.notifier).addNotification(
          title: 'Pesanan Sampai ✅',
          message:
              'Pesanan #${widget.order.id.substring(8)} telah diterima oleh ${widget.order.address.receiverName}.',
          orderId: widget.order.id,
        );
    ref.read(notificationProvider.notifier).addNotification(
          title: 'Terima Kasih! 🎉',
          message:
              'Pesanan #${widget.order.id.substring(8)} selesai. Selamat menikmati!',
          orderId: widget.order.id,
        );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final driver = widget.order.driver;
    if (driver == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Pengantaran')),
        body: const Center(child: Text('Data driver tidak tersedia')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(driver),
            _buildEtaBanner(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _buildDriverInfo(driver),
                  _buildChat(),
                ],
              ),
            ),
            _buildConfirmBar(),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(DriverModel driver) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: const BoxDecoration(
        color: ColorTheme.primaryColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 16, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Detail Pengantaran',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Driver card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withOpacity(0.6), width: 2),
                  ),
                  child: driver.photoUrl != null
                      ? ClipOval(
                          child: Image.network(driver.photoUrl!,
                              fit: BoxFit.cover))
                      : const Icon(Icons.person_rounded,
                          color: ColorTheme.primaryColor, size: 32),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(driver.name,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          )),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _Chip(
                              icon: Icons.two_wheeler_rounded,
                              label: driver.vehicleNumber),
                          const SizedBox(width: 8),
                          _Chip(
                              icon: Icons.star_rounded,
                              label: driver.rating.toStringAsFixed(1)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Action buttons
                Column(
                  children: [
                    _CircleBtn(
                      icon: Icons.phone_rounded,
                      tooltip: 'Telepon driver',
                      onTap: () => _callDriver(driver.phone),
                    ),
                    const SizedBox(height: 8),
                    _CircleBtn(
                      icon: Icons.chat_rounded,
                      tooltip: 'WhatsApp driver',
                      onTap: () => _waDriver(driver),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── ETA Banner ────────────────────────────────────────────────────────────

  Widget _buildEtaBanner() {
    final done = _etaSeconds == 0;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: done
            ? const Color(0xFF10B981).withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: done
              ? const Color(0xFF10B981).withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.timer_rounded,
            color: done ? const Color(0xFF10B981) : Colors.orange,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              done
                  ? 'Driver sudah tiba! Silakan konfirmasi penerimaan.'
                  : 'Estimasi tiba dalam',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: done
                    ? const Color(0xFF10B981)
                    : Colors.orange.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (!done)
            Text(
              _etaLabel,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.orange,
              ),
            ),
        ],
      ),
    );
  }

  // ── Tab Bar ───────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TabBar(
          controller: _tab,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: ColorTheme.primaryColor,
          unselectedLabelColor: Colors.grey.shade500,
          labelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 13),
          unselectedLabelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 13),
          tabs: const [
            Tab(text: 'Info Driver'),
            Tab(text: 'Chat'),
          ],
        ),
      ),
    );
  }

  // ── Driver Info Tab ───────────────────────────────────────────────────────

  Widget _buildDriverInfo(DriverModel driver) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _InfoCard(children: [
          _InfoRow(
            icon: Icons.person_rounded,
            label: 'Nama Driver',
            value: driver.name,
          ),
          _InfoRow(
            icon: Icons.phone_rounded,
            label: 'Nomor Telepon',
            value: driver.phone,
            onCopy: () => _copy(driver.phone),
            action: TextButton.icon(
              onPressed: () => _callDriver(driver.phone),
              icon: const Icon(Icons.phone_rounded, size: 14),
              label: const Text('Telepon'),
              style: TextButton.styleFrom(
                foregroundColor: ColorTheme.primaryColor,
                textStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                backgroundColor: ColorTheme.primaryColor.withOpacity(0.08),
              ),
            ),
          ),
          _InfoRow(
            icon: Icons.two_wheeler_rounded,
            label: 'Nomor Kendaraan',
            value: driver.vehicleNumber,
            onCopy: () => _copy(driver.vehicleNumber),
          ),
          _InfoRow(
            icon: Icons.local_shipping_rounded,
            label: 'Jenis Kendaraan',
            value: driver.vehicleType,
          ),
          _InfoRow(
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFF59E0B),
            label: 'Rating Driver',
            value: '${driver.rating.toStringAsFixed(1)} / 5.0',
          ),
        ]),
        const SizedBox(height: 16),
        _InfoCard(children: [
          _InfoRow(
            icon: Icons.receipt_rounded,
            label: 'Nomor Pesanan',
            value: '#${widget.order.id.substring(8)}',
          ),
          _InfoRow(
            icon: Icons.location_on_rounded,
            label: 'Alamat Tujuan',
            value: widget.order.address.fullAddress,
          ),
          _InfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Penerima',
            value:
                '${widget.order.address.receiverName} · ${widget.order.address.phone}',
          ),
        ]),
        const SizedBox(height: 16),
        // WhatsApp shortcut
        GestureDetector(
          onTap: () => _waDriver(driver),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF25D366).withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: const Color(0xFF25D366).withOpacity(0.3), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.chat_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Chat via WhatsApp',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Color(0xFF128C7E),
                          )),
                      Text('Kirim pesan langsung ke driver',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFF25D366)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── In-App Chat Tab ───────────────────────────────────────────────────────

  Widget _buildChat() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            itemCount: _messages.length,
            itemBuilder: (_, i) => _buildBubble(_messages[i]),
          ),
        ),
        _buildChatInput(),
      ],
    );
  }

  Widget _buildBubble(_ChatMessage msg) {
    final isUser = msg.sender == _Sender.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? ColorTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
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
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(widget.order.driver!.name,
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: ColorTheme.primaryColor.withOpacity(0.8))),
              ),
            Text(msg.text,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.5,
                  color: isUser ? Colors.white : Colors.black87,
                )),
            const SizedBox(height: 4),
            Text(
              _timeLabel(msg.time),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                color: isUser
                    ? Colors.white.withOpacity(0.65)
                    : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
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
                controller: _chatCtrl,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 13.5),
                decoration: const InputDecoration(
                  hintText: 'Kirim pesan ke driver...',
                  hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 13.5),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: ColorTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ── Confirm Delivery Bar ──────────────────────────────────────────────────

  Widget _buildConfirmBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.check_circle_rounded,
              color: Colors.white, size: 20),
          label: const Text(
            'Pesanan Sudah Diterima',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorTheme.primaryColor,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: _confirmDelivery,
        ),
      ),
    );
  }
  // hilmyp70@gmail.com
  // admin@warteg.com
  // ── Helpers ───────────────────────────────────────────────────────────────

  String _timeLabel(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Disalin ke clipboard',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

// ─── Reusable sub-widgets ─────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _CircleBtn(
      {required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: children
            .expand((w) => [w, const Divider(height: 20)])
            .take(children.length * 2 - 1)
            .toList(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final String value;
  final VoidCallback? onCopy;
  final Widget? action;

  const _InfoRow({
    required this.icon,
    this.iconColor,
    required this.label,
    required this.value,
    this.onCopy,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color:
                (iconColor ?? ColorTheme.primaryColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon,
              color: iconColor ?? ColorTheme.primaryColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11.5,
                      color: Colors.grey.shade500)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  )),
            ],
          ),
        ),
        if (action != null) ...[
          const SizedBox(width: 8),
          action!,
        ] else if (onCopy != null) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onCopy,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.copy_rounded,
                  size: 16, color: Colors.grey.shade500),
            ),
          ),
        ],
      ],
    );
  }
}