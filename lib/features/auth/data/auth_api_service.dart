import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/utils/network_error_helper.dart';

class AuthResult {
  final bool isSuccess;
  final String message;
  final Map<String, dynamic>? data;

  AuthResult({required this.isSuccess, required this.message, this.data});
}

class AuthApiService {
  final Dio _dio = ApiClient().dio;

  /// Register new Citizen account
  Future<AuthResult> register({
    required String fullName,
    required String mobile,
    String? dob,
    String? address,
    required String mpin,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'fullName': fullName.trim(),
          'mobile': mobile.trim(),
          if (dob != null && dob.isNotEmpty) 'dob': dob.trim(),
          if (address != null && address.isNotEmpty) 'address': address.trim(),
          'mpin': mpin.trim(),
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return AuthResult(
          isSuccess: true,
          message:
              response.data['message'] ?? 'Account registered successfully',
          data: response.data['data'],
        );
      } else {
        return AuthResult(
          isSuccess: false,
          message: response.data['message'] ?? 'Failed to register account',
        );
      }
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        message: NetworkErrorHelper.format(e),
      );
    }
  }

  /// Login with Mobile and MPIN
  Future<AuthResult> login({
    required String mobile,
    required String mpin,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'mobile': mobile.trim(), 'mpin': mpin.trim()},
      );

      if (response.statusCode == 200) {
        return AuthResult(
          isSuccess: true,
          message: response.data['message'] ?? 'Login successful',
          data: response.data['data'],
        );
      } else {
        return AuthResult(
          isSuccess: false,
          message: response.data['message'] ?? 'Login failed',
        );
      }
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        message: NetworkErrorHelper.format(e),
      );
    }
  }

  /// Update Citizen Profile in PostgreSQL Database
  Future<AuthResult> updateProfile({
    required String userId,
    String? fullName,
    String? mobile,
    String? dob,
    String? address,
  }) async {
    try {
      final Map<String, dynamic> body = {'userId': userId};
      if (fullName != null) body['fullName'] = fullName.trim();
      if (mobile != null) body['mobile'] = mobile.trim();
      if (dob != null) body['dob'] = dob.trim();
      if (address != null) body['address'] = address.trim();

      final response = await _dio.put('/auth/profile', data: body);

      if (response.statusCode == 200) {
        return AuthResult(
          isSuccess: true,
          message: response.data['message'] ?? 'Profile updated successfully',
          data: response.data['data'],
        );
      } else {
        return AuthResult(
          isSuccess: false,
          message: response.data['message'] ?? 'Failed to update profile',
        );
      }
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        message: NetworkErrorHelper.format(e),
      );
    }
  }

  /// Reset / Forgot MPIN
  Future<AuthResult> resetMpin({
    required String mobile,
    required String dob,
    required String newMpin,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/reset-mpin',
        data: {
          'mobile': mobile.trim(),
          'dob': dob.trim(),
          'newMpin': newMpin.trim(),
        },
      );

      if (response.statusCode == 200) {
        return AuthResult(
          isSuccess: true,
          message:
              response.data['message'] ?? 'MPIN has been reset successfully',
          data: response.data['data'],
        );
      } else {
        return AuthResult(
          isSuccess: false,
          message: response.data['message'] ?? 'Failed to reset MPIN',
        );
      }
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        message: NetworkErrorHelper.format(e),
      );
    }
  }

  /// Register or Sync Firebase FCM Push Token to Backend Database
  Future<void> syncFcmToken(String fcmToken) async {
    try {
      await _dio.post('/auth/fcm-token', data: {'fcmToken': fcmToken.trim()});
    } catch (_) {
      // Background sync, silently handle if network is offline
    }
  }

  /// Permanently delete the authenticated Citizen account
  Future<AuthResult> deleteAccount() async {
    try {
      final response = await _dio.delete('/auth/account');

      if (response.statusCode == 200) {
        return AuthResult(
          isSuccess: true,
          message: response.data['message'] ?? 'Account deleted successfully',
          data: response.data['data'],
        );
      } else {
        return AuthResult(
          isSuccess: false,
          message: response.data['message'] ?? 'Failed to delete account',
        );
      }
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        message: NetworkErrorHelper.format(e),
      );
    }
  }
}
