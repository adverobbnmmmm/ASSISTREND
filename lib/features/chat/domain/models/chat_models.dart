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
      name: json['name'] as String? ?? '',
      profilePicture: json['profile_picture'] as String?,
    );
  }

  /// Convert a Friend instance to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'profile_picture': profilePicture};
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
      name: json['group_name'] as String? ?? '',
    );
  }

  /// Convert a ChatGroup instance to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'group_name': name};
  }
}
