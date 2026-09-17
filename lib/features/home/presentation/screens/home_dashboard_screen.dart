import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/services/broadcast_api_service.dart';
import '../../../../core/widgets/in_app_alert_popup_dialog.dart';
import '../../../../core/services/system_setting_service.dart';
import '../../../../core/widgets/maintenance_screen.dart';
import '../../../../core/widgets/update_required_screen.dart';
import '../../../contact_mla/presentation/screens/contact_mla_screen.dart';
import '../../../shell/presentation/providers/navigation_provider.dart';
import '../../data/banner_api_service.dart';
import '../widgets/banner_slider_widget.dart';
import '../widgets/home_header_widget.dart';
import '../widgets/quick_action_card_widget.dart';
import '../widgets/recent_updates_widget.dart';

class HomeDashboardScreen extends StatefulWidget {
  final String selectedLanguage;
  final bool isLoggedIn;
  final bool isNestedInShell;

  const HomeDashboardScreen({
    super.key,
    this.selectedLanguage = 'ta',
    this.isLoggedIn = false,
    this.isNestedInShell = false,
  });

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  final int _currentBottomIndex = 0;
  bool _isLoading = true;
  final BannerApiService _bannerApiService = BannerApiService();
  final SystemSettingService _systemService = SystemSettingService();
  final BroadcastApiService _broadcastService = BroadcastApiService();

  // Active banner images list
  List<String> _bannerAssets = BannerApiService.defaultFallbackBanners;
  int _currentBannerIndex = 1000;
  Timer? _bannerTimer;
  late PageController _bannerController;

