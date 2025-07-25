import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dashboard.dart';

// Models
class User {
  final String id;
  final String fullName;
  final String bio;
  final String location;
  final String profilePicture;
  final List<String> socialLinks;
  final List<Post> reportedPosts;
  final Map<String, dynamic> engagementSummary;
  final Connection connection;
  final Gamification gamification;
  final AdditionalProfile additionalProfile;

  User({
    required this.id,
    required this.fullName,
    required this.bio,
    required this.location,
    required this.profilePicture,
    required this.socialLinks,
    required this.reportedPosts,
    required this.engagementSummary,
    required this.connection,
    required this.gamification,
    required this.additionalProfile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['full_name'],
      bio: json['bio'],
      location: json['location'],
      profilePicture: json['profile_picture'],
      socialLinks: List<String>.from(json['social_links']),
      reportedPosts: (json['reported_posts'] as List)
          .map((post) => Post.fromJson(post))
          .toList(),
      engagementSummary: json['engagement_summary'],
      connection: Connection.fromJson(json['connection']),
      gamification: Gamification.fromJson(json['gamification']),
      additionalProfile: AdditionalProfile.fromJson(json['additional_profile']),
    );
  }
}

class Post {
  final String id;
  final String content;
  final String timestamp;

  Post({required this.id, required this.content, required this.timestamp});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      content: json['content'],
      timestamp: json['timestamp'],
    );
  }
}

class Connection {
  final String summary;
  final bool isAnonymous;
  final String initiationTimestamp;
  final String respondTimestamp;
  final String feedback;

  Connection({
    required this.summary,
    required this.isAnonymous,
    required this.initiationTimestamp,
    required this.respondTimestamp,
    required this.feedback,
  });

  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      summary: json['summary'],
      isAnonymous: json['is_anonymous'],
      initiationTimestamp: json['initiation_timestamp'],
      respondTimestamp: json['respond_timestamp'],
      feedback: json['feedback'],
    );
  }
}

class Gamification {
  final String taskStatus;
  final List<QA> answers;

  Gamification({required this.taskStatus, required this.answers});

  factory Gamification.fromJson(Map<String, dynamic> json) {
    return Gamification(
      taskStatus: json['task_status'],
      answers: (json['answers'] as List).map((qa) => QA.fromJson(qa)).toList(),
    );
  }
}

class QA {
  final String question;
  final String answer;

  QA({required this.question, required this.answer});

  factory QA.fromJson(Map<String, dynamic> json) {
    return QA(question: json['question'], answer: json['answer']);
  }
}

class AdditionalProfile {
  final String nickname;
  final String audioSummary;
  final String highlightData;

  AdditionalProfile({
    required this.nickname,
    required this.audioSummary,
    required this.highlightData,
  });

  factory AdditionalProfile.fromJson(Map<String, dynamic> json) {
    return AdditionalProfile(
      nickname: json['nickname'],
      audioSummary: json['audio_summary'],
      highlightData: json['highlight_data'],
    );
  }
}

// Data Provider
class UserProvider with ChangeNotifier {
  List<User> _users = [];
  bool _isLoading = false;
  int _page = 1;
  final int _pageSize = 10;
  String _searchQuery = '';
  String _sortField = 'full_name';
  bool _sortAscending = true;
  Map<String, dynamic> _filters = {};

  List<User> get users => _users;
  bool get isLoading => _isLoading;

  Future<void> fetchUsers({bool loadMore = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      if (!loadMore) {
        _page = 1;
        _users.clear();
      }

      final response = await http.get(
        Uri.parse(
          'https://your-django-api.com/users?page=$_page&size=$_pageSize&search=$_searchQuery&sort=$_sortField&asc=$_sortAscending',
        ),
        headers: {
          'Authorization': 'Bearer your_secure_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        _users.addAll(data.map((json) => User.fromJson(json)).toList());
        _page++;
      }
    } catch (e) {
      print('Error fetching users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchUsers();
  }

  void setSort(String field, bool ascending) {
    _sortField = field;
    _sortAscending = ascending;
    fetchUsers();
  }

  void setFilters(Map<String, dynamic> filters) {
    _filters = filters;
    fetchUsers();
  }
}

// Main App
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: const AdminPanelApp(),
    ),
  );
}

class AdminPanelApp extends StatelessWidget {
  const AdminPanelApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Panel',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E4EF6)),
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const DashboardScreen(),
    );
  }
}
