class ChatMessage {
  final int id;
  final int senderId;
  final int? receiverId; // nullable for group chats
  final int? groupId; // nullable for friend chats
  final String content;
  final DateTime timestamp;
  final bool isMe;
  final String? imageUrl;
  bool read; // ✅ NEW: track if message has been read

  ChatMessage({
    required this.id,
    required this.senderId,
    this.receiverId,
    this.groupId,
    required this.content,
    required this.timestamp,
    required this.isMe,
    this.imageUrl,
    this.read = false, // ✅ Default to false
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, int currentUserId) {
    return ChatMessage(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch,
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      groupId: json['group_id'],
      content: json['content'] ?? json['message'] ?? '', // ✅ Safe fallback
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      isMe: json['sender_id'] == currentUserId,
      imageUrl: json['image'],
      read: json['read'] ?? false, // ✅ Defaults to false if missing
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sender_id': senderId,
    if (receiverId != null) 'receiver_id': receiverId,
    if (groupId != null) 'group_id': groupId,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    if (imageUrl != null) 'image': imageUrl,
    'read': read, // ✅ Include read status
  };
}
