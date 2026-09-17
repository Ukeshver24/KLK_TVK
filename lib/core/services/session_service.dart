import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel {
  final String id;
  final String userCode;
  final String fullName;
  final String mobile;
  final String? dob;
  final String? address;
  final String role;
  final String? status;
  final String? token;

  UserModel({
    required this.id,
    required this.userCode,
    required this.fullName,
    required this.mobile,
    this.dob,
    this.address,
    this.role = 'CITIZEN',
    this.status = 'ACTIVE',
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    return UserModel(
      id: json['id'] ?? '',
      userCode: json['userCode'] ?? json['id'] ?? 'TVK-C-0001',
      fullName: json['fullName'] ?? '',
      mobile: json['mobile'] ?? '',
      dob: json['dob'],
      address: json['address'],
      role: json['role'] ?? 'CITIZEN',
      status: json['status'] ?? 'ACTIVE',
      token: token ?? json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userCode': userCode,
      'fullName': fullName,
      'mobile': mobile,
      'dob': dob,
      'address': address,
      'role': role,
      'status': status,
      if (token != null) 'token': token,
    };
  }
}

class SessionService extends ChangeNotifier {
  static final SessionService instance = SessionService._internal();
  factory SessionService() => instance;
  SessionService._internal();

  UserModel? _currentUser;
  String? _token;
  String _savedLanguage = 'en'; // Default language is English

  UserModel? get currentUser => _currentUser;
  String? get token => _token ?? _currentUser?.token;
  bool get isLoggedIn => _currentUser != null && _currentUser!.id.isNotEmpty;
  String get userId => _currentUser?.id ?? '';
  String get userName => _currentUser?.fullName ?? '';
  String get userCode => _currentUser?.userCode ?? '';
  String get mobile => _currentUser?.mobile ?? '';
  String get dob => _currentUser?.dob ?? '';
  String get address => _currentUser?.address ?? '';
  String get savedLanguage => _savedLanguage;

  static const String _userKey = 'tvk_logged_in_user';
  static const String _tokenKey = 'tvk_auth_jwt_token';
  static const String _langKey = 'tvk_selected_language';

  /// Save logged in user & JWT token into Memory & SharedPreferences
  Future<void> saveUser(Map<String, dynamic> userData, {String? token}) async {
    final extractedToken = token ?? userData['token'] as String?;
    if (extractedToken != null && extractedToken.isNotEmpty) {
      _token = extractedToken;
    }
    _currentUser = UserModel.fromJson(userData, token: _token);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));
      if (_token != null && _token!.isNotEmpty) {
        await prefs.setString(_tokenKey, _token!);
      }
    } catch (e) {
      // Fallback in case of storage issues
    }
    notifyListeners();
  }

  /// Save selected language in Memory & SharedPreferences
  Future<void> saveLanguage(String lang) async {
    final cleanLang = lang.trim().toLowerCase() == 'ta' ? 'ta' : 'en';
    _savedLanguage = cleanLang;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_langKey, cleanLang);
    } catch (_) {}
    notifyListeners();
  }

  /// Update in-memory and persisted profile fields
  Future<void> updateProfile({
    String? fullName,
    String? mobile,
    String? dob,
    String? address,
  }) async {
    if (_currentUser == null) return;
    _currentUser = UserModel(
      id: _currentUser!.id,
      userCode: _currentUser!.userCode,
      fullName: fullName ?? _currentUser!.fullName,
      mobile: mobile ?? _currentUser!.mobile,
      dob: dob ?? _currentUser!.dob,
      address: address ?? _currentUser!.address,
      role: _currentUser!.role,
      status: _currentUser!.status,
      token: _token ?? _currentUser!.token,
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));
    } catch (_) {}
    notifyListeners();
  }

  /// Load session from SharedPreferences on app startup
  Future<void> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_tokenKey);

      final userString = prefs.getString(_userKey);
      if (userString != null && userString.isNotEmpty) {
        final Map<String, dynamic> json = jsonDecode(userString);
        _currentUser = UserModel.fromJson(json, token: _token);
      }
      final lang = prefs.getString(_langKey);
      if (lang != null && lang.isNotEmpty) {
        _savedLanguage = lang.trim().toLowerCase() == 'ta' ? 'ta' : 'en';
      } else {
        _savedLanguage = 'en';
      }
    } catch (_) {}
    notifyListeners();
  }

  /// Logout and clear session
  Future<void> clearSession() async {
    _currentUser = null;
    _token = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_tokenKey);
    } catch (_) {}
    notifyListeners();
  }
}
