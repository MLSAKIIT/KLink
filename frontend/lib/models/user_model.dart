class User {
  final String id;
  final String email;
  final String name;
  final String? username;
  final String? bio;
  final String? avatarUrl;
  final DateTime createdAt;
  final int? postsCount;
  final int? followersCount;
  final int? followingCount;
  final bool? isFollowing;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.username,
    this.bio,
    this.avatarUrl,
    required this.createdAt,
    this.postsCount,
    this.followersCount,
    this.followingCount,
    this.isFollowing,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown User',
      username: json['username'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      postsCount: json['postsCount'] as int?,
      followersCount: json['followersCount'] as int?,
      followingCount: json['followingCount'] as int?,
      isFollowing: json['isFollowing'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'username': username,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'postsCount': postsCount,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'isFollowing': isFollowing,
    };
  }
}
