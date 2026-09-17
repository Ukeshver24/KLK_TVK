import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';

class BannerItemModel {
  final String id;
  final int slot;
  final String imageUrl;
  final String? title;
  final String fullUrl;

  BannerItemModel({
    required this.id,
    required this.slot,
    required this.imageUrl,
    this.title,
    required this.fullUrl,
  });

  factory BannerItemModel.fromJson(Map<String, dynamic> json) {
    String rawUrl = json['fullUrl'] ?? json['imageUrl'] ?? '';
    final String cleanImageUrl = json['imageUrl'] ?? '';

    if (rawUrl.isNotEmpty && !rawUrl.startsWith('assets/') && !rawUrl.startsWith('data:')) {
      if (!rawUrl.startsWith('http')) {
        final cleanPath = rawUrl.startsWith('/') ? rawUrl : '/$rawUrl';
        final host = ApiClient.isProduction 
            ? ApiClient.productionHost 
            : ((!kIsWeb && Platform.isAndroid) ? 'http://10.0.2.2:4000' : 'http://localhost:4000');
        rawUrl = '$host$cleanPath';
      } else if (!ApiClient.isProduction && !kIsWeb && Platform.isAndroid) {
        rawUrl = rawUrl.replaceAll('localhost:4000', '10.0.2.2:4000');
      }
    }

    return BannerItemModel(
      id: json['id']?.toString() ?? '',
      slot: json['slot'] is int ? json['slot'] : int.tryParse(json['slot']?.toString() ?? '1') ?? 1,
      imageUrl: cleanImageUrl,
      title: json['title']?.toString(),
      fullUrl: rawUrl,
    );
  }
}

class BannerApiService {
  final Dio _dio = ApiClient().dio;
  static List<String>? _cachedBanners;
  static DateTime? _cacheTime;

  static const List<String> defaultFallbackBanners = [
    'assets/images/tvk_banner1.jpg',
  ];

  /// Fetch active live banners from backend PostgreSQL
  /// Returns only the slots that actually have uploaded images (can be 1, 2, or 3).
  Future<List<String>> getLiveBanners({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedBanners != null && _cacheTime != null) {
      if (DateTime.now().difference(_cacheTime!).inSeconds < 120) {
        return _cachedBanners!;
      }
    }

    try {
      final response = await _dio.get('/banners');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is List && data.isNotEmpty) {
          final List<String> result = [];
          for (final item in data) {
            final model = BannerItemModel.fromJson(item as Map<String, dynamic>);
            if (model.fullUrl.trim().isNotEmpty && !model.fullUrl.startsWith('assets/')) {
              result.add(model.fullUrl);
            }
          }
          if (result.isNotEmpty) {
            _cachedBanners = result;
            _cacheTime = DateTime.now();
            return result;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('BannerApiService Error fetching banners: $e');
      }
    }
    return _cachedBanners ?? defaultFallbackBanners;
  }
}
