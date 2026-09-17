import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';

class TalukModel {
  final String nameEn;
  final String nameTa;

  TalukModel({
    required this.nameEn,
    required this.nameTa,
  });

  factory TalukModel.fromJson(Map<String, dynamic> json) {
    final en = (json['nameEn'] ?? '').toString().trim();
    final ta = (json['nameTa'] ?? '').toString().trim();
    return TalukModel(
      nameEn: en.isNotEmpty ? en : ta,
      nameTa: ta.isNotEmpty ? ta : en,
    );
  }
}

class VillageModel {
  final String id;
  final String taluk;
  final String nameTa;
  final String nameEn;
  final String? pincode;
  final bool isActive;

  VillageModel({
    required this.id,
    required this.taluk,
    required this.nameTa,
    required this.nameEn,
    this.pincode,
    required this.isActive,
  });

  factory VillageModel.fromJson(Map<String, dynamic> json) {
    final en = (json['nameEn'] ?? '').toString().trim();
    final ta = (json['nameTa'] ?? '').toString().trim();

    return VillageModel(
      id: json['id'] ?? '',
      taluk: json['taluk'] ?? 'Kallakurichi',
      nameTa: ta.isNotEmpty ? ta : en,
      nameEn: en.isNotEmpty ? en : ta,
      pincode: json['pincode'],
      isActive: json['isActive'] ?? true,
    );
  }
}

class LocationApiService {
  final Dio _dio = ApiClient().dio;

  static List<TalukModel>? _cachedTaluks;
  static final Map<String, List<VillageModel>> _cachedVillagesMap = {};

  /// Fetch all distinct taluks from database (with in-memory caching)
  Future<List<TalukModel>> getTaluks({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedTaluks != null && _cachedTaluks!.isNotEmpty) {
      return _cachedTaluks!;
    }

    try {
      final response = await _dio.get('/locations/taluks');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List list = response.data['data'] ?? [];
        _cachedTaluks = list.map((item) => TalukModel.fromJson(item)).toList();
        return _cachedTaluks!;
      }
      return _cachedTaluks ?? [];
    } catch (e) {
      return _cachedTaluks ?? [];
    }
  }

  /// Fetch all active villages filtered by taluk from PostgreSQL database (with in-memory caching)
  Future<List<VillageModel>> getVillages({String? taluk, bool forceRefresh = false}) async {
    final key = taluk?.trim() ?? '__ALL__';
    if (!forceRefresh && _cachedVillagesMap.containsKey(key) && _cachedVillagesMap[key]!.isNotEmpty) {
      return _cachedVillagesMap[key]!;
    }

    try {
      final response = await _dio.get(
        '/locations/villages',
        queryParameters: (taluk != null && taluk.trim().isNotEmpty) ? {'taluk': taluk.trim()} : null,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List list = response.data['data'] ?? [];
        final villages = list.map((item) => VillageModel.fromJson(item)).toList();
        _cachedVillagesMap[key] = villages;
        return villages;
      }
      return _cachedVillagesMap[key] ?? [];
    } catch (e) {
      return _cachedVillagesMap[key] ?? [];
    }
  }
}
