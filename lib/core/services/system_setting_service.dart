import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../network/api_client.dart';

class SystemSettingModel {
  final bool maintenanceMode;
  final String maintenanceTitleEn;
  final String maintenanceTitleTa;
  final String maintenanceMsgEn;
  final String maintenanceMsgTa;

  // App Version & Force Update Controls
  final String minAppVersion;
  final String latestAppVersion;
  final bool forceUpdate;
  final String playStoreUrl;
  final String appStoreUrl;
  final String updateTitleEn;
  final String updateTitleTa;
  final String updateMsgEn;
  final String updateMsgTa;

  SystemSettingModel({
    required this.maintenanceMode,
    required this.maintenanceTitleEn,
    required this.maintenanceTitleTa,
    required this.maintenanceMsgEn,
    required this.maintenanceMsgTa,
    required this.minAppVersion,
    required this.latestAppVersion,
    required this.forceUpdate,
    required this.playStoreUrl,
    required this.appStoreUrl,
    required this.updateTitleEn,
    required this.updateTitleTa,
    required this.updateMsgEn,
    required this.updateMsgTa,
  });

  factory SystemSettingModel.fromJson(Map<String, dynamic> json) {
    return SystemSettingModel(
      maintenanceMode: json['maintenanceMode'] == true,
      maintenanceTitleEn: json['maintenanceTitleEn']?.toString() ?? 'Under Scheduled Maintenance',
      maintenanceTitleTa: json['maintenanceTitleTa']?.toString() ?? 'பராமரிப்பு பணியில் உள்ளது',
      maintenanceMsgEn: json['maintenanceMsgEn']?.toString() ??
          'We are currently upgrading our systems to serve you better. The app will be back online shortly.',
      maintenanceMsgTa: json['maintenanceMsgTa']?.toString() ??
          'சேவையக மேம்பாட்டு பணிகள் நடைபெற்று வருகின்றன. செயலி விரைவில் மீண்டும் பயன்பாட்டுக்கு வரும்.',

      minAppVersion: json['minAppVersion']?.toString() ?? '1.0.0',
      latestAppVersion: json['latestAppVersion']?.toString() ?? '1.0.0',
      forceUpdate: json['forceUpdate'] == true,
      playStoreUrl: json['playStoreUrl']?.toString() ??
          'https://play.google.com/store/apps/details?id=com.gradixtvk.tvk_application',
      appStoreUrl: json['appStoreUrl']?.toString() ?? 'https://apps.apple.com/app/id6400000000',
      updateTitleEn: json['updateTitleEn']?.toString() ?? 'Update Required',
      updateTitleTa: json['updateTitleTa']?.toString() ?? 'புதிய பதிப்பு கிடைக்கிறது',
      updateMsgEn: json['updateMsgEn']?.toString() ??
          'A new version of the app is available. Please update to continue using the app with the latest features and improvements.',
      updateMsgTa: json['updateMsgTa']?.toString() ??
          'செயலியின் புதிய பதிப்பு கிடைக்கிறது. புதிய அம்சங்களுடன் தொடர்ந்து பயன்பாட்டிற்கு செயலியைப் புதுப்பிக்கவும்.',
    );
  }

  static SystemSettingModel get defaultSetting => SystemSettingModel(
        maintenanceMode: false,
        maintenanceTitleEn: 'Under Scheduled Maintenance',
        maintenanceTitleTa: 'பராமரிப்பு பணியில் உள்ளது',
        maintenanceMsgEn:
            'We are currently upgrading our systems to serve you better. The app will be back online shortly.',
        maintenanceMsgTa:
            'சேவையக மேம்பாட்டு பணிகள் நடைபெற்று வருகின்றன. செயலி விரைவில் மீண்டும் பயன்பாட்டுக்கு வரும்.',
        minAppVersion: '1.0.0',
        latestAppVersion: '1.0.0',
        forceUpdate: false,
        playStoreUrl: 'https://play.google.com/store/apps/details?id=com.gradixtvk.tvk_application',
        appStoreUrl: 'https://apps.apple.com/app/id6400000000',
        updateTitleEn: 'Update Required',
        updateTitleTa: 'புதிய பதிப்பு கிடைக்கிறது',
        updateMsgEn:
            'A new version of the app is available. Please update to continue using the app with the latest features and improvements.',
        updateMsgTa:
            'செயலியின் புதிய பதிப்பு கிடைக்கிறது. புதிய அம்சங்களுடன் தொடர்ந்து பயன்பாட்டிற்கு செயலியைப் புதுப்பிக்கவும்.',
      );

  /// Checks if the installed app version requires a mandatory update
  bool shouldForceUpdate(String currentVersion) {
    if (forceUpdate) return true;
    try {
      final curClean = currentVersion.split('+').first.trim();
      final minClean = minAppVersion.split('+').first.trim();

      final curParts = curClean.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final minParts = minClean.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      for (int i = 0; i < minParts.length; i++) {
        final cur = i < curParts.length ? curParts[i] : 0;
        final min = minParts[i];
        if (cur < min) return true;
        if (cur > min) return false;
      }
    } catch (_) {}
    return false;
  }
}

class SystemSettingService {
  final Dio _dio = ApiClient().dio;
  static SystemSettingModel? _cachedSettings;
  static DateTime? _cacheTime;

  Future<SystemSettingModel> getSettings({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedSettings != null && _cacheTime != null) {
      if (DateTime.now().difference(_cacheTime!).inSeconds < 5) {
        return _cachedSettings!;
      }
    }

    try {
      final response = await _dio.get('/system/settings');
      if (response.statusCode == 200 && response.data != null && response.data['data'] != null) {
        _cachedSettings = SystemSettingModel.fromJson(response.data['data']);
        _cacheTime = DateTime.now();
        return _cachedSettings!;
      }
    } catch (e) {
      if (kDebugMode) {
        print('SystemSettingService Error fetching system settings: $e');
      }
    }
    return _cachedSettings ?? SystemSettingModel.defaultSetting;
  }
}
