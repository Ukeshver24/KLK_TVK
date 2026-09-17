import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileLanguageTile extends StatelessWidget {
  final bool isTamil;
  final String currentLanguage;
  final Function(String) onLanguageChanged;

  const ProfileLanguageTile({
    super.key,
    required this.isTamil,
    required this.currentLanguage,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isTamilActive = currentLanguage == 'ta';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F3F3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.translate_rounded,
                  color: Color(0xFF6B0000),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isTamil ? 'செயலி மொழி' : 'App Language',
                style: const TextStyle(
                  color: Color(0xFF2C0000),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Language Selector Pills (English & தமிழ்)
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onLanguageChanged('en'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: !isTamilActive
                          ? const Color(0xFF750000)
                          : const Color(0xFFF3EEEE),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: !isTamilActive
                            ? AppColors.goldAccent
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isTamilActive) ...[
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.goldAccent,
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          'English',
                          style: TextStyle(
                            color: !isTamilActive
                                ? AppColors.goldAccent
                                : const Color(0xFF505050),
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: GestureDetector(
                  onTap: () => onLanguageChanged('ta'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isTamilActive
                          ? const Color(0xFF750000)
                          : const Color(0xFFF3EEEE),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isTamilActive
                            ? AppColors.goldAccent
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isTamilActive) ...[
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.goldAccent,
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          'தமிழ்',
                          style: TextStyle(
                            color: isTamilActive
                                ? AppColors.goldAccent
                                : const Color(0xFF505050),
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
