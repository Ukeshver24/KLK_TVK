import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/system_setting_service.dart';

class UpdateRequiredScreen extends StatelessWidget {
  final SystemSettingModel settings;
  final String currentVersion;
  final bool isTamil;

  const UpdateRequiredScreen({
    super.key,
    required this.settings,
    this.currentVersion = '1.0.0',
    this.isTamil = false,
  });

  Future<void> _launchStore(BuildContext context) async {
    try {
      if (Platform.isAndroid) {
        // 1. Try launching native Google Play Store App directly
        final Uri marketUri = Uri.parse('market://details?id=com.gradixtvk.tvk_application');
        if (await canLaunchUrl(marketUri)) {
          await launchUrl(marketUri, mode: LaunchMode.externalApplication);
          return;
        }

        // 2. Fallback to HTTPS Google Play Store Web URL
        final Uri webUri = Uri.parse(settings.playStoreUrl);
        if (await canLaunchUrl(webUri)) {
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
          return;
        }
      } else if (Platform.isIOS) {
        // Apple App Store URL
        final Uri appStoreUri = Uri.parse(settings.appStoreUrl);
        if (await canLaunchUrl(appStoreUri)) {
          await launchUrl(appStoreUri, mode: LaunchMode.externalApplication);
          return;
        }
      } else {
        // Fallback for other platforms
        final Uri fallbackUri = Uri.parse(settings.playStoreUrl);
        if (await canLaunchUrl(fallbackUri)) {
          await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
          return;
        }
      }
    } catch (e) {
      debugPrint('Error launching store URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = isTamil ? settings.updateTitleTa : settings.updateTitleEn;
    final message = isTamil ? settings.updateMsgTa : settings.updateMsgEn;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              children: [
                const Spacer(flex: 3),

                // TVK App Logo Emblem
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/tvk_logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF8C0000),
                          child: const Center(
                            child: Text(
                              'TVK',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // "Update Required" Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF1E1E1E),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                  ),
                ),

                const SizedBox(height: 14),

                // Description Subtitle
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF6B6B6B),
                    fontSize: 14.5,
                    height: 1.5,
                    fontWeight: FontWeight.normal,
                  ),
                ),

                const SizedBox(height: 36),

                // "Update Now" Action Button (Maroon Brand Color)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => _launchStore(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB71C1C),
                      foregroundColor: Colors.white,
                      elevation: 6,
                      shadowColor: const Color(0xFFB71C1C).withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      isTamil ? 'இப்போதே புதுப்பிக்கவும்' : 'Update Now',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Current Installed Version Subtext
                Text(
                  'Current Version: $currentVersion',
                  style: const TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const Spacer(flex: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
