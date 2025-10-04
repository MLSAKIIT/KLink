import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/config/api_config.dart';
import 'package:frontend/models/comment_model.dart';

class CommentService {
  final String? accessToken;

  CommentService(this.accessToken);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (accessToken != null) 'Authorization': 'Bearer $accessToken',
  };

  // Get comments for a post
  Future<List<Comment>> getCommentsByPost(
    String postId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.commentsEndpoint}/post/$postId?limit=$limit&offset=$offset',
      ),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['comments'] as List)
          .map((json) => Comment.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }

  // Create comment
  Future<Comment> createComment({
    required String postId,
    required String content,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.commentsEndpoint}'),
      headers: _headers,
      body: jsonEncode({'postId': postId, 'content': content}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Comment.fromJson(data['comment']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to create comment');
    }
  }

  // Delete comment
  Future<void> deleteComment(String commentId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.commentsEndpoint}/$commentId'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to delete comment');
    }
  }
}
