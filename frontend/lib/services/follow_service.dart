import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/config/api_config.dart';
import 'package:frontend/models/user_model.dart';

class FollowService {
  final String? accessToken;

  FollowService(this.accessToken);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (accessToken != null) 'Authorization': 'Bearer $accessToken',
  };

  // Follow user
  Future<void> followUser(String userId) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.followEndpoint}/$userId'),
      headers: _headers,
    );

    if (response.statusCode != 201) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to follow user');
    }
  }

  // Unfollow user
  Future<void> unfollowUser(String userId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.followEndpoint}/$userId'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to unfollow user');
    }
  }

  // Get followers
  Future<List<User>> getFollowers(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.followEndpoint}/$userId/followers?limit=$limit&offset=$offset',
      ),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['followers'] as List)
          .map((json) => User.fromJson(json['follower']))
          .toList();
    } else {
      throw Exception('Failed to load followers');
    }
  }

  // Get following
  Future<List<User>> getFollowing(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.followEndpoint}/$userId/following?limit=$limit&offset=$offset',
      ),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['following'] as List)
          .map((json) => User.fromJson(json['following']))
          .toList();
    } else {
      throw Exception('Failed to load following');
    }
  }

  // Check if following
  Future<bool> checkFollowing(String userId) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.followEndpoint}/$userId/check',
      ),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['isFollowing'] ?? false;
    } else {
      return false;
    }
  }
}
