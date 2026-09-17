import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../services/session_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: _getBaseUrl(),
        connectTimeout: const Duration(seconds: 25),
        receiveTimeout: const Duration(seconds: 35),
        sendTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Security & Authentication Interceptor: Attach JWT Bearer token & user identification
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = SessionService.instance.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          final user = SessionService.instance.currentUser;
          if (user != null && user.id.isNotEmpty) {
            options.headers['x-user-id'] = user.id;
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // If receiving 401 Unauthorized, session has expired or token is invalid
          if (error.response?.statusCode == 401) {
            await SessionService.instance.clearSession();
          }
          return handler.next(error);
        },
      ),
    );

    // Lightweight error-focused logging in debug mode to prevent UI thread frame drops
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: false,
          requestHeader: false,
          requestBody: false,
          responseHeader: false,
          responseBody: false,
          error: true,
        ),
      );
    }
  }

  /// =========================================================================
  /// 🌐 API URL CONFIGURATION (LIVE vs LOCAL SWITCH)
  /// =========================================================================
  /// 👉 To switch between LIVE and LOCAL:
  /// - For LIVE SERVER: Set `isProduction = true;`
  /// - For LOCAL TESTING: Set `isProduction = false;` (or comment/uncomment below)
  /// =========================================================================
  
  // 🟢 [INACTIVE / BACKUP] LIVE PRODUCTION API:
  // static const bool isProduction = true;
  static const String productionBaseUrl = 'https://tvk.gradixtech.com/api/v1';
  static const String productionHost = 'https://tvk.gradixtech.com';

  // 🟡 [ACTIVE] LOCAL DEVELOPMENT API:
  static const bool isProduction = true;
  static const String localBaseUrlAndroid = 'http://10.0.2.2:4000/api/v1';
  static const String localBaseUrlIosWeb = 'http://localhost:4000/api/v1';

  /// Automatically resolves API Base URL based on environment, build mode and platform
  static String _getBaseUrl() {
    // If custom API_URL is passed via --dart-define (e.g. flutter build apk --dart-define=API_URL=...)
    const envApiUrl = String.fromEnvironment('API_URL');
    if (envApiUrl.isNotEmpty) {
      return envApiUrl;
    }

    // 1️⃣ Live Server: Used when isProduction is true
    if (isProduction) {
      return productionBaseUrl;
    }

    // 2️⃣ Local Development & Testing:
    // If testing on Android Emulator, 10.0.2.2 maps to host machine's localhost port 4000
    if (!kIsWeb && Platform.isAndroid) {
      return localBaseUrlAndroid;
    }
    // iOS Simulator, macOS Desktop, Web
    return localBaseUrlIosWeb;
  }
}
