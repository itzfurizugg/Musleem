import 'dart:async';
import 'dart:isolate';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  final NotificationService _notificationService = NotificationService();

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    await _notificationService.init();
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    final now = DateTime.now();
    final format = DateFormat('HH:mm');
    final currentTime = format.format(now);

    final prefs = await SharedPreferences.getInstance();
    final subuh = prefs.getString('prayer_subuh');
    final dzuhur = prefs.getString('prayer_dzuhur');
    final ashar = prefs.getString('prayer_ashar');
    final maghrib = prefs.getString('prayer_maghrib');
    final isya = prefs.getString('prayer_isya');

    void checkAndNotify(String? prayerTime, String prayerName) {
      if (prayerTime != null && prayerTime.startsWith(currentTime)) {
        _notificationService.showNotification(
          id: prayerName.hashCode,
          title: 'Waktu $prayerName',
          body:
              'Saatnya menunaikan ibadah sholat $prayerName untuk wilayah Anda.',
        );
      }
    }

    checkAndNotify(subuh, 'Subuh');
    checkAndNotify(dzuhur, 'Dzuhur');
    checkAndNotify(ashar, 'Ashar');
    checkAndNotify(maghrib, 'Maghrib');
    checkAndNotify(isya, 'Isya');
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    // Cleanup if needed
  }
}

class ForegroundService {
  static void init() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service',
        channelName: 'Foreground Service Notification',
        channelDescription: 'Running in the background to check prayer times',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'ic_launcher',
        ),
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 60000, // 1 minute
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  static Future<bool> start() async {
    if (!await FlutterForegroundTask.canDrawOverlays) {
      // Consider requesting permission if needed, but for notifications it might not be strictly necessary depending on OS
    }

    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
        notificationTitle: 'MuslimNoob Aktif',
        notificationText: 'Mengecek waktu sholat di background',
        callback: startCallback,
      );
    }
  }

  static Future<bool> stop() async {
    return FlutterForegroundTask.stopService();
  }
}
