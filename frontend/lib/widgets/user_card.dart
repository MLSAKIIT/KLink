import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback? onTap;
  final VoidCallback? onFollow;
  final bool? isFollowing;

  const UserCard({
    Key? key,
    required this.user,
    this.onTap,
    this.onFollow,
    this.isFollowing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      color: const Color(0xFF1A1A1A),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey[800],
          child: Text(
            user.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          user.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          '@${user.username}',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
        trailing: onFollow != null
            ? ElevatedButton(
                onPressed: onFollow,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(80, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Text(
                  isFollowing == true ? 'Unfollow' : 'Follow',
                  style: const TextStyle(fontSize: 12),
                ),
              )
            : null,
      ),
    );
  }
}
