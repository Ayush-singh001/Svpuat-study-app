import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    debugPrint('FCM Background Message ID: ${message.messageId}');
  } catch (e) {
    debugPrint('FCM Background Message Error: $e');
  }
}

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  bool _isInitialized = false;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // 1. Initialize Firebase Core safely
      await Firebase.initializeApp();
      _isInitialized = true;
      debugPrint('Firebase Core Initialized Successfully.');

      // 2. Request Notification Permissions
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('FCM Notification Permission Status: ${settings.authorizationStatus}');

      // 3. Fetch FCM Token
      _fcmToken = await messaging.getToken();
      if (_fcmToken != null) {
        debugPrint('==================================================');
        debugPrint('FCM DEVICE TOKEN: $_fcmToken');
        debugPrint('==================================================');
        // Register token with Express backend
        await NotificationService().registerFcmToken(_fcmToken!);
      }

      // 4. Token Refresh Listener
      messaging.onTokenRefresh.listen((newToken) async {
        _fcmToken = newToken;
        debugPrint('FCM Token Refreshed: $newToken');
        await NotificationService().registerFcmToken(newToken);
      });

      // 5. Foreground Messages Listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('FCM Foreground Notification Received: ${message.notification?.title}');
      });

      // 6. Background Message Handler Registration
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } catch (e) {
      debugPrint('Firebase FCM Setup Warning: $e');
      debugPrint('Ensure google-services.json is configured in android/app/ for live FCM push notifications.');
    }
  }

  Future<void> syncTokenWithBackend() async {
    if (_fcmToken != null) {
      await NotificationService().registerFcmToken(_fcmToken!);
    }
  }
}
