import 'user_model.dart';

class Post {
  final String id;
  final String content;
  final String? imageUrl;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User user;
  final int commentCount;
  final int likeCount;
  final bool isLiked;

  Post({
    required this.id,
    required this.content,
    this.imageUrl,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.commentCount,
    required this.likeCount,
    required this.isLiked,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      content: json['content'],
      imageUrl: json['imageUrl'],
      userId: json['userId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      user: User.fromJson(json['user']),
      commentCount: json['commentCount'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
    );
  }

  Post copyWith({
    bool? isLiked,
    int? likeCount,
    int? commentCount,
  }) {
    return Post(
      id: id,
      content: content,
      imageUrl: imageUrl,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      user: user,
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
