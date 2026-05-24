/// Application configuration file
/// Edit the URLs here to change server endpoints across the entire app

class AppConfig {
  /// Main backend server (accounts, auth, etc.)
  static const String mainServerHost = '192.168.1.3';
  static const int mainServerPort = 8000;
  static const String mainServerUrl = 'http://$mainServerHost:$mainServerPort';

  /// Social service backend server
  static const String socialServerHost = '192.168.1.3';
  static const int socialServerPort = 8001;
  static const String socialServerUrl = 'http://$socialServerHost:$socialServerPort';

  /// API endpoints
  static const String apiBaseUrl = '$mainServerUrl/api/';
  static const String authBaseUrl = '$mainServerUrl/api/v1/accounts/auth/';
  static const String socialApiBaseUrl = '$socialServerUrl/api/social-service/';
  static const String healthCheckUrl = '$mainServerUrl/api/server/health/';

  /// Specific endpoints
  static const String getNameEndpoint = '$mainServerUrl/api/account/getName/';
}
