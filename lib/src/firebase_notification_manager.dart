import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseNotificationManager {
  static FirebaseNotificationManager? _instance;
  late FirebaseMessaging _messaging;

  FirebaseNotificationManager._internal();

  factory FirebaseNotificationManager() {
    _instance ??= FirebaseNotificationManager._internal();
    return _instance!;
  }

  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      _messaging = FirebaseMessaging.instance;

      await _requestPermissions();
      await _setupMessageHandlers();
    } catch (e) {
      if (kDebugMode) {
        print('Firebase initialization failed: $e');
      }
    }
  }

  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('Permission granted: ${settings.authorizationStatus}');
    }
  }

  Future<void> _setupMessageHandlers() async {
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Received foreground message: ${message.notification?.title}');
      }
      // Firebase handles the display automatically in foreground for newer versions
    });

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Notification tapped: ${message.notification?.title}');
      }
      _handleNotificationData(message.data);
    });

    // Handle notification tap when app is terminated
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      if (kDebugMode) {
        print(
          'App launched from notification: ${initialMessage.notification?.title}',
        );
      }
      _handleNotificationData(initialMessage.data);
    }
  }

  void _handleNotificationData(Map<String, dynamic> data) {
    if (kDebugMode) {
      print('Notification data: $data');
    }
    // App developers can override this to handle custom data
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    if (kDebugMode) {
      print('Subscribed to topic: $topic');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    if (kDebugMode) {
      print('Unsubscribed from topic: $topic');
    }
  }

  void onTokenRefresh(Function(String) callback) {
    _messaging.onTokenRefresh.listen((String token) {
      callback(token);
    });
  }
}

// Background message handler (must be top-level function)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('Background message: ${message.notification?.title}');
  }
}
