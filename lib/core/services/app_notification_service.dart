import 'dart:developer';
import 'package:breezefood/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AppNotificationService {
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'labbridge_high_importance',
    'LabBridge Notifications',
    description: 'Important notifications for doctors',
    importance: Importance.high,
  );

  /// ============================================================
  /// INITIALIZE
  /// ============================================================
  static Future<void> init() async {
    // Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // LOCAL init
    await _initLocal();

    // FCM init
    await _initFCM();

    log("🔔 AppNotificationService initialized");
  }

  /// ============================================================
  /// LOCAL NOTIFICATIONS
  /// ============================================================
  static Future<void> _initLocal() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    const settings = InitializationSettings(android: android, iOS: ios);

    await _local.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        _handleNotificationTap(details.payload);
      },
    );

    final androidImpl = _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidImpl?.createNotificationChannel(_channel);
  }

  /// ============================================================
  /// FIREBASE MESSAGING
  /// ============================================================
  static Future<void> _initFCM() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(alert: true, sound: true, badge: true);

    // TOKEN
    final token = await messaging.getToken();
    log("📲 FCM TOKEN: $token");

    FirebaseMessaging.instance.onTokenRefresh.listen((t) {
      log("🔄 NEW TOKEN: $t");
      // TODO: Save to server
    });

    // FOREGROUND handler
    FirebaseMessaging.onMessage.listen((message) {
      log("📩 Foreground message: ${message.notification?.title}");
      _showLocal(message);
    });

    // BACKGROUND handler
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
  }

  /// ============================================================
  /// BACKGROUND
  /// ============================================================
static Future<void> _backgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  log("📨 Background notification: ${message.notification?.title}");
}


  /// ============================================================
  /// SHOW LOCAL NOTIFICATION
  /// ============================================================
  static Future<void> _showLocal(RemoteMessage msg) async {
    final notification = msg.notification;
    final android = notification?.android;

    if (notification == null) return;

    await _local.show(
      msg.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: msg.data.isNotEmpty ? msg.data.toString() : null,
    );
  }

  static void _handleNotificationTap(String? payload) {
    if (payload == null) return;
    try {
      final data = payload;
      log("🧩 Local Tap: $data");
    } catch (_) {}
  }
}
class FCMTokenService {
  static Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }
}