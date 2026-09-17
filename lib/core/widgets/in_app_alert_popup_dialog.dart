import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/broadcast_api_service.dart';

class InAppAlertPopupDialog extends StatelessWidget {
  final BroadcastAlertModel alert;
  final VoidCallback onDismiss;

  const InAppAlertPopupDialog({
    super.key,
    required this.alert,
    required this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required BroadcastAlertModel alert,
    required VoidCallback onDismiss,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.82),
      builder: (context) => InAppAlertPopupDialog(
        alert: alert,
        onDismiss: () {
          Navigator.of(context).pop();
          onDismiss();
        },
      ),
    );
  }

  // Visual Theme mapping based on Alert Severity
  _AlertTheme _getTheme(String severity) {
    switch (severity.toUpperCase()) {
      case 'EMERGENCY':
        return _AlertTheme(
          gradient: const LinearGradient(
            colors: [Color(0xFF5A0000), Color(0xFF8B0000), Color(0xFF4A0000)],
          ),
          borderColor: const Color(0xFFE53935),
          badgeColor: const Color(0xFFD32F2F),
          icon: Icons.warning_amber_rounded,
          badgeText: 'அவசர எச்சரிக்கை',
          buttonColor: const Color(0xFFB71C1C),
        );
      case 'ANNOUNCEMENT':
        return _AlertTheme(
          gradient: const LinearGradient(
            colors: [Color(0xFF5A3000), Color(0xFF8B5A00), Color(0xFF3E2000)],
          ),
          borderColor: const Color(0xFFFFB300),
          badgeColor: AppColors.goldAccent,
          icon: Icons.campaign_rounded,
          badgeText: 'முக்கிய மக்கள் நல அறிவிப்பு',
          buttonColor: const Color(0xFFE65100),
        );
      case 'WEATHER':
        return _AlertTheme(
          gradient: const LinearGradient(
            colors: [Color(0xFF003366), Color(0xFF00509E), Color(0xFF001F3F)],
          ),
          borderColor: const Color(0xFF00BCD4),
          badgeColor: const Color(0xFF00ACC1),
          icon: Icons.cloudy_snowing,
          badgeText: 'வானிலை & மழை எச்சரிக்கை',
          buttonColor: const Color(0xFF01579B),
        );
      case 'EVENT':
      default:
        return _AlertTheme(
          gradient: const LinearGradient(
            colors: [Color(0xFF004D40), Color(0xFF00796B), Color(0xFF00251A)],
          ),
          borderColor: const Color(0xFF00E676),
          badgeColor: const Color(0xFF00C853),
          icon: Icons.calendar_month_rounded,
          badgeText: 'குறைதீர்ப்பு முகாம் / நிகழ்வு',
          buttonColor: const Color(0xFF00695C),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _getTheme(alert.severity);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 24.0),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 380),
        decoration: BoxDecoration(
          color: const Color(0xFF1E0000),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: theme.borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: theme.borderColor.withValues(alpha: 0.35),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔴 Header Ribbon with Severity Theme & Subtitle
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: theme.gradient,
                  border: Border(
                    bottom: BorderSide(color: theme.borderColor.withValues(alpha: 0.5), width: 1.5),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(theme.icon, color: AppColors.goldAccent, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              theme.badgeText,
                              style: const TextStyle(
                                color: AppColors.goldAccent,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          alert.authorTag.isNotEmpty ? alert.authorTag : 'From the Desk of MLA',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),

                    // Close (✕) Button
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: onDismiss,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 📝 Modal Content Body
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Optional High-Res Poster Image
                    if (alert.imageUrl != null && alert.imageUrl!.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                          ),
                          child: Image.network(
                            alert.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.white38,
                                  size: 32,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Alert Headline Title in TVK Gold / Yellow
                    Text(
                      alert.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.goldAccent,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Scrollable Advisory Message Text
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 180),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          alert.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                            height: 1.55,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 🔘 Bilingual Action / Dismiss Button
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: onDismiss,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.buttonColor,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: AppColors.goldAccent, width: 1),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline_rounded, color: AppColors.goldAccent, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'புரிந்தது / Dismiss',
                              style: TextStyle(
                                color: AppColors.goldAccent,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertTheme {
  final Gradient gradient;
  final Color borderColor;
  final Color badgeColor;
  final IconData icon;
  final String badgeText;
  final Color buttonColor;

  _AlertTheme({
    required this.gradient,
    required this.borderColor,
    required this.badgeColor,
    required this.icon,
    required this.badgeText,
    required this.buttonColor,
  });
}