  @override
  void initState() {
    super.initState();
    _bannerController = PageController(initialPage: _currentBannerIndex);
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    // 1. Check Maintenance Mode with forceRefresh to detect Admin toggle immediately
    final sysSettings = await _systemService.getSettings(forceRefresh: true);
    if (mounted && sysSettings.maintenanceMode) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MaintenanceScreen(settings: sysSettings),
        ),
      );
      return;
    }

    // 2. Check Force App Update Requirement
    const String installedVersion = '1.0.0';
    if (mounted && sysSettings.shouldForceUpdate(installedVersion)) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => UpdateRequiredScreen(
            settings: sysSettings,
            currentVersion: installedVersion,
            isTamil: widget.selectedLanguage == 'ta',
          ),
        ),
      );
      return;
    }

    final liveBanners = await _bannerApiService.getLiveBanners();
    if (mounted) {
      setState(() {
        if (liveBanners.isNotEmpty) {
          _bannerAssets = liveBanners;
        }
        _isLoading = false;
      });
      _startAutoBannerScroll();
      _checkAndShowBroadcastAlert();
    }
  }

  Future<void> _checkAndShowBroadcastAlert() async {
    try {
      final alert = await _broadcastService.getActiveAlert();
      if (!mounted || alert == null || !alert.isActive) return;

      final prefs = await SharedPreferences.getInstance();
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final prefKey = 'last_seen_alert_date_${alert.id}_${alert.updatedAt}';

      if (alert.showFrequency == 'ONCE_PER_DAY') {
        final lastSeenDate = prefs.getString(prefKey);
        if (lastSeenDate == todayStr) {
          return;
        }
      }

      // Small delay so home dashboard renders smoothly first
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      InAppAlertPopupDialog.show(
        context,
        alert: alert,
        onDismiss: () async {
          if (alert.showFrequency == 'ONCE_PER_DAY') {
            await prefs.setString(prefKey, todayStr);
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error showing in-app broadcast alert: $e');
      }
    }
  }

  void _startAutoBannerScroll() {
    _bannerTimer?.cancel();
    if (_bannerAssets.length <= 1) return;

    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients && _bannerAssets.length > 1) {
        _currentBannerIndex++;
        _bannerController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _onPrevBanner() {
    if (_bannerAssets.length <= 1) return;
    if (_bannerController.hasClients) {
      _bannerTimer?.cancel();
      _currentBannerIndex--;
      _bannerController.animateToPage(
        _currentBannerIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
      _startAutoBannerScroll();
    }
  }

  void _onNextBanner() {
    if (_bannerAssets.length <= 1) return;
    if (_bannerController.hasClients) {
      _bannerTimer?.cancel();
      _currentBannerIndex++;
      _bannerController.animateToPage(
        _currentBannerIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
      _startAutoBannerScroll();
    }
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _checkAuthAndProceed(VoidCallback onAuthenticated) {
    final bool isUserLoggedIn =
        widget.isLoggedIn || SessionService.instance.isLoggedIn;
    if (isUserLoggedIn) {
      onAuthenticated();
    } else {
      AppDialog.showLoginRequired(
        context,
        selectedLanguage: widget.selectedLanguage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTamil = widget.selectedLanguage == 'ta';
    final isTablet = Responsive.isTablet(context);
    final size = MediaQuery.of(context).size;
    final bool isUserLoggedIn =
        widget.isLoggedIn || SessionService.instance.isLoggedIn;

    final bodyContent = Scaffold(
      backgroundColor: const Color(0xFFF9F6F6),
      body: Column(
        children: [
          // 📌 FIXED STICKY TOP HEADER BAR (Compact & Slim Height)
          Container(
            width: double.infinity,
            color: const Color(0xFF8C0000),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? size.width * 0.15 : 20,
                  vertical: 6,
                ),
                child: HomeHeaderWidget(
                  isTamil: isTamil,
                  isLoggedIn: isUserLoggedIn,
                ),
              ),
            ),
          ),

          // 📜 SCROLLABLE BODY CONTENT WITH REFRESH INDICATOR
          Expanded(
            child: RefreshIndicator(
              color: AppColors.goldAccent,
              backgroundColor: const Color(0xFF500000),
              onRefresh: _loadBanners,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),
                child: Column(
                  children: [
                    // Royal Maroon Banner Background Extension
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF8C0000),
                            Color(0xFF6B0000),
                            Color(0xFF4A0000),
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(28),
                          bottomRight: Radius.circular(28),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: isTablet ? size.width * 0.15 : 20,
                          right: isTablet ? size.width * 0.15 : 20,
                          top: 6,
                          bottom: 12,
                        ),
                        child: Column(
                          children: [
                            // Banner Slider / Skeleton Loading Placeholder
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 400),
                              crossFadeState: _isLoading
                                  ? CrossFadeState.showFirst
                                  : CrossFadeState.showSecond,
                              firstChild: const SkeletonBannerPlaceholder(),
                              secondChild: BannerSliderWidget(
                                controller: _bannerController,
                                currentBannerIndex: _currentBannerIndex,
                                bannerAssets: _bannerAssets,
                                isTamil: isTamil,
                                onPrev: _onPrevBanner,
                                onNext: _onNextBanner,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentBannerIndex = index;
                                  });
                                },
                                isTablet: isTablet,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quick Actions & Recent Updates Content Padding
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? size.width * 0.15 : 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Quick Actions Modular Widget
                          QuickActionCardWidget(
                            isTamil: isTamil,
                            onRaiseComplaint: () {
                              _checkAuthAndProceed(() {
                                NavigationProvider? nav;
                                try {
                                  nav = Provider.of<NavigationProvider>(
                                      context,
                                      listen: false);
                                } catch (_) {
                                  nav = null;
                                }

                                if (nav != null) {
                                  nav.setIndex(1, context);
                                }
                              });
                            },
                            onTrackStatus: () {
                              _checkAuthAndProceed(() {
                                NavigationProvider? nav;
                                try {
                                  nav = Provider.of<NavigationProvider>(
                                      context,
                                      listen: false);
                                } catch (_) {
                                  nav = null;
                                }

                                if (nav != null) {
                                  nav.setIndex(2, context);
                                }
                              });
                            },
                            onContactMla: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ContactMlaScreen(
                                    selectedLanguage: widget.selectedLanguage,
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 28),

                          // Recent Updates / Grievances Modular Widget
                          RecentUpdatesWidget(isTamil: isTamil),

                          const SizedBox(height: 90),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.isNestedInShell
          ? null
          : CustomBottomNavBar(
              currentIndex: _currentBottomIndex,
              selectedLanguage: widget.selectedLanguage,
            ),
    );

    if (widget.isNestedInShell) {
      return bodyContent;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        SystemNavigator.pop();
      },
      child: bodyContent,
    );
  }
}
