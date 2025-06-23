enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  authenticating,
  registering,
  error,
}

class AuthState {
  final AuthStatus status;
  final String? accessToken;
  final String? refreshToken;
  final int? userId;
  final String? errorMessage;

  AuthState({
    this.status = AuthStatus.initial,
    this.accessToken,
    this.refreshToken,
    this.userId,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? accessToken,
    String? refreshToken,
    int? userId,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      userId: userId ?? this.userId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // Create authenticated state
  static AuthState authenticated({
    required String accessToken,
    required String refreshToken,
    required int userId,
  }) {
    return AuthState(
      status: AuthStatus.authenticated,
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
    );
  }

  // Create unauthenticated state
  static AuthState unauthenticated() {
    return AuthState(
      status: AuthStatus.unauthenticated,
    );
  }

  // Create error state
  static AuthState error(String message) {
    return AuthState(
      status: AuthStatus.error,
      errorMessage: message,
    );
  }

  // Check if authenticated
  bool get isAuthenticated => status == AuthStatus.authenticated;
}