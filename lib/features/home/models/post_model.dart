class Post {
  final int id;
  final String user; // author UUID (string) from the backend
  final String caption;
  final String imageUrl;
  final String? audioUrl;
  final int category;
  final DateTime createdAt;
  final String? username;
  final int likesCount;
  final bool isLiked;
  final int commentsCount;
  final String? posterProfileImageUrl;
  
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
    this.commentsCount = 0,
    this.posterProfileImageUrl,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      user: json['user']?.toString() ?? '',
      username:json['username'] as String? ?? 'Anonymous',
      caption: json['caption'] as String,
      imageUrl: json['image_url'] as String,
      audioUrl: json['audio_url'] as String?,
      category: json['category'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      likesCount: json['likes_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      commentsCount: json['comments_count'] as int? ?? 0,
      posterProfileImageUrl: json['posterProfileImageUrl'] as String?,
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
      'comments_count': commentsCount,
      'posterProfileImageUrl': posterProfileImageUrl,
    };
  }

  Post copyWith({
    int? id,
    String? user,
    String? username,
    String? caption,
    String? imageUrl,
    String? audioUrl,
    int? category,
    DateTime? createdAt,
    int? likesCount,
    bool? isLiked,
    int? commentsCount,
  }) {
    return Post(
      id: id ?? this.id,
      user: user ?? this.user,
      username: username ?? this.username,
      caption: caption ?? this.caption,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      commentsCount: commentsCount ?? this.commentsCount,
    );
  }
}
