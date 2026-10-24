import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPermissionService {
  AppPermissionService._();
  static final AppPermissionService instance = AppPermissionService._();

  static const String _permissionsRequestedKey = 'tvk_initial_permissions_requested';

  /// Request all initial essential permissions when user first opens the newly installed app
  Future<void> requestInitialPermissionsOnLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alreadyRequested = prefs.getBool(_permissionsRequestedKey) ?? false;

      // Always ensure permissions are requested on first launch
      if (!alreadyRequested) {
        await prefs.setBool(_permissionsRequestedKey, true);
      }

      if (Platform.isAndroid || Platform.isIOS) {
        // 1. Notification Permission
        try {
          final notifStatus = await Permission.notification.status;
          if (!notifStatus.isGranted) {
            await Permission.notification.request();
          }
        } catch (e) {
          debugPrint('Notification permission error: $e');
        }

        // 2. Camera Permission
        try {
          final cameraStatus = await Permission.camera.status;
          if (!cameraStatus.isGranted) {
            await Permission.camera.request();
          }
        } catch (e) {
          debugPrint('Camera permission error: $e');
        }

        // 3. Storage / Files Permissions
        try {
          if (Platform.isAndroid) {
            // Android uses the system Photo Picker for image selection (no permission required).
            // Request legacy storage permission only for Android 12 and below (API <= 32).
            final storageStatus = await Permission.storage.status;
            if (!storageStatus.isGranted) {
              await Permission.storage.request();
            }
          } else if (Platform.isIOS) {
            final photosStatus = await Permission.photos.status;
            if (!photosStatus.isGranted) {
              await Permission.photos.request();
            }
          }
        } catch (e) {
          debugPrint('Storage permission error: $e');
        }
      }
    } catch (e) {
      debugPrint('Error in requestInitialPermissionsOnLaunch: $e');
    }
  }

  /// Explicitly ensure storage permission is granted before file download (for Android <= 12)
  Future<bool> ensureStoragePermission() async {
    try {
      if (!Platform.isAndroid) return true;

      // On Android 13+ (API 33+), scoped storage / app storage does not require legacy storage permission
      final status = await Permission.storage.status;
      if (status.isGranted) return true;

      final res = await Permission.storage.request();
      return res.isGranted;
    } catch (_) {
      return true;
    }
  }
}
