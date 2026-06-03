import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warteg_app/admin/pages/admin_chat_inbox.dart';
import 'package:warteg_app/admin/pages/menu_management_page.dart';
import 'package:warteg_app/admin/pages/order_management_page.dart';
import 'package:warteg_app/admin/pages/pick_up_management_page.dart';
import 'package:warteg_app/admin/pages/promo_management_page.dart';
import 'package:warteg_app/admin/pages/sales_report_page.dart';
import 'package:warteg_app/admin/widgets/admin_stats_card.dart';
import 'package:warteg_app/model/order_status_model.dart';
import 'package:warteg_app/provider/chat_provider.dart';
import 'package:warteg_app/provider/order_provider.dart';
import 'package:warteg_app/screen/welcome_page.dart';
import 'package:warteg_app/theme/color_theme.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_logged_in');
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => WelcomePage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderProvider);
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Pending delivery
    final pendingDelivery = orders
        .where(
          (o) =>
              o.status == OrderStatusModel.tungguKonfirmasi &&
              !o.acceptedByAdmin &&
              o.deliveryType == 'delivery',
        )
        .length;

    // Pending pickup
    final pendingPickup = orders
        .where(
          (o) =>
              o.status == OrderStatusModel.tungguKonfirmasi &&
              !o.acceptedByAdmin &&
              o.deliveryType == 'pickup',
        )
        .length;

    final todayRevenue = orders
        .where(
          (o) =>
              o.status == OrderStatusModel.selesai &&
              o.createdAt.day == DateTime.now().day &&
              o.createdAt.month == DateTime.now().month &&
              o.createdAt.year == DateTime.now().year,
        )
        .fold(0, (sum, o) => sum + (o.subtotal - o.discount));

    final totalDone = orders
        .where((o) => o.status == OrderStatusModel.selesai)
        .length;

    return Scaffold(
      backgroundColor: ColorTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 25, 20, 30),
                decoration: const BoxDecoration(
                  color: ColorTheme.primaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Admin Dashboard',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Consumer(
                          builder: (_, ref, __) {
                            final allOrders = ref.watch(
                              orderProvider,
                            ); // ✅ ganti nama biar tidak shadow
                            final totalUnread = allOrders.fold<int>(
                              0,
                              (sum, o) =>
                                  sum + ref.watch(unreadCountProvider(o.id)),
                            );
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AdminChatInboxPage(),
                                ),
                              ),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.forum_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Chat',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (totalUnread > 0)
                                    Positioned(
                                      right: -4,
                                      top: -4,
                                      child: Container(
                                        width: 18,
                                        height: 18,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            totalUnread > 99
                                                ? '99+'
                                                : '$totalUnread',
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
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat(
                        'EEEE, d MMMM yyyy',
                        'id',
                      ).format(DateTime.now()),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.75),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Profile card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Halo, Admin!',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Selamat datang kembali 👋',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.8),
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

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Stat Cards ─────────────────────────────
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.5,
                      children: [
                        // Pending delivery
                        AdminStatCard(
                          title: 'Delivery Pending',
                          value: '$pendingDelivery',
                          icon: Icons.delivery_dining_rounded,
                          color: Colors.orange,
                          subtitle: 'Menunggu konfirmasi',
                        ),
                        // Pending pickup
                        AdminStatCard(
                          title: 'Pickup Pending',
                          value: '$pendingPickup',
                          icon: Icons.storefront_rounded,
                          color: const Color(0xFF10B981),
                          subtitle: 'Menunggu konfirmasi',
                        ),
                        AdminStatCard(
                          title: 'Pendapatan',
                          value: currency.format(todayRevenue),
                          icon: Icons.attach_money_rounded,
                          color: ColorTheme.primaryColor,
                          subtitle: 'Hari ini',
                        ),
                        AdminStatCard(
                          title: 'Selesai',
                          value: '$totalDone',
                          icon: Icons.check_circle_outline_rounded,
                          color: Colors.blue,
                          subtitle: 'Total',
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── Menu Admin ────────────────────────────
                    const Text(
                      'Menu Admin',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _navCard(
                      context,
                      icon: Icons.delivery_dining_rounded,
                      color: Colors.orange,
                      title: 'Pesanan Delivery',
                      subtitle: pendingDelivery > 0
                          ? '$pendingDelivery pesanan menunggu konfirmasi'
                          : 'Kelola pesanan delivery',
                      badge: pendingDelivery > 0 ? '$pendingDelivery' : null,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OrderManagementPage(),
                        ),
                      ),
                    ),
                    _navCard(
                      context,
                      icon: Icons.storefront_rounded,
                      color: const Color(0xFF10B981),
                      title: 'Pesanan Pickup',
                      subtitle: pendingPickup > 0
                          ? '$pendingPickup pesanan menunggu konfirmasi'
                          : 'Kelola pesanan pickup',
                      badge: pendingPickup > 0 ? '$pendingPickup' : null,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PickupOrderPage(),
                        ),
                      ),
                    ),
                    _navCard(
                      context,
                      icon: Icons.menu_book_rounded,
                      color: Colors.blue,
                      title: 'Kelola Menu',
                      subtitle: 'Tambah, edit, hapus menu makanan',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MenuManagementPage(),
                        ),
                      ),
                    ),
                    _navCard(
                      context,
                      icon: Icons.local_offer_rounded,
                      color: Colors.pink,
                      title: 'Kelola Promo',
                      subtitle: 'Atur diskon dan promo aktif',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PromoManagementPage(),
                        ),
                      ),
                    ),
                    _navCard(
                      context,
                      icon: Icons.bar_chart_rounded,
                      color: ColorTheme.primaryColor,
                      title: 'Laporan Penjualan',
                      subtitle: 'Statistik & grafik pendapatan',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SalesReportPage(),
                        ),
                      ),
                    ),

                    // ── Logout card ─────────────────────────────────────
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: const Text(
                                'Logout?',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              content: const Text(
                                'Yakin ingin keluar dari akun admin?',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text(
                                    'Batal',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Logout',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true && context.mounted)
                            _logout(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.red.shade100),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Icon(
                                  Icons.logout_rounded,
                                  color: Colors.red,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Logout',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      'Keluar dari akun admin',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: Colors.redAccent,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8), // sedikit ruang di bawah
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    String? badge,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              if (badge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
