class ChatMessageModel {
  final String id;
  final String orderId;
  final String text;
  final ChatSender sender;
  final DateTime createdAt;
  final bool isRead;
  final bool isSystem;

  ChatMessageModel({
    required this.id,
    required this.orderId,
    required this.text,
    required this.sender,
    required this.createdAt,
    this.isRead = false,
    this.isSystem = false
  });

  ChatMessageModel copyWith({bool? isRead}) => ChatMessageModel(
        id: id,
        orderId: orderId,
        text: text,
        sender: sender,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
        isSystem: isSystem,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderId': orderId,
        'text': text,
        'sender': sender.name, // 'admin' | 'user'
        'createdAt': createdAt.toIso8601String(),
        'isRead': isRead,
        'isSystem': isSystem,

      };

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        id: json['id'] as String,
        orderId: json['orderId'] as String,
        text: json['text'] as String,
        sender: ChatSender.values.byName(json['sender'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        isRead: json['isRead'] as bool? ?? false,
        isSystem: json['isSystem'] as bool? ?? false,
      );
}

enum ChatSender { admin, user }