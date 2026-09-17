import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';

class MlaContactModel {
  final String name;
  final String degree;
  final String designationEn;
  final String designationTa;
  final String addressEn;
  final String addressTa;
  final String phone;
  final String email;
  final String visitingHoursEn;
  final String visitingHoursTa;
  final String? photoUrl;
  final String fullPhotoUrl;

  MlaContactModel({
    required this.name,
    required this.degree,
    required this.designationEn,
    required this.designationTa,
    required this.addressEn,
    required this.addressTa,
    required this.phone,
    required this.email,
    required this.visitingHoursEn,
    required this.visitingHoursTa,
    this.photoUrl,
    required this.fullPhotoUrl,
  });

  factory MlaContactModel.fromJson(Map<String, dynamic> json) {
    String rawUrl = json['fullPhotoUrl'] ?? json['photoUrl'] ?? 'assets/images/mla_photo.jpg';
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

    return MlaContactModel(
      name: json['name']?.toString() ?? 'C. Arul Vignesh',
      degree: json['degree']?.toString() ?? 'M.Sc.,',
      designationEn: json['designationEn']?.toString() ?? 'MLA, KALLAKURICHI',
      designationTa: json['designationTa']?.toString() ?? 'சட்டப்பேரவை உறுப்பினர், கள்ளக்குறிச்சி',
      addressEn: json['addressEn']?.toString() ?? 'No 42, Main Road, Near Bus Stand, Kallakurichi, Tamil Nadu – 606202',
      addressTa: json['addressTa']?.toString() ?? 'எண் 42, பிரதான சாலை, பேருந்து நிலையம் அருகில், கள்ளக்குறிச்சி, தமிழ்நாடு – 606202',
      phone: json['phone']?.toString() ?? '+91 98765 43210',
      email: json['email']?.toString() ?? 'mla.kallakurichi@tvk.in',
      visitingHoursEn: json['visitingHoursEn']?.toString() ?? 'Monday - Saturday: 09:00 AM - 06:00 PM',
      visitingHoursTa: json['visitingHoursTa']?.toString() ?? 'திங்கள் - சனி: காலை 09:00 - மாலை 06:00',
      photoUrl: json['photoUrl']?.toString(),
      fullPhotoUrl: rawUrl,
    );
  }

  static MlaContactModel get defaultContact => MlaContactModel(
        name: 'C. Arul Vignesh',
        degree: 'M.Sc.,',
        designationEn: 'MLA, KALLAKURICHI',
        designationTa: 'சட்டப்பேரவை உறுப்பினர், கள்ளக்குறிச்சி',
        addressEn: 'No 42, Main Road, Near Bus Stand, Kallakurichi, Tamil Nadu – 606202',
        addressTa: 'எண் 42, பிரதான சாலை, பேருந்து நிலையம் அருகில், கள்ளக்குறிச்சி, தமிழ்நாடு – 606202',
        phone: '+91 98765 43210',
        email: 'mla.kallakurichi@tvk.in',
        visitingHoursEn: 'Monday - Saturday: 09:00 AM - 06:00 PM',
        visitingHoursTa: 'திங்கள் - சனி: காலை 09:00 - மாலை 06:00',
        photoUrl: 'assets/images/mla_photo.jpg',
        fullPhotoUrl: 'assets/images/mla_photo.jpg',
      );
}

class MlaContactApiService {
  final Dio _dio = ApiClient().dio;

  Future<MlaContactModel> getContact() async {
    try {
      final response = await _dio.get('/mla-contact');
      if (response.statusCode == 200 && response.data != null && response.data['data'] != null) {
        return MlaContactModel.fromJson(response.data['data']);
      }
    } catch (e) {
      if (kDebugMode) {
        print('MlaContactApiService Error fetching MLA contact: $e');
      }
    }
    return MlaContactModel.defaultContact;
  }
}
