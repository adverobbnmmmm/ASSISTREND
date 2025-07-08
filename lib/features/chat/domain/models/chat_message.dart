// chat_message.dart

class ChatMessage {
  final int id;
  final int senderId;
  final int? receiverId; // nullable for group chats
  final int? groupId;    // nullable for friend chats
  final String content;
  final DateTime timestamp;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.senderId,
    this.receiverId,
    this.groupId,
    required this.content,
    required this.timestamp,
    required this.isMe,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, int currentUserId) {
    return ChatMessage(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch,
      senderId: json['sender_id'],
      receiverId: json['receiver_id'], // null for group messages
      groupId: json['group_id'],       // null for friend messages
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      isMe: json['sender_id'] == currentUserId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sender_id': senderId,
        if (receiverId != null) 'receiver_id': receiverId,
        if (groupId != null) 'group_id': groupId,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };
}
