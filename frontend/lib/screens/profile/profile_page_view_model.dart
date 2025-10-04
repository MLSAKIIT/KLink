// import 'package:flutter/material.dart';
//
// class ProfileViewModel extends ChangeNotifier {
//   String username = "Username";
//   String status = "STATUS IN 25 CHARACTERS & SPACES";
//   String description = "This is a test description that is exactly 200 characters long. Please count carefully to ensure it reaches 200 characters, including spaces, punctuation, and letters, for accurate testing purposes.";
//
//   String followers = '121';
//   String posts = '50';
//   String following = '80';
//
//   List<Map<String, dynamic>> userPosts = [
//     {"index": 0,
//       "username": "Username",
//       "Text": "Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text",
//       "isLiked": false,
//       "isDisLiked": false,
//     },
//     {"index": 1,
//       "username": "Username",
//       "Text": "Text Text Text Text",
//     "isLiked": false,
//     "isDisLiked": false,
//     },
//   ];
//
//   void deletePost(int index) {
//     userPosts.removeAt(index);
//     notifyListeners();
//   }
//
//   void toggleLike(int index) {
//     userPosts[index]['isLiked'] = !userPosts[index]['isLiked'];
//     notifyListeners();
//   }
//
//   void toggleDisLike(int index) {
//     userPosts[index]['isDisLiked'] = !userPosts[index]['isDisLiked'];
//     notifyListeners();
//   }
//
// }








// viewmodel/profile_page_view_model.dart
import 'package:flutter/material.dart';
import 'package:klink/profile/profile_page_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileService _profileService = ProfileService('http://localhost:3000'); // example base URL

  String username = 'Username';
  String status = 'STATUS IN 25 CHARACTERS & SPACES';
  String description = 'This is a test description that is exactly 200 characters long. Please count carefully to ensure it reaches 200 characters, including spaces, punctuation, and letters, for accurate testing purposes.';
  String followers = '0';
  String posts = '0';
  String following = '0';

  List<Map<String, dynamic>> userPosts = [];

  bool isLoading = false;
  bool isFollowing = false;

  Future<void> loadProfile(String userId) async {
    try {
      isLoading = true;
      notifyListeners();

      final profileData = await _profileService.getProfile(userId);
      final postsData = await _profileService.getUserPosts(userId);

      username = profileData['username'] ?? 'Username';
      status = profileData['status'] ?? 'STATUS IN 25 CHARACTERS & SPACES';
      description = profileData['bio'] ?? 'This is a test description that is exactly 200 characters long. Please count carefully to ensure it reaches 200 characters, including spaces, punctuation, and letters, for accurate testing purposes.';
      followers = profileData['followers'].toString();
      following = profileData['following'].toString();
      posts = postsData.length.toString();

      userPosts = postsData.map<Map<String, dynamic>>((p) => {
        'index': p['id'],
        'username': p['username'],
        'Text': p['text'],
        'isLiked': p['isLiked'] ?? false,
        'isDisLiked': p['isDisLiked'] ?? false,
      }).toList();

    } catch (e) {
      debugPrint('Failed to load profile: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFollow(String userId) async {
    try {
      if (isFollowing) {
        await _profileService.unfollowUser(userId);
        followers = (int.parse(followers) - 1).toString();
      } else {
        await _profileService.followUser(userId);
        followers = (int.parse(followers) + 1).toString();
      }
      isFollowing = !isFollowing;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to toggle follow: $e');
    }
  }

  void toggleLike(int index) {
    userPosts[index]['isLiked'] = !userPosts[index]['isLiked'];
    notifyListeners();
  }

  void toggleDisLike(int index) {
    userPosts[index]['isDisLiked'] = !userPosts[index]['isDisLiked'];
    notifyListeners();
  }
}
