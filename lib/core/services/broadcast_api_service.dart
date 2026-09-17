import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../network/api_client.dart';

class BroadcastAlertModel {
  final String id;
  final String title;
  final String message;
  final String severity; // EMERGENCY, ANNOUNCEMENT, WEATHER, EVENT
  final String? imageUrl;
  final bool isActive;
  final String targetScope;
  final String showFrequency; // EVERY_OPEN, ONCE_PER_DAY
  final String authorTag; // From the Desk of MLA
  final String updatedAt;

  BroadcastAlertModel({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    this.imageUrl,
    required this.isActive,
    required this.targetScope,
    required this.showFrequency,
    required this.authorTag,
    required this.updatedAt,
  });

  factory BroadcastAlertModel.fromJson(Map<String, dynamic> json) {
    String? rawImage = json['imageUrl']?.toString() ?? json['fullImageUrl']?.toString();
    String? resolvedImage;

    if (rawImage != null && rawImage.isNotEmpty && !rawImage.startsWith('data:')) {
      if (rawImage.startsWith('http')) {
        resolvedImage = rawImage;
      } else {
        final cleanPath = rawImage.startsWith('/') ? rawImage : '/$rawImage';
        final host = ApiClient.isProduction 
            ? ApiClient.productionHost 
            : ((!kIsWeb && Platform.isAndroid) ? 'http://10.0.2.2:4000' : 'http://localhost:4000');
        resolvedImage = '$host$cleanPath';
      }
    }

    return BroadcastAlertModel(
      id: json['id']?.toString() ?? 'singleton',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      severity: json['severity']?.toString() ?? 'EMERGENCY',
      imageUrl: resolvedImage,
      isActive: json['isActive'] == true,
      targetScope: json['targetScope']?.toString() ?? 'Entire Kallakurichi Constituency (79)',
      showFrequency: json['showFrequency']?.toString() ?? 'EVERY_OPEN',
      authorTag: json['authorTag']?.toString() ?? 'From the Desk of MLA',
      updatedAt: json['updatedAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}

class BroadcastApiService {
  final Dio _dio = ApiClient().dio;
  static BroadcastAlertModel? _cachedAlert;
  static DateTime? _cacheTime;

  Future<BroadcastAlertModel?> getActiveAlert({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedAlert != null && _cacheTime != null) {
      if (DateTime.now().difference(_cacheTime!).inSeconds < 120) {
        return _cachedAlert;
      }
    }

    try {
      final response = await _dio.get('/broadcasts/active');
      if (response.statusCode == 200 && response.data != null && response.data['data'] != null) {
        _cachedAlert = BroadcastAlertModel.fromJson(response.data['data']);
        _cacheTime = DateTime.now();
        return _cachedAlert;
      }
    } catch (e) {
      if (kDebugMode) {
        print('BroadcastApiService Error: $e');
      }
    }
    return _cachedAlert;
  }
}
