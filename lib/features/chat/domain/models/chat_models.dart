/// Data model representing a friend in the chat list.
class Friend {
  final int id;
  final String username;

  Friend({required this.id, required this.username});

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] as int,
      username: json['username'] as String? ?? '',
    );
  }
}

/// Data model representing a group in the chat list.
class ChatGroup {
  final int id;
  final String name;

  ChatGroup({required this.id, required this.name});

  factory ChatGroup.fromJson(Map<String, dynamic> json) {
    return ChatGroup(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
    );
  }
}
