class ApiEndpoints {
  static const String baseUrl = 'https://warless-aden-atavistically.ngrok-free.dev';
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String refresh = '$baseUrl/auth/refresh';
  static const String getUserProfile = '$baseUrl/user/profile';
  static const String updateUserProfile = '$baseUrl/user/update';
  static const String fetchItems = '$baseUrl/items';
  static const String createItem = '$baseUrl/items/create';
  static const String deleteItem = '$baseUrl/items/delete';
  static const String fetchStatistics = '$baseUrl/analysis/statistics';
  static const String fetchSegmentation = '$baseUrl/analysis/segmentation';
  static const String fetchChangeDetection = '$baseUrl/analysis/change-detection';
}