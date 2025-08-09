class PostModel {
  final int id;
  final int user;
  final String username;
  final String caption;
  final String imageUrl;
  final String audioUrl;
  final int category;
  final String createdAt;
  final int likesCount;
  final bool isLiked;
  final int commentsCount;

  PostModel({
    required this.id,
    required this.user,
    required this.username,
    required this.caption,
    required this.imageUrl,
    required this.audioUrl,
    required this.category,
    required this.createdAt,
    required this.likesCount,
    required this.isLiked,
    required this.commentsCount,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? 0,
      user: json['user'] ?? 0,
      username: json['username'] ?? '',
      caption: json['caption'] ?? '',
      imageUrl: json['image_url'] ?? '',
      audioUrl: json['audio_url'] ?? '',
      category: json['category'] ?? 0,
      createdAt: json['created_at'] ?? '',
      likesCount: json['likes_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      commentsCount: json['comments_count'] ?? 0,
    );
  }
}
