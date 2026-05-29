import 'dart:convert';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warteg_app/model/notification_model.dart';

const String _notifKey = 'notifications';

class NotificationNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationNotifier() : super([]) {
    _loadFromPrefs();
  }

  // =========================
  // LOAD DARI PREFS
  // =========================

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_notifKey);

    if (raw == null) return;

    final List decoded = jsonDecode(raw);
    state = decoded.map((e) => NotificationModel.fromJson(e)).toList();
  }

  // =========================
  // SIMPAN KE PREFS
  // =========================

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(state.map((e) => e.toJson()).toList());
    await prefs.setString(_notifKey, encoded);
  }

  // =========================
  // ADD NOTIFICATION
  // =========================

  Future<void> addNotification({
    required String title,
    required String message,
    String? orderId,
  }) async {
    state = [
      NotificationModel(
        title: title,
        message: message,
        orderId: orderId,
        createdAt: DateTime.now(),
      ),
      ...state,
    ];
    await _saveToPrefs();
  }

  // =========================
  // MARK ALL AS READ
  // =========================

  Future<void> markAllAsRead() async {
    state = state.map((e) => e.copyWith(isRead: true)).toList();
    await _saveToPrefs();
  }

  bool get hasUnread => state.any((e) => !e.isRead);
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<NotificationModel>>(
  (ref) => NotificationNotifier(),
);