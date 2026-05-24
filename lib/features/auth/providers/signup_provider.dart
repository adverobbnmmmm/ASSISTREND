import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/signup_state.dart';
import '../../../core/network/api_service.dart';
import 'package:uuid/uuid.dart';

// Custom exception for session expiry
class SessionExpiredException implements Exception {
  final String message;
  SessionExpiredException(this.message);

  @override
  String toString() => message;
}

class SignupNotifier extends StateNotifier<SignupState> {
  SignupNotifier() : super(const SignupState()) {
    // Generate a session ID on initialization
    final sessionId = const Uuid().v4();
    state = state.copyWith(sessionId: sessionId);
  }

  Future<void> updateEmail(String email) async {
    state = state.copyWith(email: email);
  }

  Future<void> updateUsername(String username) async {
    state = state.copyWith(username: username);
  }

  Future<void> updatePassword(String password) async {
    state = state.copyWith(password: password);
  }

  Future<void> updateConfirmPassword(String confirmPassword) async {
    state = state.copyWith(confirmPassword: confirmPassword);
  }

  Future<void> updateGender(String gender) async {
    state = state.copyWith(gender: gender);
  }

  Future<void> updateDateOfBirth(String dateOfBirth) async {
    state = state.copyWith(dateOfBirth: dateOfBirth);
  }

  Future<void> updatePhoneNumber(String phoneNumber) async {
    state = state.copyWith(phoneNumber: phoneNumber);
  }

  Future<void> updatePrivacyPolicyAccepted(bool accepted) async {
    state = state.copyWith(privacyPolicyAccepted: accepted);
  }

  Future<void> submitStep1() async {
    try {
      state = state.copyWith(isLoading: true, status: SignupStatus.loading);

      final response = await ApiService.signupStep1(
        state.email,
        state.username,
        sessionId: state.sessionId,
      );

      if (response['success'] == true) {
        state = state.copyWith(
          isLoading: false,
          status: SignupStatus.step1Complete,
        );
      } else {
        throw Exception(response['errors']?.toString() ?? 'Step 1 failed');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        status: SignupStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> submitStep2() async {
    try {
      state = state.copyWith(isLoading: true, status: SignupStatus.loading);

      final response = await ApiService.signupStep2(
        state.password,
        state.confirmPassword,
        sessionId: state.sessionId,
      );

      if (response['success'] == true) {
        state = state.copyWith(
          isLoading: false,
          status: SignupStatus.step2Complete,
        );
      } else {
        // Check if session expired
        if (response['error']?.toString().contains('step 1') ?? false) {
          throw SessionExpiredException(
            'Your session expired. Please start from step 1 again.'
          );
        }
        throw Exception(response['errors']?.toString() ?? 'Step 2 failed');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        status: SignupStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> submitStep3() async {
    try {
      state = state.copyWith(isLoading: true, status: SignupStatus.loading);

      final response = await ApiService.signupStep3(
        state.gender,
        state.dateOfBirth,
        sessionId: state.sessionId,
      );

      if (response['success'] == true) {
        state = state.copyWith(
          isLoading: false,
          status: SignupStatus.step3Complete,
        );
      } else {
        throw Exception(response['errors']?.toString() ?? 'Step 3 failed');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        status: SignupStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> submitStep4() async {
    try {
      state = state.copyWith(isLoading: true, status: SignupStatus.loading);

      final response = await ApiService.signupStep4(
        state.phoneNumber,
        sessionId: state.sessionId,
      );

      if (response['success'] == true) {
        state = state.copyWith(
          isLoading: false,
          status: SignupStatus.step4Complete,
        );
      } else {
        throw Exception(response['errors']?.toString() ?? 'Step 4 failed');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        status: SignupStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> submitStep5() async {
    try {
      state = state.copyWith(isLoading: true, status: SignupStatus.loading);

      final response = await ApiService.signupStep5(
        state.privacyPolicyAccepted,
        sessionId: state.sessionId,
      );

      if (response['success'] == true) {
        state = state.copyWith(
          isLoading: false,
          status: SignupStatus.step5Complete,
        );
      } else {
        throw Exception(response['errors']?.toString() ?? 'Step 5 failed');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        status: SignupStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> completeSignup() async {
    try {
      state = state.copyWith(isLoading: true, status: SignupStatus.loading);

      final response = await ApiService.signupComplete(sessionId: state.sessionId);

      if (response['success'] == true) {
        state = state.copyWith(
          isLoading: false,
          status: SignupStatus.completed,
        );
      } else {
        throw Exception(response['errors']?.toString() ?? 'Signup completion failed');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        status: SignupStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> sendEmailOTP() async {
    try {
      final response = await ApiService.sendEmailOTP(state.email);
      
      if (response['success'] != true) {
        throw Exception(response['error']?.toString() ?? 'Failed to send OTP');
      }
    } catch (e) {
      throw Exception('Failed to send email OTP: $e');
    }
  }

  Future<bool> verifyEmailOTP(String otpCode) async {
    try {
      final response = await ApiService.verifyEmailOTP(state.email, otpCode);
      return response['success'] == true;
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }

  Future<void> resendEmailOTP() async {
    try {
      final response = await ApiService.resendEmailOTP(state.email);
      
      if (response['success'] != true) {
        throw Exception(response['error']?.toString() ?? 'Failed to resend OTP');
      }
    } catch (e) {
      throw Exception('Failed to resend OTP: $e');
    }
  }

  Future<bool> validateEmail(String email) async {
    try {
      final response = await ApiService.validateEmail(email);
      return response['available'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> validateUsername(String username) async {
    try {
      final response = await ApiService.validateUsername(username);
      return response['available'] == true;
    } catch (e) {
      return false;
    }
  }

  void reset() {
    final sessionId = const Uuid().v4();
    state = SignupState(sessionId: sessionId);
  }

  void refreshSession() {
    // Regenerate session ID while keeping user data
    final newSessionId = const Uuid().v4();
    state = state.copyWith(
      sessionId: newSessionId,
      status: SignupStatus.step1Complete,  // Reset to step 1 status
      errorMessage: '',
    );
  }
}

final signupProvider =
    StateNotifierProvider<SignupNotifier, SignupState>((ref) {
  return SignupNotifier();
});
