import 'package:flutter_riverpod/legacy.dart';
import 'package:warteg_app/model/notification_model.dart';
import 'package:warteg_app/services/api_service.dart';

class NotificationNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationNotifier() : super([]) {
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final List data = await ApiService.get('/api/notifications');
      state = data.map((e) => NotificationModel.fromJson(e)).toList();
    } catch (e) {
      state = [];
    }
  }

  Future<void> addNotification({
    required String title,
    required String message,
    String? orderId,
  }) async {
    // Add locally to state for instant user feedback
    state = [
      NotificationModel(
        title: title,
        message: message,
        orderId: orderId,
        createdAt: DateTime.now(),
      ),
      ...state,
    ];
  }

  Future<void> markAllAsRead() async {
    try {
      await ApiService.put('/api/notifications/read-all', {});
      state = state.map((e) => e.copyWith(isRead: true)).toList();
    } catch (e) {
      state = state.map((e) => e.copyWith(isRead: true)).toList();
    }
  }

  bool get hasUnread => state.any((e) => !e.isRead);
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<NotificationModel>>(
  (ref) => NotificationNotifier(),
);