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
  final List<String> interests; // Add this field

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
    required this.interests, // Add this parameter
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      emoji: json['emoji'] ?? '',
      about: json['about'] ?? '',
      badges: (json['badges'] as List<dynamic>?)
              ?.map((badge) => Badge.fromJson(badge))
              .toList() ??
          [],
      points: json['points'] ?? 0,
      posts: (json['posts'] as List<dynamic>?)
              ?.map((post) => Post.fromJson(post))
              .toList() ??
          [],
      stories: (json['stories'] as List<dynamic>?)
              ?.map((story) => Story.fromJson(story))
              .toList() ??
          [],
      likedPosts: (json['likedPosts'] as List<dynamic>?)
              ?.map((like) => like['post_id'] as int)
              .toList() ??
          [],
      taggedPosts: (json['taggedPosts'] as List<dynamic>?)
              ?.map((tag) => tag['post_id'] as int)
              .toList() ??
          [],
      socials: (json['socials'] as List<dynamic>?)
              ?.map((social) => SocialLink.fromJson(social))
              .toList() ??
          [],
      interests: (json['interests'] as List<dynamic>?)
              ?.map((interest) => interest['interestId__interestName'] as String)
              .toList() ??
          [],
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
      interests: [], // Add this
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

  Post({
    required this.id,
    required this.caption,
    required this.imageUrl,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? 0,
      caption: json['caption'] ?? '',
      imageUrl: json['image_url'] ?? '',
      createdAt: json['created_at'] ?? '',
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