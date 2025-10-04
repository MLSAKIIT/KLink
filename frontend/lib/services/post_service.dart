import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/post_model.dart';

class PostService {
  final String? accessToken;

  PostService(this.accessToken);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      };

  // Get all posts
  Future<List<Post>> getPosts({int limit = 20, int offset = 0}) async {
    final response = await http.get(
      Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.postsEndpoint}?limit=$limit&offset=$offset'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['posts'] as List).map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  // Get single post
  Future<Post> getPost(String postId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.postsEndpoint}/$postId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Post.fromJson(data['post']);
    } else {
      throw Exception('Failed to load post');
    }
  }

  // Get user posts
  Future<List<Post>> getUserPosts(String userId,
      {int limit = 20, int offset = 0}) async {
    final response = await http.get(
      Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.postsEndpoint}/user/$userId?limit=$limit&offset=$offset'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['posts'] as List).map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load user posts');
    }
  }

  // Create post
  Future<Post> createPost({
    required String content,
    String? imageUrl,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.postsEndpoint}'),
      headers: _headers,
      body: jsonEncode({
        'content': content,
        if (imageUrl != null) 'imageUrl': imageUrl,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Post.fromJson(data['post']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to create post');
    }
  }

  // Update post
  Future<Post> updatePost({
    required String postId,
    String? content,
    String? imageUrl,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.postsEndpoint}/$postId'),
      headers: _headers,
      body: jsonEncode({
        if (content != null) 'content': content,
        if (imageUrl != null) 'imageUrl': imageUrl,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Post.fromJson(data['post']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to update post');
    }
  }

  // Delete post
  Future<void> deletePost(String postId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.postsEndpoint}/$postId'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to delete post');
    }
  }

  // Like post
  Future<void> likePost(String postId) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.postsEndpoint}/$postId/like'),
      headers: _headers,
    );

    if (response.statusCode != 201) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to like post');
    }
  }

  // Unlike post
  Future<void> unlikePost(String postId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.postsEndpoint}/$postId/like'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to unlike post');
    }
  }
}
