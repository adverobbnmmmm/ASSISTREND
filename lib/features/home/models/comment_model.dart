class Comment {
  final int id;
  final String userId; // commenter UUID (string) from the backend
  final String comment;
  final DateTime createdAt;
  final String? username;

  Comment({
    required this.id,
    required this.userId,
    required this.comment,
    required this.createdAt,
    this.username,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      userId: json['user_id']?.toString() ?? '',
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      username: json['username'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'username': username,
    };
  }
}
