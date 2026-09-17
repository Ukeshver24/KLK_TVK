import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'session_service.dart';
import '../network/api_client.dart';
import '../../features/track/presentation/screens/track_status_details_screen.dart';

/// Top-level background message handler for FCM
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  if (kDebugMode) {
    print('🔔 [FCM Background Notification]: ${message.notification?.title} - ${message.notification?.body}');
  }
}

class PushNotificationService {
  static final PushNotificationService instance = PushNotificationService._internal();
  factory PushNotificationService() => instance;
  PushNotificationService._internal();

  /// Global navigator key to enable routing from background/foreground notification clicks
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static String? pendingReferenceId;
  static String? pendingStatus;

  FirebaseMessaging? _fcm;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// High priority notification channel for Android heads-up popup banner & sound
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'tvk_high_importance_channel',
    'TVK Important Notifications',
    description: 'Constituency broadcast alerts and grievance status updates.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  /// Initialize Firebase & Local Notifications
  Future<void> initialize() async {
    try {
      if (kIsWeb) return;
      if (Firebase.apps.isEmpty) {
        if (kDebugMode) {
          print('⚠️ Firebase is not initialized. Skipping PushNotificationService setup.');
        }
        return;
      }

      _fcm = FirebaseMessaging.instance;

      // 1. Request Notification Permissions (Android 13+ & iOS)
      final NotificationSettings settings = await _fcm!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (kDebugMode) {
        print('🔔 Notification authorization status: ${settings.authorizationStatus}');
      }

      // 2. Initialize Local Notifications Plugin for Android/iOS Heads-up banners
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@drawable/ic_notification');
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _handleLocalNotificationClick(response.payload);
        },
      );

      // 3. Create High Priority Android Channel
      if (Platform.isAndroid) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(_channel);
      }

      // 4. Register Background Handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 5. Foreground Notification Listener (Shows popup banner when app is actively open)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('🔔 [Foreground Push Received]: ${message.notification?.title}');
        }
        _showForegroundNotification(message);
      });

      // 6. Notification Click Listener (App Opened from Background)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('🔔 Notification opened app from background: ${message.data}');
        }
        _extractAndNavigate(message.data);
      });

      // 7. Check if app was launched by clicking notification from terminated state
      try {
        final RemoteMessage? initialMessage = await _fcm?.getInitialMessage();
        if (initialMessage != null) {
          if (kDebugMode) {
            print('🔔 App launched from terminated state via notification: ${initialMessage.data}');
          }
          _extractAndNavigate(initialMessage.data);
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ getInitialMessage notice: $e');
        }
      }

      // 8. Get and cache FCM Device Token & auto-sync to backend
      await _fetchFcmToken();

      // Listen for token refreshes
      _fcm?.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        if (kDebugMode) {
          print('🔄 [FCM Token Refreshed]: $newToken');
        }
        syncTokenWithBackend(newToken);
      });
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ PushNotificationService initialize error: $e');
      }
    }
  }

  /// Retrieve FCM Token for this physical device / emulator
  Future<String?> _fetchFcmToken() async {
    try {
      if (_fcm == null) return null;
      _fcmToken = await _fcm!.getToken();
      if (kDebugMode) {
        print('====================================================');
        print('🔥 [FIREBASE FCM DEVICE TOKEN]:');
        print(_fcmToken);
        print('====================================================');
      }
      if (_fcmToken != null && _fcmToken!.isNotEmpty) {
        await syncTokenWithBackend(_fcmToken);
      }
      return _fcmToken;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to fetch FCM Token: $e');
      }
      return null;
    }
  }

  /// Sync device FCM push token with backend PostgreSQL User record
  Future<void> syncTokenWithBackend([String? tokenToSync]) async {
    final token = tokenToSync ?? _fcmToken;
    if (token == null || token.isEmpty) return;

    final userId = SessionService.instance.userId;
    if (userId.isEmpty) return;

    try {
      final dio = ApiClient().dio;
      final response = await dio.post(
        '/auth/fcm-token',
        data: {
          'userId': userId,
          'fcmToken': token.trim(),
        },
      );
      if (kDebugMode) {
        print('✅ [FCM Token Synced to Backend DB for User $userId]: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Background FCM token sync notice: $e');
      }
    }
  }

  /// Display a heads-up banner when notification arrives while app is open in foreground
  void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;

    if (notification != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title ?? 'TVK Grievance Portal',
        notification.body ?? '',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: '@drawable/ic_notification',
            largeIcon: const DrawableResourceAndroidBitmap('@drawable/ic_notification_large'),
            color: const Color(0xFF8C0000),
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  /// Navigate directly to the complaint tracking page
  static void navigateToTracking(String referenceId, {String? status}) {
    final cleanId = referenceId.trim();
    if (cleanId.isEmpty) return;

    final navState = navigatorKey.currentState;
    if (navState != null) {
      navState.push(
        MaterialPageRoute(
          builder: (context) => TrackStatusDetailsScreen(
            selectedLanguage: SessionService.instance.savedLanguage,
            referenceId: cleanId,
            status: status ?? 'SUBMITTED',
          ),
        ),
      );
    } else {
      // If navigator is not yet mounted (e.g. app starting), cache for launch
      pendingReferenceId = cleanId;
      pendingStatus = status;
    }
  }

  void _extractAndNavigate(Map<dynamic, dynamic>? data) {
    if (data == null || data.isEmpty) return;
    final refId = data['referenceId']?.toString() ??
        data['tokenNumber']?.toString() ??
        data['complaintId']?.toString();
    final status = data['status']?.toString();

    if (refId != null && refId.trim().isNotEmpty) {
      navigateToTracking(refId.trim(), status: status);
    }
  }

  void _handleLocalNotificationClick(String? payload) {
    if (kDebugMode) {
      print('👉 User tapped local notification payload: $payload');
    }
    if (payload == null || payload.isEmpty) return;

    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) {
        _extractAndNavigate(decoded);
        return;
      }
    } catch (_) {}

    if (payload.startsWith('TVK-') || payload.startsWith('tvk-')) {
      navigateToTracking(payload.trim());
    }
  }
}
