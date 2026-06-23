import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warteg_app/model/chat_message_model.dart';
import 'package:warteg_app/services/api_service.dart';
import 'package:warteg_app/services/auth_service.dart';

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
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  ChatNotifier(this.orderId) : super([]) {
    _load();
  }

  Future<void> _load() async {
    try {
      // 1. Fetch chat history from HTTP API
      final List data = await ApiService.get('/api/chats?orderId=$orderId');
      state = data.map((e) => ChatMessageModel.fromJson(e)).toList();
    } catch (e) {
      state = [];
    }

    // 2. Connect WebSocket for real-time messages
    _connectWebSocket();
  }

  Future<void> _connectWebSocket() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString(AuthService.currentUserKey);
      if (userString == null) return;
      final user = jsonDecode(userString);
      final userId = user['id'];
      if (userId == null) return;

      // Connect to Go backend WebSocket room
      final wsUrl = Uri.parse(
        '${ApiService.wsBaseUrl}/ws/chat?orderId=$orderId&userId=$userId',
      );

      _channel = WebSocketChannel.connect(wsUrl);
      _subscription = _channel?.stream.listen((message) {
        try {
          final decoded = jsonDecode(message);
          if (decoded['type'] == 'chat') {
            final chatData = decoded['data'] as Map<String, dynamic>;
            final newMessage = ChatMessageModel.fromJson(chatData);
            
            // Deduplicate if already loaded
            final exists = state.any((m) => m.id == newMessage.id);
            if (!exists) {
              state = [...state, newMessage];
            }
          }
        } catch (err) {
          debugPrint('WS error decoding message: $err');
        }
      }, onError: (err) {
        debugPrint('WS stream error: $err');
      }, onDone: () {
        debugPrint('WS connection closed for room $orderId');
      });
    } catch (e) {
      debugPrint('WS connection error: $e');
    }
  }

  /// Kirim pesan biasa (dari admin atau user)
  Future<void> sendMessage(String text, ChatSender sender) async {
    try {
      // Post message to HTTP API
      await ApiService.post('/api/chats', {
        'orderId': orderId,
        'text': text,
      });
      // Message will be broadcasted to WebSocket and added dynamically via stream listener
    } catch (e) {
      debugPrint('Failed to send chat message: $e');
    }
  }

  /// Kirim system message (detail order otomatis, tampil sebagai info di tengah)
  void sendSystemMessage(String text) {
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
  }

  /// Admin membaca semua pesan user
  void markAllRead() {
    state = state.map((m) => m.copyWith(isRead: true)).toList();
  }

  /// User membaca semua pesan admin
  void markAllUserRead() {
    state = state.map((m) => m.copyWith(isRead: true)).toList();
  }

  /// Reset/hapus semua chat
  Future<void> clearChat() async {
    state = [];
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _channel?.sink.close();
    super.dispose();
  }
}
