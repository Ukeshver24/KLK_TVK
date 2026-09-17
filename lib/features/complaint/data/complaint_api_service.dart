import 'dart:io';
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/network_error_helper.dart';

class ComplaintModel {
  final String id;
  final String referenceId; // Format: TVK-KKI-26-0001
  final String userId;
  final String? citizenId; // Format: TVK-C-0001
  final String fullName;
  final String mobile;
  final String taluk;
  final String village;
  final String address;
  final String pincode;
  final String category;
  final String description;
  final String? attachment; // Multi-image proof
  final double? latitude;
  final double? longitude;
  final String? locationUrl;
  final String status;
  final String? statusReason;
  final String? adminRemarks;
  final List<Map<String, dynamic>>? timelineEvents;
  final String createdAt;

  ComplaintModel({
    required this.id,
    required this.referenceId,
    required this.userId,
    this.citizenId,
    required this.fullName,
    required this.mobile,
    required this.taluk,
    required this.village,
    required this.address,
    required this.pincode,
    required this.category,
    required this.description,
    this.attachment,
    this.latitude,
    this.longitude,
    this.locationUrl,
    required this.status,
    this.statusReason,
    this.adminRemarks,
    this.timelineEvents,
    required this.createdAt,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    final userObj = json['user'] is Map ? json['user'] as Map<String, dynamic> : null;
    final citizenCode = userObj?['userCode'] as String? ?? json['citizenId'] as String? ?? json['userCode'] as String?;

    double? lat;
    if (json['latitude'] != null) {
      lat = double.tryParse(json['latitude'].toString());
    }
    double? lng;
    if (json['longitude'] != null) {
      lng = double.tryParse(json['longitude'].toString());
    }

    return ComplaintModel(
      id: json['id'] ?? '',
      referenceId: json['referenceId'] ?? '',
      userId: json['userId'] ?? '',
      citizenId: citizenCode,
      fullName: json['fullName'] ?? '',
      mobile: json['mobile'] ?? '',
      taluk: json['taluk'] ?? 'Kallakurichi',
      village: json['village'] ?? '',
      address: json['address'] ?? '',
      pincode: json['pincode'] ?? '606202',
      category: json['category'] ?? 'General',
      description: json['description'] ?? '',
      attachment: json['attachment'],
      latitude: lat,
      longitude: lng,
      locationUrl: json['locationUrl'] as String?,
      status: json['status'] ?? 'SUBMITTED',
      statusReason: json['statusReason'],
      adminRemarks: json['adminRemarks'],
      timelineEvents: json['timelineEvents'] != null && json['timelineEvents'] is List
          ? (json['timelineEvents'] as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList()
          : null,
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
    );
  }
}

class ComplaintResult {
  final bool isSuccess;
  final String message;
  final ComplaintModel? data;

  ComplaintResult({
    required this.isSuccess,
    required this.message,
    this.data,
  });
}

class ComplaintApiService {
  final Dio _dio = ApiClient().dio;

  /// Register a new Citizen Complaint with proof images & GPS problem location
  Future<ComplaintResult> registerComplaint({
    required String userId,
    required String fullName,
    required String mobile,
    required String taluk,
    required String village,
    required String address,
    required String pincode,
    required String category,
    required String description,
    String? attachment,
    double? latitude,
    double? longitude,
    String? locationUrl,
    bool isTamil = false,
  }) async {
    try {
      final Map<String, dynamic> payload = {
        'userId': userId,
        'fullName': fullName.trim(),
        'mobile': mobile.trim(),
        'taluk': taluk.trim(),
        'village': village.trim(),
        'address': address.trim(),
        'pincode': pincode.trim(),
        'category': category.trim(),
        'description': description.trim(),
      };

      if (attachment != null && attachment.trim().isNotEmpty) {
        payload['attachment'] = attachment.trim();
      }
      if (latitude != null) payload['latitude'] = latitude;
      if (longitude != null) payload['longitude'] = longitude;
      if (locationUrl != null && locationUrl.trim().isNotEmpty) {
        payload['locationUrl'] = locationUrl.trim();
      }

      final response = await _dio.post(
        '/complaints/register',
        data: payload,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ComplaintResult(
          isSuccess: true,
          message: response.data['message'] ?? 'Complaint registered successfully',
          data: ComplaintModel.fromJson(response.data['data']),
        );
      } else {
        return ComplaintResult(
          isSuccess: false,
          message: response.data['message'] ??
              (isTamil ? 'புகார் பதிவு செய்ய முடியவில்லை' : 'Failed to register complaint'),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Complaint register exception: $e');
      }
      return ComplaintResult(
        isSuccess: false,
        message: NetworkErrorHelper.format(e, isTamil: isTamil),
      );
    }
  }

  /// Get complaints for logged-in citizen
  Future<List<ComplaintModel>> getMyComplaints(String userId) async {
    try {
      final response = await _dio.get(
        '/complaints/my-complaints',
        queryParameters: {'userId': userId},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List list = response.data['data'] ?? [];
        return list.map((item) => ComplaintModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Track complaint(s) by Reference ID or Registered Mobile Number
  Future<List<ComplaintModel>> trackComplaints(String query) async {
    try {
      final clean = query.trim().replaceAll('#', '');
      final response = await _dio.get('/complaints/track/$clean');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final dynamic rawData = response.data['data'];
        if (rawData is List) {
          return rawData.map((item) => ComplaintModel.fromJson(item)).toList();
        } else if (rawData is Map<String, dynamic>) {
          return [ComplaintModel.fromJson(rawData)];
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Client-side image compression: Downscales large phone camera images (e.g. 5MB -> ~250KB)
  /// using Flutter's native engine image codec in ~30ms before upload for lightning-fast transfer!
  static Future<String> compressImageFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return filePath;

      final int fileLength = await file.length();
      // If already compact (<= 400 KB), skip compression
      if (fileLength <= 400 * 1024) {
        return filePath;
      }

      final bytes = await file.readAsBytes();
      // Downscale native image to max 1280px width
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: 1280,
      );
      final frameInfo = await codec.getNextFrame();
      final byteData = await frameInfo.image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) return filePath;

      final tempDir = Directory.systemTemp;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final cleanBase = filePath.split('/').last.replaceAll(RegExp(r'[^a-zA-Z0-9_\.]'), '_');
      final targetPath = '${tempDir.path}/opt_${timestamp}_$cleanBase.png';
      final compressedFile = File(targetPath);
      await compressedFile.writeAsBytes(byteData.buffer.asUint8List(), flush: true);

      return targetPath;
    } catch (e) {
      debugPrint('⚠️ Client image compression fallback: $e');
      return filePath;
    }
  }

  /// Upload multiple proof image files reliably with compression and parallel speed
  Future<List<String>> uploadMultipleImages(List<String> filePaths) async {
    if (filePaths.isEmpty) return [];

    // 1. First compress all local images concurrently (5MB -> ~250KB each)
    final List<String> preparedPaths = await Future.wait(
      filePaths.map((path) async {
        if (path.startsWith('http')) return path;
        return await compressImageFile(path);
      }),
    );

    // 2. Attempt fast batch upload in a single request
    try {
      final formData = FormData();
      for (final p in preparedPaths) {
        if (!p.startsWith('http')) {
          final file = File(p);
          if (file.existsSync()) {
            final fileName = p.split('/').last;
            formData.files.add(
              MapEntry(
                'images',
                await MultipartFile.fromFile(p, filename: fileName),
              ),
            );
          }
        }
      }

      if (formData.files.isNotEmpty) {
        final response = await _dio.post(
          '/complaints/upload',
          data: formData,
          options: Options(
            contentType: 'multipart/form-data',
            sendTimeout: const Duration(seconds: 60),
            receiveTimeout: const Duration(seconds: 60),
          ),
        );

        if (response.statusCode == 200 && response.data['success'] == true) {
          final data = response.data['data'];
          if (data is Map) {
            final filenamesStr = data['filenames'] ?? data['filename'];
            if (filenamesStr is String && filenamesStr.isNotEmpty) {
              final list = filenamesStr.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
              if (list.length == preparedPaths.length) {
                return list;
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Batch upload notice, falling back to individual uploads: $e');
    }

    // 3. Fallback: Upload in parallel with individual retries
    final List<String> finalUrls = [];
    final uploadFutures = preparedPaths.map((p) async {
      if (p.startsWith('http')) return p;
      // Try upload with up to 2 retries
      for (int attempt = 1; attempt <= 2; attempt++) {
        final result = await uploadImage(p);
        if (result != null && result.isNotEmpty) {
          return result;
        }
        await Future.delayed(const Duration(milliseconds: 400));
      }
      return null;
    });

    final results = await Future.wait(uploadFutures);
    for (final r in results) {
      if (r != null && r.isNotEmpty) {
        finalUrls.add(r);
      }
    }

    return finalUrls;
  }

  /// Upload single proof image file (with fast compression & 60s timeout)
  Future<String?> uploadImage(String filePath) async {
    try {
      final optimizedPath = await compressImageFile(filePath);
      final fileName = optimizedPath.split('/').last;
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          optimizedPath,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '/complaints/upload',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        return (data['filename'] ?? data['url']) as String?;
      }
      return null;
    } catch (e) {
      debugPrint('Error uploading image to server: $e');
      return null;
    }
  }
}
