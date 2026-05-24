import 'package:flutter/foundation.dart';

enum SignupStatus {
  initial,
  loading,
  step1Complete,
  step2Complete,
  step3Complete,
  step4Complete,
  step5Complete,
  completed,
  error,
}

class SignupState {
  final SignupStatus status;
  final String email;
  final String username;
  final String password;
  final String confirmPassword;
  final String gender;
  final String dateOfBirth;
  final String phoneNumber;
  final bool privacyPolicyAccepted;
  final String sessionId;
  final String errorMessage;
  final bool isLoading;

  const SignupState({
    this.status = SignupStatus.initial,
    this.email = '',
    this.username = '',
    this.password = '',
    this.confirmPassword = '',
    this.gender = '',
    this.dateOfBirth = '',
    this.phoneNumber = '',
    this.privacyPolicyAccepted = false,
    this.sessionId = '',
    this.errorMessage = '',
    this.isLoading = false,
  });

  SignupState copyWith({
    SignupStatus? status,
    String? email,
    String? username,
    String? password,
    String? confirmPassword,
    String? gender,
    String? dateOfBirth,
    String? phoneNumber,
    bool? privacyPolicyAccepted,
    String? sessionId,
    String? errorMessage,
    bool? isLoading,
  }) {
    return SignupState(
      status: status ?? this.status,
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      privacyPolicyAccepted:
          privacyPolicyAccepted ?? this.privacyPolicyAccepted,
      sessionId: sessionId ?? this.sessionId,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
