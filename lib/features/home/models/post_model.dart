class Post {
  final int id;
  final int user;
  final String caption;
  final String imageUrl;
  final String? audioUrl;
  final int category;
  final DateTime createdAt;
  final String? username;
  final int likesCount;
  final bool isLiked;
  
  Post({
    required this.id,
    required this.user,
    required this.username,
    required this.caption,
    required this.imageUrl,
    this.audioUrl,
    required this.category,
    required this.createdAt,
    this.likesCount = 0,
    this.isLiked = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      user: json['user'] as int,
      username:json['username'] as String? ?? 'Anonymous',
      caption: json['caption'] as String,
      imageUrl: json['image_url'] as String,
      audioUrl: json['audio_url'] as String?,
      category: json['category'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      likesCount: json['likes_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'username': username ?? 'Anonymous',
      'caption': caption,
      'image_url': imageUrl,
      'audio_url': audioUrl,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'likes_count': likesCount,
      'is_liked': isLiked,
    };
  }
}
