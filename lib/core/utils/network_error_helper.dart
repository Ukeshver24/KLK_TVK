import 'dart:io';
import 'package:dio/dio.dart';

/// Centralized utility to ensure user-friendly error messages across the entire app.
/// Completely protects citizens from raw backend stack traces, Prisma errors, SQL, and technical jargon.
class NetworkErrorHelper {
  static const String defaultEn = 'Please check your internet connection';
  static const String defaultTa = 'தயவுசெய்து உங்கள் இணைய இணைப்பை சரிபார்க்கவும்';

  /// Sanitizes and formats any error into an accurate, user-friendly message
  static String format(dynamic error, {bool isTamil = false}) {
    final offlineMsg = isTamil ? defaultTa : defaultEn;
    final serverErrorMsg = isTamil
        ? 'சர்வர் பிழை ஏற்பட்டுள்ளது. சிறிது நேரம் கழித்து மீண்டும் முயற்சிக்கவும்.'
        : 'Server error occurred. Please try again later.';

    if (error == null) return serverErrorMsg;

    if (error is DioException) {
      // 1. Genuine Network / Offline / DNS errors ONLY
      if (error.type == DioExceptionType.connectionError ||
          error.error is SocketException) {
        return offlineMsg;
      }

      // 2. Server response timeout
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return isTamil
            ? 'சர்வர் பதில் அளிக்க தாமதமாகிறது. சிறிது நேரம் கழித்து மீண்டும் முயற்சிக்கவும்.'
            : 'Server response timed out. Please try again.';
      }

      // 3. Server returned a JSON response message
      if (error.response?.data != null && error.response?.data is Map) {
        final rawMsg = error.response?.data['message']?.toString();
        if (rawMsg != null && rawMsg.trim().isNotEmpty) {
          final lower = rawMsg.toLowerCase();

          // A) User not found / deleted from DB
          if (lower.contains('user not found') ||
              lower.contains('user account not found') ||
              lower.contains('userid_fkey') ||
              lower.contains('user_fkey')) {
            return isTamil
                ? 'பயனர் கணக்கு காணப்படவில்லை. தயவுசெய்து மீண்டும் உள்நுழையவும்.'
                : 'User not found. Please log in again.';
          }

          // B) Technical Prisma / Stack Trace / SQL Leak -> Show clean Server Error
          if (lower.contains('prisma') ||
              lower.contains('foreign key') ||
              lower.contains('constraint') ||
              lower.contains('invocation') ||
              lower.contains('wwwroot') ||
              lower.contains('stack') ||
              lower.contains('syntaxerror') ||
              lower.contains('query') ||
              lower.contains('fkey') ||
              lower.contains('column') ||
              lower.contains('database') ||
              lower.contains('internal server')) {
            final code = error.response?.statusCode ?? 500;
            return isTamil
                ? 'சர்வர் பிழை ($code). சிறிது நேரம் கழித்து மீண்டும் முயற்சிக்கவும்.'
                : 'Server error ($code). Please try again.';
          }

          // C) Socket errors inside backend message
          if (lower.contains('socket') ||
              lower.contains('failed host lookup') ||
              lower.contains('network is unreachable')) {
            return offlineMsg;
          }

          return rawMsg;
        }
      }

      // 4. HTTP 401 Unauthorized / Session Expired
      if (error.response?.statusCode == 401) {
        return isTamil
            ? 'பயனர் கணக்கு காணப்படவில்லை. தயவுசெய்து மீண்டும் உள்நுழையவும்.'
            : 'User not found. Please log in again.';
      }

      // 5. HTTP 404 Not Found
      if (error.response?.statusCode == 404) {
        return isTamil
            ? 'கோரப்பட்ட விவரங்கள் கிடைக்கவில்லை.'
            : 'Requested information not found.';
      }

      // 6. HTTP 500+ Server Errors
      final status = error.response?.statusCode ?? 0;
      if (status >= 500) {
        return isTamil
            ? 'சர்வர் பிழை ($status). சிறிது நேரம் கழித்து மீண்டும் முயற்சிக்கவும்.'
            : 'Server error ($status). Please try again later.';
      }
    }

    final str = error.toString();
    final lower = str.toLowerCase();

    // User deleted / not found
    if (lower.contains('user not found') || lower.contains('userid_fkey')) {
      return isTamil
          ? 'பயனர் கணக்கு காணப்படவில்லை. தயவுசெய்து மீண்டும் உள்நுழையவும்.'
          : 'User not found. Please log in again.';
    }

    // Only genuine socket exceptions are offline
    if (lower.contains('socketexception') || lower.contains('failed host lookup')) {
      return offlineMsg;
    }

    return serverErrorMsg;
  }
}
