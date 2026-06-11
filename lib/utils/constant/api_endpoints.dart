class ApiEndpoints {
  static const String baseUrl = 'https://warless-aden-atavistically.ngrok-free.dev';
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String refresh = '$baseUrl/auth/refresh';
  static const String profile = '$baseUrl/auth/profile';
  static const String fetchStatistics = '$baseUrl/analysis/statistics';
  static const String fetchSegmentation = '$baseUrl/analysis/segmentation';
  static const String fetchChangeDetection = '$baseUrl/analysis/change-detection';
  static const String fetchOverlay = '$baseUrl/visualization/overlay';
}