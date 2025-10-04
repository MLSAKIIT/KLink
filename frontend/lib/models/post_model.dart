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
      id: json['id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      userId: json['userId'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      user: User.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      commentCount: json['commentCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
    );
  }

  Post copyWith({bool? isLiked, int? likeCount, int? commentCount}) {
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
