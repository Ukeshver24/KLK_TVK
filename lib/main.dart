import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/constants/app_theme.dart';
import 'core/services/session_service.dart';
import 'core/services/push_notification_service.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

// Global ScrollBehavior that completely removes Android stretch overscroll & rubber-band effects across the entire app
class NoStretchScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase Core
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  // 2. Initialize Push Notification Services & Background Listeners
  try {
    await PushNotificationService.instance.initialize();
  } catch (e) {
    debugPrint('PushNotificationService initialization notice: $e');
  }

  // 3. Load active user session
  try {
    await SessionService.instance.loadSession();
  } catch (e) {
    debugPrint('SessionService initialization notice: $e');
  }

  // 4. Configure System UI Overlay & Edge-to-Edge display
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  runApp(const TVKGrievanceApp());
}

class TVKGrievanceApp extends StatelessWidget {
  const TVKGrievanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: PushNotificationService.navigatorKey,
      title: 'TVK Grievance Portal',
      debugShowCheckedModeBanner: false,
      scrollBehavior: NoStretchScrollBehavior(),
      theme: AppTheme.darkTheme,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(context).textScaler.clamp(
              minScaleFactor: 0.85,
              maxScaleFactor: 1.0,
            ),
          ),
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}