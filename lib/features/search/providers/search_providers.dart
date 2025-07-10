import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/search_result_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Provider for search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider for search results
final searchResultsProvider = FutureProvider.family<List<SearchResultModel>, String>((ref, query) async {
  if (query.isEmpty) return [];

  final List<SearchResultModel> results = [];

  // Check for prefix to determine which backend to call
  String actualQuery = query;
  bool onlyUsers = false;
  bool onlyPosts = false;
  if (query.startsWith('profile:')) {
    onlyUsers = true;
    actualQuery = query.substring(8);
  } else if (query.startsWith('post:')) {
    onlyPosts = true;
    actualQuery = query.substring(5);
  }

  if (!onlyPosts) {
    // Search users
    final userRes = await http.get(Uri.parse('http://10.0.2.2:8001/api/social-service/features/search/users/?q=$actualQuery'));
    if (userRes.statusCode == 200) {
      final data = json.decode(userRes.body);
      for (var user in data['results']) {
        results.add(SearchResultModel(
          id: user['id'].toString(),
          type: 'profile',
          title: user['name'] ?? '',
          subtitle: user['email'] ?? '',
          imageUrl: '',
          timestamp: DateTime.now(),
        ));
      }
    }
  }

  if (!onlyUsers) {
    // Search posts
    final postRes = await http.get(Uri.parse('http://10.0.2.2:8001/api/social-service/features/search/posts/?q=$actualQuery'));
    if (postRes.statusCode == 200) {
      final data = json.decode(postRes.body);
      for (var post in data['results']) {
        String type = 'text';
        final imageUrl = (post['image_url'] ?? '').replaceAll('"', '');
        if (imageUrl.isNotEmpty) {
          if (imageUrl.endsWith('.mp4') || imageUrl.endsWith('.mov')) {
            type = 'video';
          } else {
            type = 'photo';
          }
        }
        results.add(SearchResultModel(
          id: post['id'].toString(),
          type: type,
          title: (post['caption'] ?? '').replaceAll('"', ''),
          subtitle: post['user'] != null && post['user']['name'] != null ? post['user']['name'] : '',
          imageUrl: imageUrl,
          timestamp: DateTime.tryParse(post['created_at'] ?? '') ?? DateTime.now(),
        ));
      }
    }
  }

  return results;
});

// Provider for filtered results by type
final filteredResultsProvider = Provider.family<List<SearchResultModel>, String>((ref, type) {
  final results = ref.watch(searchResultsProvider(ref.watch(searchQueryProvider)));

  return results.when(
    data: (data) {
      if (type == 'All') return data;
      return data.where((result) => result.type == type.toLowerCase()).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
