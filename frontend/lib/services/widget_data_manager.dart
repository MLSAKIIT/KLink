import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';
import '../services/post_service.dart';

class WidgetDataManager {
  static const String _keyWidgetData = 'widget_data';
  static const String _keyLastUpdate = 'widget_last_update';
  
  // Update widget data
  static Future<void> updateWidgetData(String? accessToken) async {
    try {
      if (accessToken == null) {
        print('No access token available for widget update');
        return;
      }

      final postService = PostService(accessToken);
      
      // Fetch latest posts from following users
      final posts = await postService.getFollowingPosts(limit: 10);
      
      if (posts.isEmpty) {
        await _setNoPostsData();
        return;
      }

      // Get the latest post with image
      final latestPost = posts.first;
      
      // Store widget data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyWidgetData, jsonEncode({
        'imageUrl': latestPost.imageUrl ?? '',
        'username': latestPost.user.username,
        'name': latestPost.user.name,
        'content': latestPost.content.length > 100 
            ? '${latestPost.content.substring(0, 100)}...'
            : latestPost.content,
        'timestamp': latestPost.createdAt.toIso8601String(),
        'avatarUrl': latestPost.user.avatarUrl ?? '',
      }));
      await prefs.setInt(_keyLastUpdate, DateTime.now().millisecondsSinceEpoch);

      // Update home widget
      await HomeWidget.saveWidgetData<String>('imageUrl', latestPost.imageUrl ?? '');
      await HomeWidget.saveWidgetData<String>('username', latestPost.user.username);
      await HomeWidget.saveWidgetData<String>('name', latestPost.user.name);
      await HomeWidget.saveWidgetData<String>('content', 
          latestPost.content.length > 100 
              ? '${latestPost.content.substring(0, 100)}...'
              : latestPost.content);
      await HomeWidget.saveWidgetData<String>('timestamp', _formatTimestamp(latestPost.createdAt));
      await HomeWidget.saveWidgetData<bool>('hasData', true);
      
      await HomeWidget.updateWidget(
        name: 'KLinkWidgetProvider',
        androidName: 'KLinkWidgetProvider',
        iOSName: 'KLinkWidget',
      );
      
      print('Widget data updated successfully');
    } catch (e) {
      print('Error updating widget data: $e');
      await _setNoPostsData();
    }
  }

  static Future<void> _setNoPostsData() async {
    await HomeWidget.saveWidgetData<bool>('hasData', false);
    await HomeWidget.saveWidgetData<String>('message', 'No posts available');
    await HomeWidget.updateWidget(
      name: 'KLinkWidgetProvider',
      androidName: 'KLinkWidgetProvider',
      iOSName: 'KLinkWidget',
    );
  }

  // Format timestamp for display
  static String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  // Get cached widget data
  static Future<Map<String, dynamic>?> getCachedWidgetData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataString = prefs.getString(_keyWidgetData);
      
      if (dataString != null) {
        return jsonDecode(dataString);
      }
    } catch (e) {
      print('Error getting cached widget data: $e');
    }
    return null;
  }

  // Check if widget data needs update (older than 30 minutes)
  static Future<bool> needsUpdate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdate = prefs.getInt(_keyLastUpdate);
      
      if (lastUpdate == null) return true;
      
      final lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
      final now = DateTime.now();
      
      return now.difference(lastUpdateTime).inMinutes > 30;
    } catch (e) {
      return true;
    }
  }
}
