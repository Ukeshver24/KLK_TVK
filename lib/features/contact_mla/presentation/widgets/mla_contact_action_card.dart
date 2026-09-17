import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class MlaContactActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final bool showExternalIcon;
  final VoidCallback? onTap;

  const MlaContactActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    this.showExternalIcon = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF800000),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF800000).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Circle Box
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.goldAccent,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Card Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: AppColors.goldAccent.withValues(alpha: 0.85),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                            ),
                          ),
                          if (showExternalIcon)
                            Icon(
                              Icons.north_east_rounded,
                              color: AppColors.goldAccent.withValues(alpha: 0.85),
                              size: 16,
                            ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        content,
                        style: const TextStyle(
                          color: AppColors.goldAccent,
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
