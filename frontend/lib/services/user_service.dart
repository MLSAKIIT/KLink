import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/config/api_config.dart';
import 'package:frontend/models/user_model.dart';

class UserService {
  final String? accessToken;

  UserService(this.accessToken);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (accessToken != null) 'Authorization': 'Bearer $accessToken',
  };

  // Search users
  Future<List<User>> searchUsers(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.usersEndpoint}/search?q=${Uri.encodeComponent(query)}&limit=$limit',
        ),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['users'] as List)
            .map((json) => User.fromJson(json))
            .toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to search users (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Search error: $e');
    }
  }

  // Get user by ID or username
  Future<User> getUserById(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.usersEndpoint}/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['user']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to load user (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Load user error: $e');
    }
  }
}
