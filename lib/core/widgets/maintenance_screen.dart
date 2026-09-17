import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/session_service.dart';
import '../services/system_setting_service.dart';
import '../../features/shell/presentation/screens/main_shell_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';

class MaintenanceScreen extends StatefulWidget {
  final SystemSettingModel settings;

  const MaintenanceScreen({super.key, required this.settings});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  final SystemSettingService _systemService = SystemSettingService();
  late SystemSettingModel _currentSettings;
  bool _isChecking = false;
  late String _activeLanguage;

  @override
  void initState() {
    super.initState();
    _currentSettings = widget.settings;
    _activeLanguage = SessionService.instance.savedLanguage;
    _fetchLatest();
  }

  // Fetch the latest text directly from Admin/DB on mount
  Future<void> _fetchLatest() async {
    final fresh = await _systemService.getSettings(forceRefresh: true);
    if (mounted) {
      setState(() {
        _currentSettings = fresh;
      });
    }
  }

  Future<void> _checkAgain() async {
    setState(() {
      _isChecking = true;
    });

    final fresh = await _systemService.getSettings(forceRefresh: true);

    if (!mounted) return;

    if (!fresh.maintenanceMode) {
      // Unlocked! Admin turned OFF maintenance mode
      final lang = SessionService.instance.savedLanguage;
      if (SessionService.instance.isLoggedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainShellScreen(
              selectedLanguage: lang,
            ),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const OnboardingScreen(),
          ),
        );
      }
    } else {
      setState(() {
        _currentSettings = fresh;
        _isChecking = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _activeLanguage == 'ta'
                ? 'சேவையக பராமரிப்பு பணிகள் தொடர்ந்து நடைபெறுகின்றன. சிறிது நேரம் கழித்து மீண்டும் முயற்சிக்கவும்.'
                : 'Server maintenance is still in progress. Please check again shortly.',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.goldAccent,
            ),
          ),
          backgroundColor: const Color(0xFF500000),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTamil = _activeLanguage == 'ta';

    // Live Title from Admin DB
    final title = isTamil
        ? (_currentSettings.maintenanceTitleTa.isNotEmpty
            ? _currentSettings.maintenanceTitleTa
            : 'பராமரிப்பு பணியில் உள்ளது')
        : (_currentSettings.maintenanceTitleEn.isNotEmpty
            ? _currentSettings.maintenanceTitleEn
            : 'Under Scheduled Maintenance');

    // Live Message from Admin DB
    final message = isTamil
        ? (_currentSettings.maintenanceMsgTa.isNotEmpty
            ? _currentSettings.maintenanceMsgTa
            : 'சேவையக மேம்பாட்டு பணிகள் நடைபெற்று வருகின்றன. செயலி விரைவில் மீண்டும் பயன்பாட்டுக்கு வரும்.')
        : (_currentSettings.maintenanceMsgEn.isNotEmpty
            ? _currentSettings.maintenanceMsgEn
            : 'We are currently upgrading our systems to serve you better. The app will be back online shortly.');

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF5A0000),
              Color(0xFF380000),
              Color(0xFF1E0000),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // 🔄 Top Left Instant Refresh Action
              Positioned(
                top: 12,
                left: 20,
                child: GestureDetector(
                  onTap: _isChecking ? null : _checkAgain,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.goldAccent.withValues(alpha: 0.4)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _isChecking
                            ? const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.goldAccent,
                                ),
                              )
                            : const Icon(Icons.refresh_rounded, color: AppColors.goldAccent, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          _activeLanguage == 'ta' ? 'புதுப்பி' : 'Refresh',
                          style: const TextStyle(
                            color: AppColors.goldAccent,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 🌐 Top Right Language Switcher Pill (Instant Tamil / English Preview)
              Positioned(
                top: 12,
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _activeLanguage = _activeLanguage == 'ta' ? 'en' : 'ta';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.goldAccent.withValues(alpha: 0.4)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.language_rounded, color: AppColors.goldAccent, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          _activeLanguage == 'ta' ? 'English' : 'தமிழ்',
                          style: const TextStyle(
                            color: AppColors.goldAccent,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 🎯 ENTIRE SECTION PERFECTLY VERTICALLY & HORIZONTALLY CENTERED WITH PULL-TO-REFRESH
              Positioned.fill(
                child: RefreshIndicator(
                  color: AppColors.goldAccent,
                  backgroundColor: const Color(0xFF500000),
                  onRefresh: _checkAgain,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),

                          // 🔴 TVK Emblem Header Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.goldAccent.withValues(alpha: 0.4)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.shield_rounded, color: AppColors.goldAccent, size: 15),
                                SizedBox(width: 6),
                                Text(
                                  'TVK COMMAND CENTER',
                                  style: TextStyle(
                                    color: AppColors.goldAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // 🛠️ Animated Wrench / Maintenance Glowing Icon Box
                          Container(
                            width: 115,
                            height: 115,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF700000),
                              border: Border.all(color: AppColors.goldAccent, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.goldAccent.withValues(alpha: 0.35),
                                  blurRadius: 28,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.build_circle_rounded,
                                color: AppColors.goldAccent,
                                size: 60,
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // 📢 Live Maintenance Title from Admin
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.goldAccent,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 📝 Live Maintenance Message Box from Admin
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: AppColors.goldAccent.withValues(alpha: 0.3)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.goldLight,
                                fontSize: 14,
                                height: 1.6,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ⏳ Sub-notice
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.timer_outlined, color: AppColors.goldAccent, size: 15),
                              const SizedBox(width: 6),
                              Text(
                                isTamil ? 'விரைவில் இயல்பு நிலைக்கு வரும்' : 'Will be back online shortly',
                                style: const TextStyle(
                                  color: AppColors.goldAccent,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 90), // Space for bottom button
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

              // 🔄 Bottom Check Again / Retry Button
              Positioned(
                left: 24,
                right: 24,
                bottom: 20,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isChecking ? null : _checkAgain,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF800000),
                      foregroundColor: AppColors.goldAccent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      side: const BorderSide(color: AppColors.goldAccent, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isChecking
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: AppColors.goldAccent,
                              strokeWidth: 2.5,
                            ),
                          )
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.refresh_rounded, color: AppColors.goldAccent, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  isTamil
                                      ? 'மீண்டும் சரிபார்க்கவும்'
                                      : 'Check Again',
                                  style: const TextStyle(
                                    color: AppColors.goldAccent,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
