import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:assistrend/core/network/api_service.dart';
import '../../profile/providers/profile_setup_provider.dart';
import '../../profile/models/profile_setup_model.dart';

class ApplyChampionPage extends ConsumerStatefulWidget {
  const ApplyChampionPage({super.key});

  @override
  ConsumerState<ApplyChampionPage> createState() => _ApplyChampionPageState();
}

class _ApplyChampionPageState extends ConsumerState<ApplyChampionPage> {
  final List<int> _selectedInterestIds = [];
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileSetupProvider.notifier).loadInterests();
    });
  }

  Future<void> _submitApplication() async {
    if (_selectedInterestIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one specialized domain interest.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      await ApiService.applyForChampion(_selectedInterestIds);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Community Champion application submitted!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Failed to submit application: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final setupState = ref.watch(profileSetupProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF12161C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        title: const Text(
          'Become a Community Champion',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Premium Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1D5EFF), Color(0xFF0A3AFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1D5EFF).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shield_outlined, color: Colors.white, size: 28),
                        SizedBox(width: 8),
                        Text(
                          'Volunteer Status',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Community Champions support community members who share similar specialized domains. Select the interests you specialize in. Once approved by our team, you\'ll gain access to the Champion Dashboard.',
                      style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.45),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Select Specialized Domains',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Under these domains, you will match and connect with community members.',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 20),

              if (setupState.interests.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: CircularProgressIndicator(color: Color(0xFF1D5EFF)),
                  ),
                )
              else
                _buildInterestsGrid(setupState.interests),

              const SizedBox(height: 32),

              if (_statusMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _statusMessage,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                  ),
                ),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D5EFF),
                    disabledBackgroundColor: const Color(0xFF1D5EFF).withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Submit Application',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInterestsGrid(List<InterestCategory> categories) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final selectedCount = category.subcategories
            .where((sub) => _selectedInterestIds.contains(sub.id))
            .length;

        return _buildCategoryCard(category, selectedCount);
      },
    );
  }

  Widget _buildCategoryCard(InterestCategory category, int selectedCount) {
    Gradient cardGradient = const LinearGradient(
      colors: [Color(0xFF282F3B), Color(0xFF1E232B)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    IconData categoryIcon = Icons.interests_outlined;

    if (category.name.toLowerCase().contains('sport')) {
      categoryIcon = Icons.sports_soccer;
    } else if (category.name.toLowerCase().contains('music')) {
      categoryIcon = Icons.music_note;
    } else if (category.name.toLowerCase().contains('show') || category.name.toLowerCase().contains('movie')) {
      categoryIcon = Icons.movie;
    } else if (category.name.toLowerCase().contains('tech') || category.name.toLowerCase().contains('code')) {
      categoryIcon = Icons.computer;
    } else if (category.name.toLowerCase().contains('travel') || category.name.toLowerCase().contains('hike')) {
      categoryIcon = Icons.flight;
    }

    final hasSelection = selectedCount > 0;

    return GestureDetector(
      onTap: () => _showSubcategoriesSheet(category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: cardGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasSelection ? const Color(0xFF1D5EFF) : Colors.white12,
            width: hasSelection ? 2 : 1,
          ),
          boxShadow: [
            if (hasSelection)
              BoxShadow(
                color: const Color(0xFF1D5EFF).withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                categoryIcon,
                size: 64,
                color: hasSelection ? const Color(0xFF1D5EFF).withOpacity(0.15) : Colors.white.withOpacity(0.04),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasSelection
                        ? const Color(0xFF1D5EFF).withOpacity(0.2)
                        : Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    hasSelection ? '$selectedCount selected' : 'Explore',
                    style: TextStyle(
                      color: hasSelection ? const Color(0xFF5E8BFF) : Colors.white38,
                      fontSize: 11,
                      fontWeight: hasSelection ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSubcategoriesSheet(InterestCategory category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161B22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    category.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose your domains of specialized knowledge',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: category.subcategories.map((sub) {
                          final isSelected = _selectedInterestIds.contains(sub.id);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedInterestIds.remove(sub.id);
                                } else {
                                  _selectedInterestIds.add(sub.id);
                                }
                              });
                              setModalState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF1D5EFF).withOpacity(0.15)
                                    : const Color(0xFF21262D),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF1D5EFF) : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSelected) ...[
                                    const Icon(
                                      Icons.check,
                                      color: Color(0xFF1D5EFF),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Text(
                                    sub.name,
                                    style: TextStyle(
                                      color: isSelected ? const Color(0xFF5E8BFF) : Colors.white,
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D5EFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
