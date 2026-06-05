/// Data models for the messaging feature.

class ChatUser {
  final String id; // UUID
  final String username;
  final String email;
  final String profileImageUrl;

  ChatUser({
    required this.id,
    required this.username,
    this.email = '',
    this.profileImageUrl = '',
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
    );
  }
}

class ChatMessage {
  final int id;
  final int conversationId;
  final String senderId; // UUID
  final String senderName;
  final String text;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? 0,
      conversationId: json['conversationId'] ?? 0,
      senderId: json['senderId']?.toString() ?? '',
      senderName: json['senderName'] ?? '',
      text: json['text'] ?? '',
      createdAt:
          DateTime.tryParse(json['created_at'] ?? '')?.toLocal() ?? DateTime.now(),
    );
  }
}

class Conversation {
  final int id;
  final bool isGroup;
  final String title; // other user's name (direct) or group name
  final String name; // group name (empty for direct)
  final String avatar;
  final List<ChatUser> members;
  final ChatMessage? lastMessage;
  final DateTime updatedAt;

  Conversation({
    required this.id,
    required this.isGroup,
    required this.title,
    required this.name,
    required this.avatar,
    required this.members,
    required this.lastMessage,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? 0,
      isGroup: json['is_group'] ?? false,
      title: json['title'] ?? 'Chat',
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
      members: (json['members'] as List<dynamic>?)
              ?.map((m) => ChatUser.fromJson(m))
              .toList() ??
          [],
      lastMessage: json['last_message'] != null
          ? ChatMessage.fromJson(json['last_message'])
          : null,
      updatedAt:
          DateTime.tryParse(json['updated_at'] ?? '')?.toLocal() ?? DateTime.now(),
    );
  }
}
