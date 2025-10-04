import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widget_data_manager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      print('Background task started: $task');
      
      // Get access token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      
      if (accessToken != null) {
        await WidgetDataManager.updateWidgetData(accessToken);
      } else {
        print('No access token available');
      }
      
      return Future.value(true);
    } catch (e) {
      print('Background task error: $e');
      return Future.value(false);
    }
  });
}

class WidgetBackgroundService {
  static const String widgetUpdateTask = 'widgetUpdateTask';
  
  // Initialize background service
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  // Start periodic widget updates (every 30 minutes)
  static Future<void> startPeriodicUpdate() async {
    await Workmanager().registerPeriodicTask(
      widgetUpdateTask,
      widgetUpdateTask,
      frequency: const Duration(minutes: 30),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
    print('Periodic widget update task registered');
  }

  // Stop periodic updates
  static Future<void> stopPeriodicUpdate() async {
    await Workmanager().cancelByUniqueName(widgetUpdateTask);
    print('Periodic widget update task cancelled');
  }

  // Trigger immediate update
  static Future<void> triggerImmediateUpdate(String? accessToken) async {
    await WidgetDataManager.updateWidgetData(accessToken);
  }
}
