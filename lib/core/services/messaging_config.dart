import 'dart:convert';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class MessagingConfig {
  static Future<void> initFirebaseMessaging(BuildContext context) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      log('🚫 User denied notification permission.');
      _showPermissionDialog(context);
    } else {
      log('✅ User granted notification permission.');
    }

    // Listen for foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("📩 Foreground Notification: ${message.notification?.title}");
    });

    // Handle notification when app is opened from a terminated state
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        handleNotification(message.data);
      }
    });

    // Handle notification when app is opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotification(message.data);
    });

    // Background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Listen for token refresh events
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      log("🔁 New FCM Token: $newToken");
      // TODO: send updated token to your server if needed
    });
  }

  /// Handles background notifications
  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    await Firebase.initializeApp(); // ensure Firebase is initialized
    log(
      "📨 Handling a background notification: ${message.notification?.title}",
    );
  }

  /// Show permission dialog if user denied
  static void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Permission Required"),
          content: const Text(
            "This app requires notification permissions to function properly.",
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await FirebaseMessaging.instance.requestPermission(
                  alert: true,
                  badge: true,
                  sound: true,
                  criticalAlert: true,
                );
              },
              child: const Text("Allow"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
}

/// 🔑 Generate an OAuth2 access token for sending FCM messages
Future<String> getAccessToken() async {
  // Load your new service account file (replace with your actual path)
  final jsonString = await rootBundle.loadString(
    'assets/notifications_key/sahtee-service-account.json',
  );

  final accountCredentials = auth.ServiceAccountCredentials.fromJson(
    jsonString,
  );
  final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
  final client = await auth.clientViaServiceAccount(accountCredentials, scopes);

  return client.credentials.accessToken.data;
}

/// 🚀 Send FCM notification using HTTP v1 API
Future<void> sendNotification({
  required String token,
  required String title,
  required String body,
}) async {
  final String accessToken = await getAccessToken();

  // ✅ Use your correct Firebase project ID
  final String fcmUrl =
      'https://fcm.googleapis.com/v1/projects/sahtee-9cd53/messages:send';

  final response = await http.post(
    Uri.parse(fcmUrl),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
    body: jsonEncode(<String, dynamic>{
      'message': {
        'token': token,
        'notification': {'title': title, 'body': body},
        'android': {
          'notification': {
            'icon': 'app_icon', // your app's icon name in res/drawable
            'sound': 'default',
          },
        },
        'apns': {
          'payload': {
            'aps': {'sound': 'default', 'content-available': 1},
          },
        },
      },
    }),
  );

  if (response.statusCode == 200) {
    log('✅ Notification sent successfully');
  } else {
    log('❌ Failed to send notification: ${response.body}');
  }
}

/// Handle notification click or data payload
void handleNotification(Map<String, dynamic> data) {
  log("🧩 Handling notification: $data");
}
