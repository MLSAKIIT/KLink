class ApiConfig {
  // Change this based on your environment
  // For Android Emulator: http://10.0.2.2:3000
  // For iOS Simulator: http://localhost:3000
  // For Physical Device: http://YOUR_COMPUTER_IP:3000
  static const String baseUrl = 'http://192.168.1.8:3000/api';

  // Endpoints
  static const String authEndpoint = '/auth';
  static const String postsEndpoint = '/posts';
  static const String commentsEndpoint = '/comments';
  static const String followEndpoint = '/follow';
  static const String usersEndpoint = '/users';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
