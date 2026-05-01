import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'prayer_service.dart';

typedef TZDateTime = tz.TZDateTime;

/// Kunci SharedPreferences untuk pilihan suara
const _kSoundKey = 'prayer_notif_sound';

class PrayerNotifService {
  static final PrayerNotifService _instance = PrayerNotifService._internal();
  factory PrayerNotifService() => _instance;
  PrayerNotifService._internal();

  final _plugin = FlutterLocalNotificationsPlugin();

  // ── Opsi suara ──────────────────────────────────────────────────────────────
  // key → label
  static const Map<String, String> soundOptions = {
    'default': 'Suara Bawaan',
    'adzan_makkah': 'Adzan Makkah',
    'adzan_madinah': 'Adzan Madinah',
  };

  // ID notifikasi per waktu sholat
  static const _idSubuh = 1;
  static const _idDzuhur = 2;
  static const _idAshar = 3;
  static const _idMaghrib = 4;
  static const _idIsya = 5;

  // ── Init ────────────────────────────────────────────────────────────────────
  Future<void> init() async {
    if (!Platform.isAndroid) return; // Notifikasi hanya untuk Android

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
  }

  // ── Baca / Tulis pilihan suara ───────────────────────────────────────────────
  static Future<String> getSavedSound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kSoundKey) ?? 'default';
  }

  static Future<void> saveSound(String soundKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSoundKey, soundKey);
  }

  // ── Schedule notifikasi ──────────────────────────────────────────────────────
  Future<void> schedulePrayerNotifications(
    PrayerSchedule schedule,
    String timezone,
  ) async {
    if (!Platform.isAndroid) return; // Notifikasi hanya untuk Android
    await cancelAll();

    final soundKey = await getSavedSound();
    final location = _getLocation(timezone);
    final now = tz.TZDateTime.now(location);

    // Gunakan tanggal hari ini dari now (dalam timezone lokal) agar konsisten
    final today = DateTime(now.year, now.month, now.day);

    final prayers = [
      {
        'id': _idSubuh,
        'name': 'Subuh',
        'time': schedule.subuh,
        'isSubuh': true,
      },
      {
        'id': _idDzuhur,
        'name': 'Dzuhur',
        'time': schedule.dzuhur,
        'isSubuh': false,
      },
      {
        'id': _idAshar,
        'name': 'Ashar',
        'time': schedule.ashar,
        'isSubuh': false,
      },
      {
        'id': _idMaghrib,
        'name': 'Maghrib',
        'time': schedule.maghrib,
        'isSubuh': false,
      },
      {'id': _idIsya, 'name': 'Isya', 'time': schedule.isya, 'isSubuh': false},
    ];

    for (final prayer in prayers) {
      final scheduledTime = _parseTime(
        prayer['time'] as String,
        today,
        location,
      );
      if (scheduledTime.isBefore(now)) {
        print(
          '⏳ [NOTIF] Terlewat: ${prayer['name']} di $scheduledTime (sekarang $now)',
        );
        continue;
      }

      print(
        '✅ [NOTIF] Menjadwalkan ${prayer['name']} pada $scheduledTime (sekarang $now)',
      );

      final isSubuh = prayer['isSubuh'] as bool;
      final details = _buildNotifDetails(soundKey, isSubuh);

      try {
        await _plugin.zonedSchedule(
          prayer['id'] as int,
          'Waktunya ${prayer['name']}',
          'Saatnya melaksanakan sholat ${prayer['name']}',
          scheduledTime,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: null,
        );
        print('🔔 [NOTIF] Sukses dijadwalkan: ${prayer['name']}');
      } catch (e) {
        print('❌ [NOTIF] Gagal jadwal ${prayer['name']}: $e');
      }
    }
  }

  Future<void> cancelAll() async => _plugin.cancelAll();

  // ── Test Notifikasi ────────────────────────────────────────────────────────
  Future<void> showTestNotification() async {
    final soundKey = await getSavedSound();
    final details = _buildNotifDetails(soundKey, false); // tes suara non-subuh

    await _plugin.show(
      999,
      'Test Adzan',
      'Ini adalah tes suara ${soundOptions[soundKey]}',
      details,
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  /// Bangun NotificationDetails berdasarkan soundKey dan apakah ini Subuh.
  /// Subuh memakai file `<soundKey>_subuh`, sholat lain pakai `<soundKey>`.
  NotificationDetails _buildNotifDetails(String soundKey, bool isSubuh) {
    final AndroidNotificationDetails android;

    if (soundKey == 'default') {
      // Suara sistem default — channel v3 agar Android re-create dengan importance max
      android = AndroidNotificationDetails(
        'prayer_channel_default_v3',
        'Waktu Sholat',
        channelDescription: 'Pengingat waktu sholat — suara bawaan',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        icon: '@mipmap/ic_launcher',
      );
    } else {
      // Subuh → <soundKey>_subuh, lainnya → <soundKey>
      final rawName = isSubuh ? '${soundKey}_subuh' : soundKey;
      final channelId = 'prayer_${rawName}_v3';

      android = AndroidNotificationDetails(
        channelId,
        'Waktu Sholat (${soundOptions[soundKey]}${isSubuh ? ' — Subuh' : ''})',
        channelDescription: 'Adzan $rawName',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        sound: RawResourceAndroidNotificationSound(rawName),
        icon: '@mipmap/ic_launcher',
      );
    }

    return NotificationDetails(android: android);
  }

  TZDateTime _parseTime(String hhmm, DateTime tanggal, tz.Location location) {
    final parts = hhmm.split(':');
    return tz.TZDateTime(
      location,
      tanggal.year,
      tanggal.month,
      tanggal.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  tz.Location _getLocation(String timezone) {
    try {
      final loc = tz.getLocation(timezone);
      print('🌍 [NOTIF] Timezone berhasil dimuat: $timezone');
      return loc;
    } catch (e) {
      print(
        '⚠️ [NOTIF] Timezone $timezone gagal, fallback ke Asia/Jakarta: $e',
      );
      return tz.getLocation('Asia/Jakarta');
    }
  }
}
