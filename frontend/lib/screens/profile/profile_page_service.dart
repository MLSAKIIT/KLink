import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileService {
  final String baseUrl;

  ProfileService(this.baseUrl);

  Future<Map<String, dynamic>> getProfile(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/profile/$userId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<List<dynamic>> getUserPosts(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/posts/user/$userId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<void> followUser(String userId) async {
    final response = await http.post(Uri.parse('$baseUrl/follow/$userId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to follow');
    }
  }

  Future<void> unfollowUser(String userId) async {
    final response = await http.post(Uri.parse('$baseUrl/unfollow/$userId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to unfollow');
    }
  }
}