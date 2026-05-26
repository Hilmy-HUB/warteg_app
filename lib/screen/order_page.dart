import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warteg_app/model/order_model.dart';
import 'package:warteg_app/model/order_status_model.dart';
import 'package:warteg_app/provider/order_provider.dart';
import 'package:warteg_app/screen/invoice_page.dart';
import 'package:warteg_app/theme/color_theme.dart';

class OrderPage extends ConsumerStatefulWidget {
  const OrderPage({super.key});

  @override
  ConsumerState<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends ConsumerState<OrderPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> tabs = [
    "Bayar",
    "Diproses",
    "Dijemput",
    "Diantar",
    "Selesai",
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: tabs.length, vsync: this);
  }

  List<OrderModel> getOrdersByStatus(
    List<OrderModel> allOrders,
    OrderStatusModel status,
  ) {
    return allOrders.where((order) => order.status == status).toList();
  }

  Color getStatusColor(OrderStatusModel status) {
    switch (status) {
      case OrderStatusModel.bayar:
        return Colors.red;

      case OrderStatusModel.diproses:
        return Colors.orange;

      case OrderStatusModel.dijemput:
        return Colors.blue;

      case OrderStatusModel.diantar:
        return Colors.purple;

      case OrderStatusModel.selesai:
        return Colors.green;

      default:
        return Colors.grey;
    }
  }

  String formatRupiah(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();

    final mod = s.length % 3;

    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (i - mod) % 3 == 0) {
        buf.write('.');
      }

      buf.write(s[i]);
    }

    return buf.toString();
  }

  Widget buildOrderCard(OrderModel order) {
    return GestureDetector(
      onTap: () {
        if (order.status == OrderStatusModel.bayar) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InvoicePage(
                order: order,
                vaNumber: order.vaNumber,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 5,
              width: double.infinity,
              decoration: BoxDecoration(
                color: getStatusColor(order.status),
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Order #${order.id.substring(8)}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: getStatusColor(order.status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    order.status.toString().split('.').last,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: getStatusColor(order.status),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Column(
              children: order.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.network(
                          item.image,
                          width: 74,
                          height: 74,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.menuName,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              '${item.quantity} x Rp ${formatRupiah(item.hargaSatuan)}',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),

                            if (item.addOns.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: item.addOns
                                      .map(
                                        (e) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 9,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: ColorTheme.buttonPrimary
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          child: Text(
                                            '+ $e',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontFamily: 'Poppins',
                                              color: ColorTheme.buttonPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      Text(
                        'Rp ${formatRupiah(item.totalHarga)}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: ColorTheme.buttonPrimary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const Divider(height: 30),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.grey.shade600,
                        size: 18,
                      ),

                      const SizedBox(width: 8),

                      const Text(
                        'Alamat',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),

                      const Spacer(),

                      Expanded(
                        child: Text(
                          order.address.label,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Icon(
                        Icons.payments_outlined,
                        color: Colors.grey.shade600,
                        size: 18,
                      ),

                      const SizedBox(width: 8),

                      const Text(
                        'Pembayaran',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),

                      const Spacer(),

                      Text(
                        order.paymentMethod.name,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: ColorTheme.buttonPrimary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Text(
                    'Total Belanja',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  const Spacer(),

                  Text(
                    'Rp ${formatRupiah(order.total)}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: ColorTheme.buttonPrimary,
                    ),
                  ),
                ],
              ),
            ),

            if (order.status == OrderStatusModel.bayar) ...[
              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.red),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        'Silakan selesaikan pembayaran virtual account',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    ref
                        .read(orderProvider.notifier)
                        .updateOrderStatus(order.id, OrderStatusModel.diproses);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pembayaran berhasil')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorTheme.buttonPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Bayar Sekarang',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildTabContent(OrderStatusModel status) {
    final allOrders = ref.watch(orderProvider);

    final orders = getOrdersByStatus(allOrders, status);

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 60,
                color: Colors.grey.shade300,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Belum ada pesanan',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Pesanan kamu akan muncul di sini',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(18),
      itemCount: orders.length,
      itemBuilder: (_, index) {
        return buildOrderCard(orders[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Pesanan Saya',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(95),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Container(
              height: 58,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(22),
              ),
              child: TabBar(
                tabAlignment: TabAlignment.start,
                controller: _tabController,
                isScrollable: true,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                splashBorderRadius: BorderRadius.circular(18),
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                labelColor: ColorTheme.buttonPrimary,
                unselectedLabelColor: Colors.grey.shade500,
                labelStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                labelPadding: const EdgeInsets.symmetric(horizontal: 18),
                tabs: tabs.map((e) {
                  return SizedBox(height: 46, child: Center(child: Text(e)));
                }).toList(),
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildTabContent(OrderStatusModel.bayar),
          buildTabContent(OrderStatusModel.diproses),
          buildTabContent(OrderStatusModel.dijemput),
          buildTabContent(OrderStatusModel.diantar),
          buildTabContent(OrderStatusModel.selesai),
        ],
      ),
    );
  }
}
