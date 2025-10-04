import 'user_model.dart';

class Comment {
  final String id;
  final String content;
  final String postId;
  final String userId;
  final DateTime createdAt;
  final User user;

  Comment({
    required this.id,
    required this.content,
    required this.postId,
    required this.userId,
    required this.createdAt,
    required this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'],
      postId: json['postId'],
      userId: json['userId'],
      createdAt: DateTime.parse(json['createdAt']),
      user: User.fromJson(json['user']),
    );
  }
}
