import '../network/social_api_service.dart';

class ProfileService {
  static Future<bool> isProfileComplete(int userId) async {
    try {
      final profileData = await SocialApiService.getProfileData(userId);
      
      // Check if profile has at least interests and about information
      final interests = profileData['interests'] as List<dynamic>?;
      final about = profileData['about'] as String?;
      
      return (interests != null && interests.isNotEmpty) && 
             (about != null && about.trim().isNotEmpty);
    } catch (e) {
      // If we can't fetch profile data, assume it's incomplete
      return false;
    }
  }
}
