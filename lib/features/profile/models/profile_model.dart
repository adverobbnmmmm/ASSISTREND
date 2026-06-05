import 'package:flutter/material.dart';

class ProfileModel {
  final String name;
  final String username;
  final String emoji;
  final String about;
  final List<Badge> badges;
  final int points;
  final List<Post> posts;
  final List<Story> stories;
  final List<int> likedPosts;
  final List<int> taggedPosts;
  final List<SocialLink> socials;
  final List<String> interests;
  final String? audioUrl; // Add profile audio URL
  final String? profileImageUrl; // Add profile image URL

  ProfileModel({
    required this.name,
    required this.username,
    required this.emoji,
    required this.about,
    required this.badges,
    required this.points,
    required this.posts,
    required this.stories,
    required this.likedPosts,
    required this.taggedPosts,
    required this.socials,
    required this.interests,
    this.audioUrl, // Add this parameter
    this.profileImageUrl, // Add this parameter
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // Check if wrapped in data object
    final data = json['data'] ?? json;
    
    return ProfileModel(
      name: data['display_name'] ?? data['name'] ?? '',
      username: data['username'] ?? '',
      emoji: data['emoji'] ?? '',
      about: data['bio'] ?? data['about'] ?? '',
      badges: (data['badges'] as List<dynamic>?)
              ?.map((badge) => Badge.fromJson(badge))
              .toList() ??
          [],
      points: data['points'] ?? 0,
      posts: (data['posts'] as List<dynamic>?)
              ?.map((post) => Post.fromJson(post))
              .toList() ??
          [],
      stories: (data['stories'] as List<dynamic>?)
              ?.map((story) => Story.fromJson(story))
              .toList() ??
          [],
      likedPosts: (data['likedPosts'] as List<dynamic>?)
              ?.map((like) => like['post_id'] as int)
              .toList() ??
          [],
      taggedPosts: (data['taggedPosts'] as List<dynamic>?)
              ?.map((tag) => tag['post_id'] as int)
              .toList() ??
          [],
      socials: (data['socials'] as List<dynamic>?)
              ?.map((social) => SocialLink.fromJson(social))
              .toList() ??
          [],
      interests: (data['interests'] as List<dynamic>?)
              ?.map((interest) => interest['interestId__interestName'] as String)
              .toList() ??
          [],
      audioUrl: data['audio_intro_url'] ?? data['audioUrl'], // Add audio URL parsing
      profileImageUrl: data['profile_picture_url'] ?? data['profileImageUrl'], // Add profile image URL parsing
    );
  }

  // Empty profile for initial state
  factory ProfileModel.empty() {
    return ProfileModel(
      name: '',
      username: '',
      emoji: '',
      about: '',
      badges: [],
      points: 0,
      posts: [],
      stories: [],
      likedPosts: [],
      taggedPosts: [],
      socials: [],
      interests: [],
      audioUrl: null, // Add this
      profileImageUrl: null, // Add this
    );
  }
}

class Badge {
  final String name;
  final String image;

  Badge({
    required this.name,
    required this.image,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      name: json['badge__name'] ?? '',
      image: json['badge__image'] ?? '',
    );
  }
}

class Post {
  final int id;
  final String caption;
  final String imageUrl;
  final String createdAt;
  final int category;
  final int likesCount;
  final int commentsCount;

  Post({
    required this.id,
    required this.caption,
    required this.imageUrl,
    required this.createdAt,
    this.category = 0,
    this.likesCount = 0,
    this.commentsCount = 0,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? 0,
      caption: json['caption'] ?? '',
      imageUrl: json['image_url'] ?? '',
      createdAt: json['created_at'] ?? '',
      category: json['category'] ?? 0,
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
    );
  }
}

class Story {
  final int id;
  final String content;
  final String createdAt;

  Story({
    required this.id,
    required this.content,
    required this.createdAt,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}

class SocialLink {
  final String platform;
  final String url;

  SocialLink({
    required this.platform,
    required this.url,
  });

  factory SocialLink.fromJson(Map<String, dynamic> json) {
    return SocialLink(
      platform: json['platform'] ?? '',
      url: json['url'] ?? '',
    );
  }

  // Convert platform to icon data
  IconData get icon {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return Icons.facebook;
      case 'twitter':
        // Use a different icon since twitter is not available
        return Icons.chat;
      case 'instagram':
        return Icons.camera_alt;
      case 'linkedin':
        // Use a different icon since linkedin is not available
        return Icons.business;
      case 'github':
        return Icons.code;
      case 'youtube':
        return Icons.video_library;
      default:
        return Icons.link;
    }
  }

  // Get the color for the social media icon
  Color get color {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return Colors.blue;
      case 'twitter':
        return Colors.lightBlue;
      case 'instagram':
        return Colors.purple;
      case 'linkedin':
        return Colors.blue.shade800;
      case 'github':
        return Colors.white;
      case 'youtube':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}