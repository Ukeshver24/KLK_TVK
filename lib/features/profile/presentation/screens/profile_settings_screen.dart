import 'package:flutter/material.dart';
import 'package:tvk_application/core/widgets/app_toast.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../../../auth/data/auth_api_service.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../widgets/profile_language_tile.dart';
import 'edit_profile_screen.dart';
import 'faq_support_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

class ProfileSettingsScreen extends StatefulWidget {
  final String selectedLanguage;
  final Function(String)? onLanguageChanged;
  final bool isNestedInShell;

  const ProfileSettingsScreen({
    super.key,
    required this.selectedLanguage,
    this.onLanguageChanged,
    this.isNestedInShell = false,
  });

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  late String _currentLanguage;
  bool _notificationsEnabled = true;
  final int _currentBottomIndex = 4;
  final AuthApiService _authService = AuthApiService();
  bool _isDeletingAccount = false;

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.selectedLanguage;
  }

  @override
  void didUpdateWidget(covariant ProfileSettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedLanguage != widget.selectedLanguage) {
      setState(() {
        _currentLanguage = widget.selectedLanguage;
      });
    }
  }

  void _changeLanguage(String newLang) {
    if (_currentLanguage != newLang) {
      setState(() {
        _currentLanguage = newLang;
      });
      SessionService.instance.saveLanguage(newLang);
      if (widget.onLanguageChanged != null) {
        widget.onLanguageChanged!(newLang);
      }
    }
  }

  void _showLogoutConfirmationDialog(bool isTamil) {
    AppDialog.showConfirmation(
      context,
      title: isTamil
          ? 'நிச்சயமாக வெளியேற விரும்புகிறீர்களா?'
          : 'Are you sure you want to logout?',
      message: isTamil
          ? 'வெளியேறிய பிறகு புதிய புகார் பதிவு செய்ய மீண்டும் லாகின் செய்ய வேண்டும்.'
          : 'You will need to login again to register new complaints or track petitions.',
      confirmText: isTamil ? 'வெளியேறு' : 'Logout',
      cancelText: isTamil ? 'ரத்து' : 'Cancel',
      confirmColor: const Color(0xFFD32F2F),
      icon: Icons.logout_rounded,
      onConfirm: () async {
        await SessionService.instance.clearSession();
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) =>
                LoginScreen(selectedLanguage: _currentLanguage),
          ),
          (route) => false,
        );
      },
    );
  }

  void _showDeleteAccountConfirmationDialog(bool isTamil) {
    AppDialog.showConfirmation(
      context,
      title: isTamil
          ? 'கணக்கை நிரந்தரமாக நீக்கவா?'
          : 'Delete your account permanently?',
      message: isTamil
          ? 'உங்கள் கணக்கு, புகார்கள் மற்றும் தொடர்புடைய கோப்புகள் நிரந்தரமாக நீக்கப்படும். இந்த செயலை மீண்டும் மாற்ற முடியாது.'
          : 'Your account, complaints, and related files will be permanently deleted. This action cannot be undone.',
      confirmText: isTamil ? 'நிரந்தரமாக நீக்கு' : 'Delete Account',
      cancelText: isTamil ? 'ரத்து' : 'Cancel',
      confirmColor: const Color(0xFFD32F2F),
      icon: Icons.delete_forever_rounded,
      onConfirm: () async {
        await _deleteAccount();
      },
    );
  }

  Future<void> _deleteAccount() async {
    if (_isDeletingAccount) return;

    setState(() {
      _isDeletingAccount = true;
    });

    try {
      final result = await _authService.deleteAccount();

      if (!mounted) return;

      if (result.isSuccess) {
        AppToast.showSuccess(context, result.message);

        await SessionService.instance.clearSession();

        if (!mounted) return;

        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) =>
                LoginScreen(selectedLanguage: _currentLanguage),
          ),
          (route) => false,
        );
      } else {
        AppToast.showError(context, result.message);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeletingAccount = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTamil = _currentLanguage == 'ta';
    final isTablet = Responsive.isTablet(context);
    final size = MediaQuery.of(context).size;

    final userName = SessionService.instance.userName;
    final userCode = SessionService.instance.userCode;
    final mobile = SessionService.instance.mobile;
    final dob = SessionService.instance.dob;
    final address = SessionService.instance.address;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F6),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            // Top Section (Deep Maroon Top Header + User Card)
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // Deep Maroon Header Banner
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: const BoxDecoration(
                    color: Color(0xFF800000),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          isTamil ? 'சுயவிவரம்' : 'Profile & Settings',
                          style: TextStyle(
                            color: AppColors.goldAccent,
                            fontSize: 22,
                            fontWeight: isTamil
                                ? FontWeight.w700
                                : FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // User Info Floating Card
                Padding(
                  padding: EdgeInsets.only(
                    top: 100,
                    left: isTablet ? size.width * 0.15 : 20,
                    right: isTablet ? size.width * 0.15 : 20,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          userName.isNotEmpty
                              ? userName
                              : (isTamil ? 'குடிமகன்' : 'Citizen'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF6B0000),
                            fontSize: 20,
                            fontWeight: isTamil
                                ? FontWeight.w700
                                : FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mobile.isNotEmpty
                              ? '+91 $mobile'
                              : (isTamil
                                    ? 'கைபேசி எண் சேர்க்கப்படவில்லை'
                                    : 'Mobile number not set'),
                          style: const TextStyle(
                            color: Color(0xFF6E6E6E),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 14),
                        // EDIT Pill Button
                        InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder: (context) => EditProfileScreen(
                                      selectedLanguage: _currentLanguage,
                                      initialMobile: mobile,
                                      initialAddress: address,
                                    ),
                                  ),
                                )
                                .then((_) {
                                  setState(() {});
                                });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFDF5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.goldAccent,
                                width: 1.2,
                              ),
                            ),
                            child: Text(
                              isTamil ? 'திருத்து' : 'EDIT',
                              style: const TextStyle(
                                color: Color(0xFF6B0000),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Citizen Info Details Grid (DOB, User ID, Address)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? size.width * 0.15 : 20,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEBE5E5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Row 1: User ID & DOB
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoTile(
                            icon: Icons.fingerprint_rounded,
                            label: isTamil ? 'பயனர் எண்' : 'USER ID',
                            value: userCode.isNotEmpty
                                ? userCode
                                : 'TVK-C-0001',
                            isGold: true,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: const Color(0xFFF0E6E6),
                        ),
                        Expanded(
                          child: _buildInfoTile(
                            icon: Icons.calendar_today_rounded,
                            label: isTamil ? 'பிறந்த தேதி' : 'DATE OF BIRTH',
                            value: dob.isNotEmpty ? dob : '—',
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: Color(0xFFF0E6E6)),
                    // Row 2: Address
                    _buildInfoTile(
                      icon: Icons.location_on_outlined,
                      label: isTamil
                          ? 'குடியிருப்பு முகவரி'
                          : 'RESIDENTIAL ADDRESS',
                      value: address.isNotEmpty
                          ? address
                          : (isTamil
                                ? 'முகவரி குறிப்பிடப்படவில்லை'
                                : 'Address not specified'),
                      isFullWidth: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Content Section Padding
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? size.width * 0.15 : 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SETTINGS HEADER
                  Text(
                    isTamil ? 'அமைப்புகள்' : 'SETTINGS',
                    style: const TextStyle(
                      color: Color(0xFF6E6E6E),
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Settings Card Container
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFEBE5E5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(22),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          // Language Tile
                          ProfileLanguageTile(
                            isTamil: isTamil,
                            currentLanguage: _currentLanguage,
                            onLanguageChanged: _changeLanguage,
                          ),

                          const Divider(height: 1, color: Color(0xFFF0E6E6)),

                          // Push Notifications Switch Tile
                          ListTile(
                            leading: Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF8F3F3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.notifications_none_rounded,
                                color: Color(0xFF6B0000),
                                size: 20,
                              ),
                            ),
                            title: Text(
                              isTamil ? 'அறிவிப்புகள்' : 'Notifications',
                              style: const TextStyle(
                                color: Color(0xFF2C0000),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: Switch(
                              value: _notificationsEnabled,
                              activeThumbColor: AppColors.goldAccent,
                              activeTrackColor: const Color(0xFF750000),
                              onChanged: (val) {
                                setState(() {
                                  _notificationsEnabled = val;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ABOUT APP HEADER
                  Text(
                    isTamil ? 'செயலி பற்றி' : 'ABOUT APP',
                    style: const TextStyle(
                      color: Color(0xFF6E6E6E),
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // About App Card Container
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFEBE5E5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(22),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          // FAQ & Support
                          ListTile(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => FaqSupportScreen(
                                    selectedLanguage: _currentLanguage,
                                  ),
                                ),
                              );
                            },
                            leading: Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF8F3F3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.help_outline_rounded,
                                color: Color(0xFF6B0000),
                                size: 20,
                              ),
                            ),
                            title: Text(
                              isTamil
                                  ? 'அடிக்கடி கேட்கப்படும் கேள்விகள் (FAQ)'
                                  : 'FAQ & Support',
                              style: const TextStyle(
                                color: Color(0xFF2C0000),
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFFA09090),
                            ),
                          ),

                          const Divider(height: 1, color: Color(0xFFF5EEEE)),

                          // Privacy Policy
                          ListTile(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => PrivacyPolicyScreen(
                                    selectedLanguage: _currentLanguage,
                                  ),
                                ),
                              );
                            },
                            leading: Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF8F3F3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.security_rounded,
                                color: Color(0xFF6B0000),
                                size: 20,
                              ),
                            ),
                            title: Text(
                              isTamil ? 'தனியுரிமைக் கொள்கை' : 'Privacy Policy',
                              style: const TextStyle(
                                color: Color(0xFF2C0000),
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFFA09090),
                            ),
                          ),

                          const Divider(height: 1, color: Color(0xFFF0E6E6)),

                          // Terms of Service
                          ListTile(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => TermsOfServiceScreen(
                                    selectedLanguage: _currentLanguage,
                                  ),
                                ),
                              );
                            },
                            leading: Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF8F3F3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.description_outlined,
                                color: Color(0xFF6B0000),
                                size: 20,
                              ),
                            ),
                            title: Text(
                              isTamil ? 'சேவை விதிகள்' : 'Terms of Service',
                              style: const TextStyle(
                                color: Color(0xFF2C0000),
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFFA09090),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 🗑️ DELETE ACCOUNT BUTTON CONTAINER
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F0),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: const Color(0xFFFFD6D6),
                        width: 1.2,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(22),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        onTap: _isDeletingAccount
                            ? null
                            : () =>
                                  _showDeleteAccountConfirmationDialog(isTamil),
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.delete_forever_rounded,
                            color: Color(0xFFD32F2F),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          isTamil ? 'கணக்கை நீக்கு' : 'Delete Account',
                          style: const TextStyle(
                            color: Color(0xFFD32F2F),
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Color(0xFFD32F2F),
                          size: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 🚪 LOGOUT BUTTON CONTAINER
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F0),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: const Color(0xFFFFD6D6),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD32F2F)
                              .withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(22),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        onTap: () => _showLogoutConfirmationDialog(isTamil),
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            color: Color(0xFFD32F2F),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          isTamil ? 'வெளியேறு' : 'Logout',
                          style: const TextStyle(
                            color: Color(0xFFD32F2F),
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Color(0xFFD32F2F),
                          size: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: widget.isNestedInShell
          ? null
          : CustomBottomNavBar(
              currentIndex: _currentBottomIndex,
              selectedLanguage: _currentLanguage,
            ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    bool isGold = false,
    bool isFullWidth = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        crossAxisAlignment: isFullWidth
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF7F7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF0E6E6)),
            ),
            child: Icon(icon, color: const Color(0xFF750000), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8A7A7A),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: isGold
                        ? const Color(0xFF750000)
                        : const Color(0xFF2C0000),
                    fontFamily: isGold ? 'monospace' : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
