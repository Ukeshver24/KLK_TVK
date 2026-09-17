import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class LanguageToggleWidget extends StatelessWidget {
  final String selectedLanguage;
  final Function(String) onLanguageSelected;

  const LanguageToggleWidget({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFF330000).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.goldAccent.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onLanguageSelected('en'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  color: selectedLanguage == 'en'
                      ? AppColors.goldAccent
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Center(
                  child: Text(
                    'English',
                    style: TextStyle(
                      color: selectedLanguage == 'en'
                          ? const Color(0xFF4A0000)
                          : AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onLanguageSelected('ta'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  color: selectedLanguage == 'ta'
                      ? AppColors.goldAccent
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Center(
                  child: Text(
                    'தமிழ்',
                    style: TextStyle(
                      color: selectedLanguage == 'ta'
                          ? const Color(0xFF4A0000)
                          : AppColors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
