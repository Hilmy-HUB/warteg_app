// lib/admin/pages/admin_dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warteg_app/admin/pages/menu_management_page.dart';
import 'package:warteg_app/admin/pages/order_management_page.dart';
import 'package:warteg_app/admin/pages/promo_management_page.dart';
import 'package:warteg_app/admin/pages/sales_report_page.dart';
import 'package:warteg_app/admin/widgets/admin_stats_card.dart';
import 'package:warteg_app/model/order_status_model.dart';
import 'package:warteg_app/provider/order_provider.dart';
import 'package:warteg_app/screen/welcome_page.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
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
        locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    final pendingCount = orders
        .where((o) => o.status == OrderStatusModel.bayar)
        .length;

    final todayRevenue = orders
        .where((o) =>
            o.status == OrderStatusModel.selesai &&
            o.createdAt.day   == DateTime.now().day &&
            o.createdAt.month == DateTime.now().month &&
            o.createdAt.year  == DateTime.now().year)
        .fold(0, (sum, o) => sum + o.total);

    final totalDone =
        orders.where((o) => o.status == OrderStatusModel.selesai).length;

    // ... sisa kode tidak berubah

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Colors.black87),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Greeting
          const Text(
            'Selamat datang, Admin 👋',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
          Text(
            DateFormat('EEEE, d MMMM yyyy', 'id').format(DateTime.now()),
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: Colors.grey[600]),
          ),

          const SizedBox(height: 20),

          // Stat Cards
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.4,
            children: [
              AdminStatCard(
                title: 'Pesanan Pending',
                value: '$pendingCount',
                icon: Icons.pending_actions,
                color: Colors.orange,
                subtitle: 'Hari ini',
              ),
              AdminStatCard(
                title: 'Pendapatan',
                value: currency.format(todayRevenue),
                icon: Icons.attach_money,
                color: Colors.green,
                subtitle: 'Hari ini',
              ),
              AdminStatCard(
                title: 'Selesai',
                value: '$totalDone',
                icon: Icons.check_circle_outline,
                color: Colors.blue,
                subtitle: 'Total',
              ),
              AdminStatCard(
                title: 'Total Pesanan',
                value: '${orders.length}',
                icon: Icons.receipt_long,
                color: Colors.purple,
                subtitle: 'Semua',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Menu navigasi
          const Text(
            'Menu Admin',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          _navCard(
            context,
            icon: Icons.receipt_long,
            color: Colors.orange,
            title: 'Kelola Pesanan',
            subtitle: '$pendingCount pesanan baru menunggu',
            badge: pendingCount > 0 ? '$pendingCount' : null,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const OrderManagementPage()),
            ),
          ),
          _navCard(
            context,
            icon: Icons.menu_book,
            color: Colors.blue,
            title: 'Kelola Menu',
            subtitle: 'Tambah, edit, hapus menu makanan',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const MenuManagementPage()),
            ),
          ),
          _navCard(
            context,
            icon: Icons.local_offer,
            color: Colors.pink,
            title: 'Kelola Promo',
            subtitle: 'Atur diskon dan promo aktif',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const PromoManagementPage()),
            ),
          ),
          _navCard(
            context,
            icon: Icons.bar_chart,
            color: Colors.green,
            title: 'Laporan Penjualan',
            subtitle: 'Statistik & grafik pendapatan',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const SalesReportPage()),
            ),
          ),
        ],
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 14)),
        subtitle: Text(subtitle,
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: Colors.grey[600])),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(badge,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontFamily: 'Poppins')),
              ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios,
                size: 15, color: Colors.grey),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}