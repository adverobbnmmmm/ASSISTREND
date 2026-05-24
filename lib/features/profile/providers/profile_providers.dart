import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/profile_model.dart';
import '../../../shared/utils/storage.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/network/social_api_service.dart'; // Updated import
import '../../../config/app_config.dart';

// State for profile loading
enum ProfileStatus { initial, loading, loaded, error }

class ProfileState {
  final ProfileStatus status;
  final ProfileModel profile;
  final String? errorMessage;

  ProfileState({
    this.status = ProfileStatus.initial,
    required this.profile,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileModel? profile,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(ProfileState(profile: ProfileModel.empty()));

  Future<void> fetchProfile(String userId) async {
    try {
      state = state.copyWith(status: ProfileStatus.loading);

      // Use the SocialApiService instead of direct HTTP request
      final data = await SocialApiService.getProfileData(userId);
      final profile = ProfileModel.fromJson(data);
      
      state = state.copyWith(
        status: ProfileStatus.loaded,
        profile: profile,
      );
    } catch (e) {
      state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
  
  // Add method to update profile
  Future<void> updateProfile(String userId, {
    String? name,
    String? about,
    String? emoji,
  }) async {
    try {
      final updateData = {
        if (name != null) 'name': name,
        if (about != null) 'about': about, 
        if (emoji != null) 'emoji': emoji,
      };
      
      await SocialApiService.updateProfile(userId, updateData);
      
      // Refresh profile data after update
      await fetchProfile(userId);
    } catch (e) {
      state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'Failed to update profile: $e',
      );
    }
  }
}

// Provider for profile state
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});

// Provider for current user's profile
final currentUserProfileProvider = FutureProvider<ProfileModel>((ref) async {
  final authState = ref.watch(authProvider);
  final userId = authState.userId;

  if (userId == null) {
    throw Exception('User not authenticated');
  }

  // Initialize profile loading
  final profileNotifier = ref.read(profileProvider.notifier);
  await profileNotifier.fetchProfile(userId);

  // Return the profile from the state
  return ref.read(profileProvider).profile;
});

// Helper provider for selected tab
final selectedTabIndexProvider = StateProvider<int>((ref) => 0);

// Update the _buildProfileHeader method to include an edit button
Widget _buildProfileHeader(ProfileModel profile) {
  return Padding(
    padding: EdgeInsets.all(16.0),
    child: Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(
                "https://ui-avatars.com/api/?name=${profile.name}&background=random"
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Text(
                    "@${profile.username}",
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  Row(
                    children: [
                      Text(
                        "${profile.points} points",
                        style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      if (profile.emoji.isNotEmpty)
                        Text(
                          profile.emoji,
                          style: TextStyle(fontSize: 16),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                //_showEditProfileDialog();
              },
              tooltip: 'Edit Profile',
            ),
          ],
        ),
      ],
    ),
  );
}
