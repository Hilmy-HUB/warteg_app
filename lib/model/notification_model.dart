// lib/model/notification_model.dart

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

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'message': message,
      'orderId': orderId,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      title: json['title'],
      message: json['message'],
      orderId: json['orderId'],
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
    );
  }
}