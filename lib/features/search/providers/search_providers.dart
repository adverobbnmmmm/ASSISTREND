import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/search_result_model.dart';

// Provider for search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider for search results
final searchResultsProvider = FutureProvider.family<List<SearchResultModel>, String>((ref, query) async {
  // This is a placeholder for actual API call
  // In a real app, you would make an API call to your backend service
  
  // Simulating a network delay
  await Future.delayed(const Duration(milliseconds: 500));
  
  // Placeholder for search results
  List<Map<String, dynamic>> dummyData = [
    {
      'id': '1',
      'type': 'profile',
      'title': 'Pranav',
      'subtitle': '1h ago',
      'image_url': 'https://randomuser.me/api/portraits/men/1.jpg',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
    },
    {
      'id': '2',
      'type': 'profile',
      'title': 'Rahul',
      'subtitle': '1h ago',
      'image_url': 'https://randomuser.me/api/portraits/men/2.jpg',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
    },
    {
      'id': '3',
      'type': 'photo',
      'title': 'Amazing Sunset',
      'subtitle': 'Shared by Alex',
      'image_url': 'https://picsum.photos/id/237/200/300',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    },
    {
      'id': '4',
      'type': 'video',
      'title': 'Flutter Tutorial',
      'subtitle': 'Learn Flutter in 10 minutes',
      'image_url': 'https://picsum.photos/id/1/200/300',
      'timestamp': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
    },
    {
      'id': '5',
      'type': 'text',
      'title': 'Important Announcement',
      'subtitle': 'Read about our latest updates',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
  ];
  
  // Filter based on query
  if (query.isNotEmpty) {
    dummyData = dummyData
        .where((item) => 
            item['title'].toString().toLowerCase().contains(query.toLowerCase()) ||
            (item['subtitle'] != null && item['subtitle'].toString().toLowerCase().contains(query.toLowerCase())))
        .toList();
  }
  
  // Convert to models
  return dummyData.map((item) => SearchResultModel.fromJson(item)).toList();
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
