/// Data model representing a friend in the chat list.
class Friend {
  final int id;
  final String name;
  final String? profilePicture;

  Friend({required this.id, required this.name, this.profilePicture});

  /// Factory constructor to create a Friend instance from JSON data.
  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] as int,
      // If name is null, fallback to empty string
      name: json['name'] as String? ?? '',
      profilePicture: json['profile_picture'] as String?,
    );
  }
}

/// Data model representing a group in the chat list.
class ChatGroup {
  final int id;
  final String name;

  ChatGroup({required this.id, required this.name});

  /// Factory constructor to create a ChatGroup instance from JSON data.
  factory ChatGroup.fromJson(Map<String, dynamic> json) {
    return ChatGroup(
      id: json['id'] as int,
      // Use group_name field and fallback to empty string if null
      name: json['group_name'] as String? ?? '',
    );
  }
}


