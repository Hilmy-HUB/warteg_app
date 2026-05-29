import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:warteg_app/model/order_model.dart';
import 'package:warteg_app/model/order_status_model.dart';
import 'package:warteg_app/provider/order_provider.dart';

class OrderManagementPage extends ConsumerStatefulWidget {
  const OrderManagementPage({super.key});

  @override
  ConsumerState<OrderManagementPage> createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends ConsumerState<OrderManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(orderProvider);

    // Sesuaikan dengan OrderStatusModel yang ada
    final pending  = orders.where((o) => o.status == OrderStatusModel.bayar).toList();
    final active   = orders.where((o) =>
        o.status == OrderStatusModel.diproses ||
        o.status == OrderStatusModel.dijemput ||
        o.status == OrderStatusModel.diantar).toList();
    final done     = orders.where((o) => o.status == OrderStatusModel.selesai).toList();
    final rejected = orders.where((o) => o.status == OrderStatusModel.dibatalkan).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Kelola Pesanan',
            style: TextStyle(
                fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.black87)),
        bottom: TabBar(
          controller: _tab,
          labelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins'),
          labelColor: Colors.redAccent,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.redAccent,
          tabs: [
            Tab(text: 'Baru (${pending.length})'),
            Tab(text: 'Proses (${active.length})'),
            Tab(text: 'Selesai (${done.length})'),
            Tab(text: 'Dibatalkan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _OrderList(orders: pending, showActions: true),
          _OrderList(orders: active, showStatus: true),
          _OrderList(orders: done),
          _OrderList(orders: rejected),
        ],
      ),
    );
  }
}

class _OrderList extends ConsumerWidget {
  final List<OrderModel> orders;
  final bool showActions;
  final bool showStatus;

  const _OrderList({required this.orders, this.showActions = false, this.showStatus = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 60, color: Colors.grey),
            SizedBox(height: 12),
            Text('Tidak ada pesanan', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (_, i) => _OrderCard(
        order: orders[i],
        showActions: showActions,
        showStatus: showStatus,
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final OrderModel order;
  final bool showActions;
  final bool showStatus;

  const _OrderCard({required this.order, this.showActions = false, this.showStatus = false});

  Color _statusColor(OrderStatusModel s) => switch (s) {
        OrderStatusModel.bayar      => Colors.orange,
        OrderStatusModel.diproses   => Colors.blue,
        OrderStatusModel.dijemput   => Colors.purple,
        OrderStatusModel.diantar    => Colors.teal,
        OrderStatusModel.selesai    => Colors.green,
        OrderStatusModel.dibatalkan => Colors.red,
      };

  String _statusLabel(OrderStatusModel s) => switch (s) {
        OrderStatusModel.bayar      => 'Menunggu Bayar',
        OrderStatusModel.diproses   => 'Diproses',
        OrderStatusModel.dijemput   => 'Siap Dijemput',
        OrderStatusModel.diantar    => 'Diantar',
        OrderStatusModel.selesai    => 'Selesai',
        OrderStatusModel.dibatalkan => 'Dibatalkan',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final notifier = ref.read(orderProvider.notifier);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header — pakai receiverName & phone dari AddressModel
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.address.receiverName,
                    style: const TextStyle(
                        fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 14)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: _statusColor(order.status).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(_statusLabel(order.status),
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _statusColor(order.status))),
                ),
              ],
            ),
            Text(order.address.phone,
                style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey[600])),
            Text(order.address.fullAddress,
                style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey[500]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(DateFormat('d MMM yyyy, HH:mm').format(order.createdAt),
                style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey[400])),

            const Divider(height: 20),

            // Items
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item.quantity}x ${item.menuName}',
                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                      Text(currency.format(item.hargaSatuan * item.quantity),
                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                    ],
                  ),
                )),

            const Divider(height: 16),

            // Subtotal, ongkir, diskon
            if (order.ongkir > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Ongkir', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey[600])),
                  Text(currency.format(order.ongkir),
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            if (order.discount > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Diskon', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.green[600])),
                  Text('- ${currency.format(order.discount)}',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.green[600])),
                ],
              ),

            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                Text(currency.format(order.total),
                    style: const TextStyle(
                        fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.redAccent)),
              ],
            ),

            // Actions untuk tab "Baru" (status: bayar)
            if (showActions) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent),
                          foregroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Batalkan', style: TextStyle(fontFamily: 'Poppins')),
                      onPressed: () => notifier.updateOrderStatus(order.id, OrderStatusModel.dibatalkan),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Proses', style: TextStyle(fontFamily: 'Poppins')),
                      onPressed: () => notifier.updateOrderStatus(order.id, OrderStatusModel.diproses),
                    ),
                  ),
                ],
              ),
            ],

            // Dropdown untuk tab "Proses"
            if (showStatus) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<OrderStatusModel>(
                value: order.status,
                decoration: InputDecoration(
                  labelText: 'Update Status',
                  labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.black87),
                items: const [
                  DropdownMenuItem(value: OrderStatusModel.diproses, child: Text('Diproses')),
                  DropdownMenuItem(value: OrderStatusModel.dijemput, child: Text('Siap Dijemput')),
                  DropdownMenuItem(value: OrderStatusModel.diantar,  child: Text('Sedang Diantar')),
                  DropdownMenuItem(value: OrderStatusModel.selesai,  child: Text('Selesai')),
                ],
                onChanged: (s) {
                  if (s != null) notifier.updateOrderStatus(order.id, s);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}