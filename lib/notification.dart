import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Wrapper around flutter_local_notifications to keep setup in one place.
class FlutterLocalNotification {
  FlutterLocalNotification._();

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static bool _timezoneInitialized = false;

  static const AndroidNotificationDetails _androidAssignmentDetails =
      AndroidNotificationDetails(
    'assignment_deadline_channel',
    '과제 마감 알림',
    channelDescription: '마감이 임박한 과제를 알려줍니다.',
    importance: Importance.high,
    priority: Priority.high,
  );

  static const DarwinNotificationDetails _iosAssignmentDetails =
      DarwinNotificationDetails();

  static const NotificationDetails _assignmentNotificationDetails =
      NotificationDetails(
    android: _androidAssignmentDetails,
    iOS: _iosAssignmentDetails,
  );

  // Call once during app startup to wire Android/iOS init settings.
  static init() async {
    await _ensureTimezoneInitialized();
    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings('mipmap/ic_launcher');

    DarwinInitializationSettings iosInitializationSettings =
        const DarwinInitializationSettings(
          // We request permissions later so onboarding flow can decide timing.
          requestAlertPermission: false,

          requestBadgePermission: false,

          requestSoundPermission: false,
        );

    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,

      iOS: iosInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> _ensureTimezoneInitialized() async {
    if (_timezoneInitialized) return;
    tz.initializeTimeZones();
    try {
      final String timeZoneName =
          await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
    _timezoneInitialized = true;
  }

  // Requests notification permissions on each supported platform.
  static Future<void> requestNotificationPermission() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  // Shows a simple test notification using the default channel configuration.
  static Future<void> showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'channel id',
          'channel name',

          channelDescription: 'channel description',

          importance: Importance.max,

          priority: Priority.max,

          showWhen: false,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,

      iOS: DarwinNotificationDetails(badgeNumber: 1),
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'test title',
      'test body',
      notificationDetails,
    );
  }

  static int _assignmentReminderId(String assignmentId, int daysBefore) {
    return Object.hash(assignmentId, daysBefore) & 0x7fffffff;
  }

  static Future<void> scheduleAssignmentReminder({
    required String assignmentId,
    required String title,
    required DateTime endDate,
    required int daysBefore,
  }) async {
    await _ensureTimezoneInitialized();

    final tz.TZDateTime scheduled = tz.TZDateTime.from(endDate, tz.local)
        .subtract(Duration(days: daysBefore));
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) {
      // Don't schedule if the trigger time already passed.
      return;
    }

    await cancelAssignmentReminder(assignmentId, daysBefore);

    final body = daysBefore <= 0
        ? '$title 과제가 오늘 마감돼요.'
        : '$title 과제가 ${daysBefore}일 안에 마감돼요.';

    await flutterLocalNotificationsPlugin.zonedSchedule(
      _assignmentReminderId(assignmentId, daysBefore),
      '과제 마감 알림',
      body,
      scheduled,
      _assignmentNotificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelAssignmentReminder(
    String assignmentId,
    int daysBefore,
  ) async {
    await flutterLocalNotificationsPlugin.cancel(
      _assignmentReminderId(assignmentId, daysBefore),
    );
  }

  static Future<void> cancelAllAssignmentReminders(String assignmentId) async {
    await cancelAssignmentReminder(assignmentId, 3);
    await cancelAssignmentReminder(assignmentId, 1);
  }

  static Future<void> showAssignmentReminderNow({
    required String assignmentId,
    required String title,
    required int daysBefore,
  }) async {
    final body = daysBefore <= 0
        ? '$title 과제가 오늘 마감돼요.'
        : '$title 과제가 ${daysBefore}일 안에 마감돼요.';

    await flutterLocalNotificationsPlugin.show(
      _assignmentReminderId(assignmentId, daysBefore),
      '과제 마감 알림',
      body,
      _assignmentNotificationDetails,
    );
  }
}
