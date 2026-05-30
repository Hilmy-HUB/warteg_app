import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warteg_app/model/order_status_model.dart';
import 'package:warteg_app/provider/navbar_provider.dart';
import 'package:warteg_app/provider/notification_provider.dart';
import 'package:warteg_app/provider/order_tab_provider.dart';
import 'package:warteg_app/theme/color_theme.dart';

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  String formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');

    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  OrderStatusModel getTargetTab(String title) {
    final lower = title.toLowerCase();

    if (lower.contains('pembayaran')) {
      return OrderStatusModel.tungguKonfirmasi;
    }

    if (lower.contains('konfirmasi')) {
      return OrderStatusModel.tungguKonfirmasi;
    }

    if (lower.contains('diproses')) {
      return OrderStatusModel.diproses;
    }

    if (lower.contains('diantar')) {
      return OrderStatusModel.diantar;
    }

    if (lower.contains('selesai')) {
      return OrderStatusModel.selesai;
    }

    if (lower.contains('dibatalkan')) {
      return OrderStatusModel.dibatalkan;
    }

    return OrderStatusModel.bayar;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationProvider);

    Future.microtask(() {
      ref.read(notificationProvider.notifier).markAllAsRead();
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),

      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 70,
                    color: Colors.grey.shade300,
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Belum ada notifikasi',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
              itemCount: notifications.length,
              itemBuilder: (_, index) {
                final notif = notifications[index];

                return GestureDetector(
                  onTap: () {
                    final isPickup = notif.title.contains('Pickup');

                    if (notif.title.contains('Pembayaran')) {
                      ref.read(orderTabProvider.notifier).state =
                          OrderStatusModel.tungguKonfirmasi;
                    } else if (notif.title.contains('Dibatalkan')) {
                      ref.read(orderTabProvider.notifier).state =
                          OrderStatusModel.dibatalkan;
                    } else if (notif.title.contains('Diantar')) {
                      ref.read(orderTabProvider.notifier).state =
                          OrderStatusModel.diantar;
                    } else if (notif.title.contains('Selesai')) {
                      ref.read(orderTabProvider.notifier).state =
                          OrderStatusModel.selesai;
                    } else if (isPickup) {
                      ref.read(orderTabProvider.notifier).state =
                          OrderStatusModel.tungguKonfirmasi;
                    } else {
                      ref.read(orderTabProvider.notifier).state =
                          OrderStatusModel.bayar;
                    }

                    // arahkan ke navbar yang sesuai
                    ref.read(navbarIndexProvider.notifier).state = isPickup
                        ? 3
                        : 2;

                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: ColorTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.notifications_rounded,
                            color: ColorTheme.primaryColor,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notif.title,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                notif.message,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                formatTime(notif.createdAt),
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
