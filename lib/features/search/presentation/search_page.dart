import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assistrend/features/home/main/debouncer.dart';
import 'package:assistrend/features/search/providers/search_providers.dart';
import 'package:assistrend/features/search/models/search_result_model.dart';
import 'package:assistrend/features/search/presentation/search_result_item.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 500);
  late TabController _tabController;
  final List<String> _tabs = ['All', 'Profiles', 'Posts'];
  int _selectedTabIndex = 0;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    _debouncer.run(() {
      setState(() {
        _isSearching = query.isNotEmpty;
      });
      ref.read(searchQueryProvider.notifier).state = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: _buildSearchField(),
        elevation: 0,
        bottom: _isSearching 
            ? TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.blue,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
              )
            : null,
      ),
      body: _isSearching 
          ? _buildSearchResults() 
          : _buildPopularContent(),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearch,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search for people, posts, tags...',
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
          suffixIcon: _searchController.text.isNotEmpty 
              ? IconButton(
                  icon: Icon(Icons.close, color: Colors.grey[500], size: 18),
                  onPressed: () {
                    _searchController.clear();
                    _onSearch('');
                  },
                ) 
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        ),
      ),
    );
  }

  Widget _buildPopularContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            'Popular',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              _buildFilterChip('All', 0),
              _buildFilterChip('Profiles', 1),
              _buildFilterChip('Posts', 2),
            ],
          ),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'Start typing to search...',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = index == _selectedTabIndex;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _selectedTabIndex = index;
            if (_isSearching) {
              _tabController.animateTo(index);
            }
          });
        },
        backgroundColor: Colors.grey[800],
        selectedColor: Colors.blue,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final searchQuery = ref.watch(searchQueryProvider);
    if (_selectedTabIndex == 1) {
      // Profiles
      final usersAsyncValue = ref.watch(searchResultsProvider('profile:' + searchQuery));
      return _buildResultsListFromProvider(usersAsyncValue, 'profile');
    } else if (_selectedTabIndex == 2) {
      // Posts
      final postsAsyncValue = ref.watch(searchResultsProvider('post:' + searchQuery));
      return _buildResultsListFromProvider(postsAsyncValue, 'photo');
    } else {
      // All
      final allAsyncValue = ref.watch(searchResultsProvider(searchQuery));
      return _buildResultsListFromProvider(allAsyncValue, null);
    }
  }
  
  Widget _buildResultsListFromProvider(AsyncValue<List<SearchResultModel>> asyncResults, String? filterType) {
    return asyncResults.when(
      data: (results) {
        final filteredResults = filterType == null
            ? results
            : results.where((result) => result.type == filterType).toList();
            
        return filteredResults.isEmpty
            ? const Center(child: Text('No results found', style: TextStyle(color: Colors.grey)))
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: filteredResults.length,
                itemBuilder: (context, index) {
                  return _buildResultItem(filteredResults[index]);
                },
              );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text('Error: {error.toString()}', style: const TextStyle(color: Colors.red)),
      ),
    );
  }

  Widget _buildResultItem(SearchResultModel item) {
    return SearchResultItem(
      result: item,
      onTap: () {
        // Handle navigation based on item type
        switch (item.type) {
          case 'profile':
            // Navigate to profile page
            break;
          case 'photo':
          case 'video':
            // Open media viewer
            break;
          case 'text':
          default:
            // Open post details
            break;
        }
      },
    );
  }
}
