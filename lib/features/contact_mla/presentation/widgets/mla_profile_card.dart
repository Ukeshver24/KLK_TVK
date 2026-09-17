import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class MlaProfileCard extends StatelessWidget {
  final bool isTamil;
  final String name;
  final String degree;
  final String designation;

  const MlaProfileCard({
    super.key,
    required this.isTamil,
    this.name = 'C. Arul Vignesh',
    this.degree = 'M.Sc.,',
    this.designation = 'MLA, KALLAKURICHI',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 85, bottom: 22, left: 18, right: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
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
          // MLA Name with degree suffix
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$name ',
                  style: TextStyle(
                    color: const Color(0xFF1E1E1E),
                    fontSize: isTamil ? 19 : 20,
                    fontWeight: isTamil ? FontWeight.w700 : FontWeight.w800,
                    letterSpacing: isTamil ? 0.1 : 0.2,
                  ),
                ),
                if (degree.isNotEmpty)
                  TextSpan(
                    text: degree,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Designation Star Badge Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF800000),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF800000).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: AppColors.goldAccent,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    designation,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.goldAccent,
                      fontSize: 11,
                      fontWeight: isTamil ? FontWeight.w700 : FontWeight.w800,
                      letterSpacing: isTamil ? 0.3 : 0.8,
                    ),
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
