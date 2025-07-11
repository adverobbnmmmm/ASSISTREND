import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_state.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/utils/storage.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _initializeAuthState();
  }

  Future<void> _initializeAuthState() async {
    try {
      final accessToken = await Storage.getToken();
      final refreshToken = await Storage.getRefreshToken();
      final userId = await Storage.getUserId();

      print('Auth init - Token: ${accessToken != null ? 'present' : 'null'}, UserId: $userId');

      if (accessToken != null && userId != null) {
        state = AuthState.authenticated(
          accessToken: accessToken,
          refreshToken: refreshToken ?? '',
          userId: userId,
        );
      } else {
        state = AuthState.unauthenticated();
      }
    } catch (e) {
      print('Auth initialization error: $e');
      state = AuthState.unauthenticated();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.authenticating);

      final response = await ApiService.login(email, password);
      final accessToken = response['access'];
      final refreshToken = response['refresh'];
      final userId = response['userId'];

      // Store tokens and user ID
      await Storage.saveToken(accessToken);
      await Storage.saveRefreshToken(refreshToken);
      await Storage.saveUserId(userId);

      // Update state
      state = AuthState.authenticated(
        accessToken: accessToken,
        refreshToken: refreshToken,
        userId: userId,
      );
    } catch (e) {
      state = AuthState.error('Login failed: $e');
    }
  }

  Future<void> register(String name, String email, String phone, String password, bool privacyPolicyAccepted) async {
    try {
      state = state.copyWith(status: AuthStatus.registering);

      await ApiService.register(name, email, phone, password, privacyPolicyAccepted);

      // After registration, the user still needs to verify OTP, so we stay unauthenticated
      state = AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error('Registration failed: $e');
    }
  }  Future<void> verifyOTP(String email, String otp) async {
    try {
      state = state.copyWith(status: AuthStatus.authenticating);

      await ApiService.verifyOTP(email, otp);

      // Typically the OTP verification would return tokens, but if not,
      // the user would need to login separately
      state = AuthState.unauthenticated();
      
    } catch (e) {
      state = AuthState.error('OTP verification failed: $e');
    }
  }

  Future<void> logout() async {
    print('Auth provider logout started');
    
    try {
      final refreshToken = await Storage.getRefreshToken();
      if (refreshToken != null) {
        try {
          print('Calling logout API with refresh token');
          await ApiService.logout(refreshToken);
          print('Logout API call successful');
        } catch (e) {
          // Continue with local logout even if API call fails
          print('Logout API error (continuing with local logout): $e');
        }
      }
    } catch (e) {
      print('Error getting refresh token: $e');
    }

    // Always clear tokens locally regardless of API call success
    try {
      print('Clearing all tokens');
      await Storage.clearAllTokens();
      print('Tokens cleared successfully');
    } catch (e) {
      print('Error clearing tokens: $e');
    }

    // Always update state to unauthenticated
    print('Updating state to unauthenticated');
    state = AuthState.unauthenticated();
    
    print('Auth provider logout completed');
  }

  Future<void> loginWithGoogle(String accessToken, String refreshToken, int userId) async {
    try {
      state = state.copyWith(status: AuthStatus.authenticating);

      // Store tokens and user ID
      await Storage.saveToken(accessToken);
      await Storage.saveRefreshToken(refreshToken);
      await Storage.saveUserId(userId);

      // Update state
      state = AuthState.authenticated(
        accessToken: accessToken,
        refreshToken: refreshToken,
        userId: userId,
      );
    } catch (e) {
      state = AuthState.error('Google login failed: $e');
    }
  }
}

// Provider for auth state
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Convenience providers for auth status
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).errorMessage;
});