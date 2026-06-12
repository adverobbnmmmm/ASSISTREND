import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/utils/storage.dart';
import '../models/profile_setup_model.dart';

class ProfileSetupNotifier extends StateNotifier<ProfileSetupState> {
  ProfileSetupNotifier() : super(ProfileSetupState());

  Future<void> setupProfile(String userId, ProfileSetupModel profileData) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final response = await ApiService.setupProfile(userId, profileData);
      
      if (response['status'] == 'success') {
        await Storage.saveProfileComplete(true);
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response['message'] ?? 'Profile setup failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadInterests() async {
    try {
      final response = await ApiService.getInterests();
      
      if (response['status'] == 'success') {
        final rawInterests = (response['interests'] as List?) ?? [];
        final interests = rawInterests
            .map((json) => InterestCategory.fromJson(json))
            .toList();
        
        state = state.copyWith(interests: interests);
      }
    } catch (e) {
      // Handle error silently or log it
      print('Error loading interests: $e');
    }
  }

  Future<bool> checkProfileExists(String userId) async {
    try {
      final response = await ApiService.checkProfileExists(userId);
      return response['profileExists'] ?? false;
    } catch (e) {
      print('Error checking profile existence: $e');
      return false;
    }
  }
}

final profileSetupProvider = StateNotifierProvider<ProfileSetupNotifier, ProfileSetupState>((ref) {
  return ProfileSetupNotifier();
});
