import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/app_permission_service.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../../core/services/system_setting_service.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/maintenance_screen.dart';
import '../../../../core/widgets/update_required_screen.dart';
import '../../../shell/presentation/screens/main_shell_screen.dart';
import '../../../onboarding/presentation/screens/onboarding_screen.dart';
import '../../../track/presentation/screens/track_status_details_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // Prompt user for initial permissions on app launch
    AppPermissionService.instance.requestInitialPermissionsOnLaunch();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.65, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.95, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    // Check Maintenance Mode & Navigate after splash animation
    Timer(const Duration(milliseconds: 3000), () async {
      if (mounted) {
        final sysSettings = await SystemSettingService().getSettings(forceRefresh: true);
        if (!mounted) return;

        // 1. Check Maintenance Mode
        if (sysSettings.maintenanceMode) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MaintenanceScreen(settings: sysSettings),
            ),
          );
          return;
        }

        final lang = SessionService.instance.savedLanguage;
        final isTamil = lang == 'ta';

        // 2. Check Force App Update Requirement
        const String installedVersion = '1.0.0';
        if (sysSettings.shouldForceUpdate(installedVersion)) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => UpdateRequiredScreen(
                settings: sysSettings,
                currentVersion: installedVersion,
                isTamil: isTamil,
              ),
            ),
          );
          return;
        }

        // Check if app was opened via notification click
        final pendingRefId = PushNotificationService.pendingReferenceId;
        final pendingStatus = PushNotificationService.pendingStatus;
        PushNotificationService.pendingReferenceId = null;
        PushNotificationService.pendingStatus = null;

        if (SessionService.instance.isLoggedIn) {
          // Sync device FCM push token with backend
          PushNotificationService.instance.syncTokenWithBackend();

          if (pendingRefId != null && pendingRefId.isNotEmpty) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => MainShellScreen(
                  selectedLanguage: lang,
                ),
              ),
            );
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TrackStatusDetailsScreen(
                  selectedLanguage: lang,
                  referenceId: pendingRefId,
                  status: pendingStatus ?? 'SUBMITTED',
                ),
              ),
            );
            return;
          }

          // Directly go to MainShellScreen!
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MainShellScreen(
                selectedLanguage: lang,
              ),
            ),
          );
        } else {
          if (pendingRefId != null && pendingRefId.isNotEmpty) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => TrackStatusDetailsScreen(
                  selectedLanguage: lang,
                  referenceId: pendingRefId,
                  status: pendingStatus ?? 'SUBMITTED',
                ),
              ),
            );
            return;
          }

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const OnboardingScreen(),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);

    return Scaffold(
      backgroundColor: const Color(0xFF7A0000),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8C0000),
              Color(0xFF7A0000),
              Color(0xFF680000),
              Color(0xFF4E0000),
            ],
            stops: [0.0, 0.35, 0.70, 1.0],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // 1. Top Header (Tamil 'தமிழக வெற்றிக் கழகம்' in Yellow Gold + Subtitles)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'தமிழக வெற்றிக் கழகம்',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.goldAccent,
                                fontSize: isTablet ? 32 : 23,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'G R I E V A N C E   P O R T A L',
                            style: TextStyle(
                              color: AppColors.white.withValues(alpha: 0.95),
                              fontSize: isTablet ? 14 : 11.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'கள்ளக்குறிச்சி சட்டமன்ற தொகுதி',
                            style: TextStyle(
                              color: AppColors.goldLight.withValues(alpha: 0.9),
                              fontSize: isTablet ? 13 : 10.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // 2. Center Hero Image (Slightly larger scale with soft bottom feathered blend)
                      Expanded(
                        child: Center(
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Soft Ambient Warm Glow Aura Behind Leaders
                                Container(
                                  width: isTablet ? 360 : 280,
                                  height: isTablet ? 360 : 280,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        AppColors.goldAccent.withValues(alpha: 0.22),
                                        const Color(0xFFA00000).withValues(alpha: 0.15),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.0, 0.55, 1.0],
                                    ),
                                  ),
                                ),

                                // Leader Cutout with Feathered Bottom Vignette (No glitch, seamless blend)
                                Transform.scale(
                                  scale: 1.06,
                                  child: ShaderMask(
                                    shaderCallback: (Rect rect) {
                                      return const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black, // Fully visible at top & faces
                                          Colors.black, // Fully visible through torso & bouquet
                                          Color(0xCC000000), // Smooth soft fade starts below bouquet
                                          Color(0x44000000), // Feathered transparent blend
                                          Colors.transparent, // 100% invisible before bottom edge
                                        ],
                                        stops: [0.0, 0.48, 0.68, 0.84, 0.96],
                                      ).createShader(rect);
                                    },
                                    blendMode: BlendMode.dstIn,
                                    child: Image.asset(
                                      'assets/images/splash_leaders.png',
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Image.asset(
                                          'assets/images/tvk_logo.png',
                                          height: 180,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 3. Bottom Progress Bar & Motto Section
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 80 : 30,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Custom Golden Shimmer Progress Bar
                            Container(
                              height: 3.5,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFF380000),
                                borderRadius: BorderRadius.circular(2),
                                border: Border.all(
                                  color: AppColors.goldAccent.withValues(alpha: 0.25),
                                  width: 0.5,
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: _progressAnimation.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.goldAccent,
                                          AppColors.goldLight,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.goldAccent.withValues(alpha: 0.7),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Tamil Motto
                            Text(
                              'பிறப்பொக்கும் எல்லா உயிர்க்கும்',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.goldAccent,
                                fontSize: isTablet ? 14 : 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 3),

                            // Subtitle Footer Text
                            Text(
                              'E M P O W E R I N G   K A L L A K U R I C H I',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.white.withValues(alpha: 0.7),
                                fontSize: isTablet ? 11 : 9.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.8,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
