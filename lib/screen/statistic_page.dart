import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warteg_app/model/order_status_model.dart';
import 'package:warteg_app/provider/order_provider.dart';
import 'package:warteg_app/provider/purchase_history_provider.dart';
import 'package:warteg_app/controller/auth_controller.dart';
import 'package:warteg_app/theme/color_theme.dart';

class PurchaseStatisticsPage extends ConsumerWidget {
  const PurchaseStatisticsPage({super.key});

  // ── Format Rupiah ────────────────────────────────────────────────────────────
  static String _formatRupiah(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();
    final mod = s.length % 3;
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (i - mod) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  // ── Format tanggal ───────────────────────────────────────────────────────────
  static String _formatDate(DateTime? date) {
    if (date == null) return '-';
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allOrders = ref.watch(orderProvider);
    final orders = allOrders
        .where((o) => o.status == OrderStatusModel.selesai)
        .toList();
    final purchaseHistory = ref.watch(purchaseHistoryProvider);
    final user = ref.watch(currentUserProvider);

    // ── Kalkulasi statistik ──────────────────────────────────────────────────
    final totalOrders = orders.length;
    final totalSpending = orders.fold<int>(0, (sum, o) => sum + o.total);

    // Tanggal akun dibuat: ambil order paling lama sebagai proxy,
    // atau pakai createdAt dari user jika tersedia
    final DateTime? accountSince = orders.isNotEmpty
        ? orders.map((o) => o.createdAt).reduce((a, b) => a.isBefore(b) ? a : b)
        : null;

    // ── Menu favorit: purchaseHistory sudah Map<String, int> ────────────────
    final sortedMenus = purchaseHistory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topMenus = sortedMenus.take(5).toList();

    // ── Kalkulasi per bulan (6 bulan terakhir) ───────────────────────────────
    final now = DateTime.now();
    final monthlyData = List.generate(6, (i) {
      final month = DateTime(now.year, now.month - (5 - i));
      final count = orders.where((o) {
        return o.createdAt.year == month.year &&
            o.createdAt.month == month.month;
      }).length;
      return _MonthlyData(month: month, count: count);
    });
    final maxMonthlyCount = monthlyData
        .map((m) => m.count)
        .fold(0, (a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F4),
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ────────────────────────────────────────────────────
            _AppBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                children: [
                  // ── Hero Summary Card ──────────────────────────────────
                  _HeroSummaryCard(
                    username: user?['username'] ?? 'User',
                    totalOrders: totalOrders,
                    totalSpending: totalSpending,
                    accountSince: accountSince,
                    formatRupiah: _formatRupiah,
                    formatDate: _formatDate,
                  ),

                  const SizedBox(height: 24),

                  // ── Stats Grid ─────────────────────────────────────────
                  _StatGrid(
                    totalOrders: totalOrders,
                    totalSpending: totalSpending,
                    formatRupiah: _formatRupiah,
                  ),

                  const SizedBox(height: 24),

                  // ── Grafik Bulanan ─────────────────────────────────────
                  _SectionLabel(label: 'Aktivitas 6 Bulan Terakhir'),
                  const SizedBox(height: 12),
                  _MonthlyChart(data: monthlyData, maxCount: maxMonthlyCount),

                  const SizedBox(height: 24),

                  // ── Menu Favorit ───────────────────────────────────────
                  _SectionLabel(label: 'Menu Favorit Kamu 🍽️'),
                  const SizedBox(height: 12),

                  if (topMenus.isEmpty)
                    _EmptyFavorite()
                  else
                    ...topMenus.asMap().entries.map(
                      (entry) => _FavoriteMenuCard(
                        rank: entry.key + 1,
                        menuName: entry.value.key,
                        count: entry.value.value,
                        total: sortedMenus.first.value,
                        index: entry.key,
                      ),
                    ),

                  const SizedBox(height: 24),

                  // ── Akun Sejak ─────────────────────────────────────────
                  _AccountSinceCard(
                    accountSince: accountSince,
                    formatDate: _formatDate,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 40,
              height: 40,
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
                size: 17,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Statistik Pembelian',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
        letterSpacing: -0.2,
      ),
    );
  }
}

// ─── Hero Summary Card ────────────────────────────────────────────────────────

class _HeroSummaryCard extends StatelessWidget {
  final String username;
  final int totalOrders;
  final int totalSpending;
  final DateTime? accountSince;
  final String Function(int) formatRupiah;
  final String Function(DateTime?) formatDate;

  const _HeroSummaryCard({
    required this.username,
    required this.totalOrders,
    required this.totalSpending,
    required this.accountSince,
    required this.formatRupiah,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ColorTheme.primaryColor, Color(0xFF1B6650)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ColorTheme.primaryColor.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ringkasan Aktivitas',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Halo, $username!',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Row(
              children: [
                _HeroStat(label: 'Total Pesanan', value: '$totalOrders'),
                Container(
                  width: 1,
                  height: 48,
                  color: Colors.white24,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                _HeroStat(
                  label: 'Total Pengeluaran',
                  value: 'Rp ${formatRupiah(totalSpending)}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.white70,
                  size: 14,
                ),
                const SizedBox(width: 8),
                Text(
                  accountSince != null
                      ? 'Pelanggan sejak ${formatDate(accountSince)}'
                      : 'Belum ada pesanan',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;

  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Grid (2 kolom) ──────────────────────────────────────────────────────

class _StatGrid extends StatelessWidget {
  final int totalOrders;
  final int totalSpending;
  final String Function(int) formatRupiah;

  const _StatGrid({
    required this.totalOrders,
    required this.totalSpending,
    required this.formatRupiah,
  });

  @override
  Widget build(BuildContext context) {
    // Rata-rata per pesanan
    final avgSpending = totalOrders > 0 ? totalSpending ~/ totalOrders : 0;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.receipt_long_rounded,
            iconColor: const Color(0xFF6366F1),
            iconBg: const Color(0xFFEEF2FF),
            label: 'Total Pesanan',
            value: '$totalOrders',
            suffix: '',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.wallet_rounded,
            iconColor: const Color(0xFFF59E0B),
            iconBg: const Color(0xFFFFFBEB),
            label: 'Rata-rata/Pesanan',
            value: 'Rp ${formatRupiah(avgSpending)}',
            suffix: '',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final String suffix;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.suffix,
  });

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            suffix,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Monthly Chart ────────────────────────────────────────────────────────────

class _MonthlyData {
  final DateTime month;
  final int count;
  _MonthlyData({required this.month, required this.count});
}

class _MonthlyChart extends StatelessWidget {
  final List<_MonthlyData> data;
  final int maxCount;

  const _MonthlyChart({required this.data, required this.maxCount});

  static const _shortMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Ags',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.show_chart_rounded,
                color: ColorTheme.primaryColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'Jumlah Pesanan per Bulan',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((item) {
                final ratio = maxCount == 0 ? 0.0 : item.count / maxCount;
                final barHeight = 80.0 * ratio;
                final isCurrentMonth =
                    item.month.year == DateTime.now().year &&
                    item.month.month == DateTime.now().month;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Count label
                        if (item.count > 0)
                          Text(
                            '${item.count}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isCurrentMonth
                                  ? ColorTheme.primaryColor
                                  : Colors.grey.shade500,
                            ),
                          ),
                        const SizedBox(height: 4),
                        // Bar
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          height: barHeight > 0 ? barHeight : 4,
                          decoration: BoxDecoration(
                            color: isCurrentMonth
                                ? ColorTheme.primaryColor
                                : ColorTheme.primaryColor.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Month label
                        Text(
                          _shortMonths[item.month.month - 1],
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: isCurrentMonth
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isCurrentMonth
                                ? ColorTheme.primaryColor
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Favorite Menu Card ───────────────────────────────────────────────────────

class _FavoriteMenuCard extends StatelessWidget {
  final int rank;
  final String menuName;
  final int count;
  final int total; // count terbesar untuk progress bar
  final int index;

  const _FavoriteMenuCard({
    required this.rank,
    required this.menuName,
    required this.count,
    required this.total,
    required this.index,
  });

  static const _rankColors = [
    Color(0xFFFFD700), // Gold
    Color(0xFFC0C0C0), // Silver
    Color(0xFFCD7F32), // Bronze
    Color(0xFF6366F1), // Indigo
    Color(0xFF10B981), // Green
  ];

  static const _rankEmoji = ['🥇', '🥈', '🥉', '4️⃣', '5️⃣'];

  @override
  Widget build(BuildContext context) {
    final color = _rankColors[index.clamp(0, _rankColors.length - 1)];
    final progress = total > 0 ? count / total : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          // Rank badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                _rankEmoji[index.clamp(0, _rankEmoji.length - 1)],
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Menu info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        menuName,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${count}x dipesan',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: color.withOpacity(0.85),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      color.withOpacity(0.7),
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty Favorite ───────────────────────────────────────────────────────────

class _EmptyFavorite extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_outlined,
            size: 48,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada riwayat pembelian',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Account Since Card ───────────────────────────────────────────────────────

class _AccountSinceCard extends StatelessWidget {
  final DateTime? accountSince;
  final String Function(DateTime?) formatDate;

  const _AccountSinceCard({
    required this.accountSince,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    // Hitung durasi sejak pesanan pertama
    String durationText = '';
    if (accountSince != null) {
      final diff = DateTime.now().difference(accountSince!);
      final days = diff.inDays;
      if (days >= 365) {
        final years = days ~/ 365;
        durationText = '$years tahun bersama kami';
      } else if (days >= 30) {
        final months = days ~/ 30;
        durationText = '$months bulan bersama kami';
      } else {
        durationText = '$days hari bersama kami';
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFF0FDF4), const Color(0xFFECFDF5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🎉', style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bergabung Sejak',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF10B981),
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  accountSince != null
                      ? formatDate(accountSince)
                      : 'Buat pesanan pertamamu!',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                if (durationText.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    durationText,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.grey.shade500,
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
}
