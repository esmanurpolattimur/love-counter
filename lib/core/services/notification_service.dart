import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _notifications = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _anniversaryId = 1001;
  static const _birthdayId = 1002;
  static const _channelId = 'love_counter_reminders';

  Future<void> initialize() async {
    if (_ready) return;
    timezone_data.initializeTimeZones();
    final deviceZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(deviceZone.name));

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _notifications.initialize(settings);
    _ready = true;
  }

  Future<void> requestPermissions() async {
    await initialize();
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> reschedule({
    required DateTime anniversaryDate,
    DateTime? birthdayDate,
    required bool anniversaryEnabled,
    required bool birthdayEnabled,
    required int leadDays,
  }) async {
    await initialize();
    await _notifications.cancel(_anniversaryId);
    await _notifications.cancel(_birthdayId);
    if (anniversaryEnabled) {
      await _scheduleAnnual(
        id: _anniversaryId,
        date: anniversaryDate,
        title: 'Yıldönümünüz yaklaşıyor 💖',
        body: '$leadDays gün sonra birlikte olduğunuz özel günü kutlayacaksınız.',
        leadDays: leadDays,
      );
    }
    if (birthdayEnabled && birthdayDate != null) {
      await _scheduleAnnual(
        id: _birthdayId,
        date: birthdayDate,
        title: 'Doğum günü yaklaşıyor 🎂',
        body: '$leadDays gün sonra sevdiğinin doğum günü.',
        leadDays: leadDays,
      );
    }
  }

  Future<void> _scheduleAnnual({required int id, required DateTime date, required String title, required String body, required int leadDays}) async {
    final now = tz.TZDateTime.now(tz.local);
    var target = tz.TZDateTime(tz.local, now.year, date.month, date.day, 9).subtract(Duration(days: leadDays));
    if (!target.isAfter(now)) target = tz.TZDateTime(tz.local, now.year + 1, date.month, date.day, 9).subtract(Duration(days: leadDays));
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      target,
      const NotificationDetails(android: AndroidNotificationDetails(_channelId, 'Aşk Sayacı hatırlatıcıları', channelDescription: 'Yıldönümü ve doğum günü hatırlatmaları', importance: Importance.high, priority: Priority.high), iOS: DarwinNotificationDetails()),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }
}
