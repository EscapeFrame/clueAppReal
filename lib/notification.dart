import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Wrapper around flutter_local_notifications to keep setup in one place.
class FlutterLocalNotification {
  FlutterLocalNotification._();

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Call once during app startup to wire Android/iOS init settings.
  static init() async {
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
}
