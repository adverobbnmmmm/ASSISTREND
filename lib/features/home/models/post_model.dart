class Post {
  final int id;
  final int user;
  final String caption;
  final String imageUrl;
  final int category;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.user,
    required this.caption,
    required this.imageUrl,
    required this.category,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      user: json['user'] as int,
      caption: json['caption'] as String,
      imageUrl: json['image_url'] as String,
      category: json['category'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'caption': caption,
      'image_url': imageUrl,
      'category': category,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
