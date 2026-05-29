import 'package:flutter_riverpod/legacy.dart';

class NotificationModel {
  final String title;
  final String message;
  final String? orderId;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.title,
    required this.message,
    this.orderId,
    required this.createdAt,
    this.isRead = false,
  });

  NotificationModel copyWith({
    String? title,
    String? message,
    String? orderId,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      title: title ?? this.title,
      message: message ?? this.message,
      orderId: orderId ?? this.orderId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

class NotificationNotifier
    extends StateNotifier<List<NotificationModel>> {
  NotificationNotifier() : super([]);

  void addNotification({
    required String title,
    required String message,
    String? orderId,
  }) {
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

  void markAllAsRead() {
    state = state
        .map((e) => e.copyWith(isRead: true))
        .toList();
  }

  bool get hasUnread {
    return state.any((e) => !e.isRead);
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier,
        List<NotificationModel>>(
  (ref) => NotificationNotifier(),
);