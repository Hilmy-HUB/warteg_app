import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:warteg_app/model/order_status_model.dart';
import 'package:warteg_app/provider/order_provider.dart';

class SalesReportPage extends ConsumerWidget {
  const SalesReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderProvider);
    final done   = orders.where((o) => o.status == OrderStatusModel.selesai).toList();
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    final totalRevenue = done.fold(0, (s, o) => s + o.total);
    final todayDone    = done.where((o) =>
        o.createdAt.day   == DateTime.now().day &&
        o.createdAt.month == DateTime.now().month &&
        o.createdAt.year  == DateTime.now().year).toList();
    final todayRevenue = todayDone.fold(0, (s, o) => s + o.total);

    // Item terlaris — pakai CartItemModel dari order.items
    final Map<String, int> itemCount = {};
    for (final o in done) {
      for (final item in o.items) {
        itemCount[item.menuName] = (itemCount[item.menuName] ?? 0) + item.quantity;
      }
    }
    final sortedItems = itemCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Laporan Penjualan',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.black87)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: _SummaryCard(
                label: 'Total Pendapatan', value: currency.format(totalRevenue),
                icon: Icons.attach_money, color: Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _SummaryCard(
                label: 'Pendapatan Hari Ini', value: currency.format(todayRevenue),
                icon: Icons.today, color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _SummaryCard(
                label: 'Total Pesanan Selesai', value: '${done.length}',
                icon: Icons.check_circle, color: Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _SummaryCard(
                label: 'Selesai Hari Ini', value: '${todayDone.length}',
                icon: Icons.today_outlined, color: Colors.purple)),
            ],
          ),

          const SizedBox(height: 24),
          const Text('Menu Terlaris',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),

          if (sortedItems.isEmpty)
            const Center(child: Text('Belum ada data', style: TextStyle(fontFamily: 'Poppins')))
          else
            ...sortedItems.take(5).toList().asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final item = entry.value;
              final maxQty = sortedItems.first.value.toDouble();
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.redAccent.withOpacity(0.12),
                          child: Text('$rank',
                              style: const TextStyle(
                                  fontFamily: 'Poppins', fontSize: 11,
                                  fontWeight: FontWeight.bold, color: Colors.redAccent)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(item.key,
                              style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                        ),
                        Text('${item.value}x',
                            style: const TextStyle(
                                fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.redAccent)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: item.value / maxQty,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation(Colors.redAccent),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 24),
          const Text('Riwayat Pesanan Selesai',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),

          ...done.reversed.take(10).map((o) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long, color: Colors.green, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pakai receiverName dari AddressModel
                          Text(o.address.receiverName,
                              style: const TextStyle(
                                  fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(DateFormat('d MMM, HH:mm').format(o.createdAt),
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey[500])),
                        ],
                      ),
                    ),
                    Text(currency.format(o.total),
                        style: const TextStyle(
                            fontFamily: 'Poppins', fontWeight: FontWeight.bold,
                            color: Colors.green, fontSize: 13)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;

  const _SummaryCard(
      {required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontFamily: 'Poppins', fontWeight: FontWeight.bold,
                  fontSize: 15, color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: Colors.grey[600])),
        ],
      ),
    );
  }
}