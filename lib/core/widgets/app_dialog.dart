import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../../features/auth/presentation/screens/login_screen.dart';

/// Single standard Modal Dialog / Popup component for the entire application.
/// Replaces all duplicated inline dialogs across screens to ensure uniform UI,
/// hardware-accelerated animations, and zero code duplication.
class AppDialog {
  /// Show Standard Login Required Dialog
  static void showLoginRequired(
    BuildContext context, {
    required String selectedLanguage,
  }) {
    final lang = selectedLanguage.trim().toLowerCase();
    final isTamil = lang == 'ta' || lang == 'tamil';

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'AppLoginRequiredDialog',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curve,
          child: FadeTransition(
            opacity: anim1,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 16,
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(22.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF8C0000), Color(0xFF500000)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.goldAccent,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isTamil ? 'உள்நுழைவு தேவை' : 'Login Required',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2C0000),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isTamil
                          ? 'இந்தச் சேவையைப் பயன்படுத்த உங்கள் கணக்கில் உள்நுழையவும்.'
                          : 'Please log in to your account to access this feature.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6E6E6E),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: Color(0xFFD4C5C5)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              isTamil ? 'ரத்து' : 'Cancel',
                              style: const TextStyle(
                                color: Color(0xFF6E6E6E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(
                                    selectedLanguage: selectedLanguage,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF750000),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              isTamil ? 'உள்நுழைக' : 'Login',
                              style: const TextStyle(
                                color: AppColors.goldAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Show Standard Confirmation Dialog (e.g. Logout, Delete)
  static void showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    required String cancelText,
    required VoidCallback onConfirm,
    Color confirmColor = const Color(0xFF750000),
    IconData icon = Icons.help_outline_rounded,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'AppConfirmationDialog',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curve,
          child: FadeTransition(
            opacity: anim1,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 16,
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(22.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: confirmColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: confirmColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2C0000),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6E6E6E),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: Color(0xFFD4C5C5)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              cancelText,
                              style: const TextStyle(
                                color: Color(0xFF6E6E6E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true).pop();
                              onConfirm();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: confirmColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              confirmText,
                              style: const TextStyle(
                                color: AppColors.goldAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
