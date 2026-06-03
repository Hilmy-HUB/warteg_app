import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warteg_app/model/chat_message_model.dart';

final chatProvider =
    StateNotifierProvider.family<ChatNotifier, List<ChatMessageModel>, String>(
      (ref, orderId) => ChatNotifier(orderId),
    );

// Unread untuk admin (pesan dari user yang belum dibaca admin)
final unreadCountProvider = Provider.family<int, String>((ref, orderId) {
  final messages = ref.watch(chatProvider(orderId));
  return messages
      .where((m) => m.sender == ChatSender.user && !m.isRead && !m.isSystem)
      .length;
});

// Unread untuk user (pesan dari admin yang belum dibaca user)
final unreadAdminCountProvider = Provider.family<int, String>((ref, orderId) {
  final messages = ref.watch(chatProvider(orderId));
  return messages
      .where((m) => m.sender == ChatSender.admin && !m.isRead && !m.isSystem)
      .length;
});

class ChatNotifier extends StateNotifier<List<ChatMessageModel>> {
  final String orderId;
  static const _prefix = 'chat_';

  ChatNotifier(this.orderId) : super([]) {
    _load();
  }

  String get _key => '$_prefix$orderId';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
          .toList();
      state = list;
    } catch (_) {
      // Data korup, reset
      await prefs.remove(_key);
      state = [];
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(state.map((m) => m.toJson()).toList()),
    );
  }

  /// Kirim pesan biasa (dari admin atau user)
  void sendMessage(String text, ChatSender sender) {
    debugPrint('CHAT => room:$orderId sender:$sender text:$text');

    state = [
      ...state,
      ChatMessageModel(
        id: '${orderId}_${DateTime.now().microsecondsSinceEpoch}',
        orderId: orderId,
        text: text,
        sender: sender,
        createdAt: DateTime.now(),
      ),
    ];
    _save(); // ✅ Simpan setelah kirim
  }

  /// Kirim system message (detail order otomatis, tampil sebagai info di tengah)
  /// Hanya kirim sekali per order — cek dulu apakah sudah ada system message
  void sendSystemMessage(String text) {
    // Cek apakah sudah ada system message untuk order ini
    final alreadySent = state.any((m) => m.isSystem);
    if (alreadySent) return;

    state = [
      ...state,
      ChatMessageModel(
        id: '${orderId}_sys_${DateTime.now().microsecondsSinceEpoch}',
        orderId: orderId,
        text: text,
        sender: ChatSender.user,
        createdAt: DateTime.now(),
        isRead: true,
        isSystem: true,
      ),
    ];
    _save();
  }

  /// Admin membaca semua pesan user
  void markAllRead() {
    state = state.map((m) => m.copyWith(isRead: true)).toList();
    _save();
  }

  /// User membaca semua pesan admin
  void markAllUserRead() {
    final updated = state
        .map((m) => m.sender == ChatSender.admin ? m.copyWith(isRead: true) : m)
        .toList();
    final hasChange = state.any(
      (m) => m.sender == ChatSender.admin && !m.isRead,
    );
    if (hasChange) {
      state = updated;
      _save();
    }
  }

  /// Reset/hapus semua chat untuk order ini (untuk debugging / data korup)
  Future<void> clearChat() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
