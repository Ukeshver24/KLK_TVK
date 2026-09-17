import 'package:flutter/material.dart';

class ComplaintHistoryCard extends StatelessWidget {
  final bool isTamil;
  final String referenceId;
  final String status;
  final String date;
  final VoidCallback onViewPressed;

  const ComplaintHistoryCard({
    super.key,
    required this.isTamil,
    required this.referenceId,
    required this.status,
    required this.date,
    required this.onViewPressed,
  });

  @override
  Widget build(BuildContext context) {
    Color stripColor;
    Color badgeBg;
    Color badgeText;
    String statusLabel;

    final normStatus = status.toUpperCase().replaceAll(' ', '_');

    switch (normStatus) {
      case 'RESOLVED':
        stripColor = const Color(0xFF389E0D);
        badgeBg = const Color(0xFFF6FFED);
        badgeText = const Color(0xFF389E0D);
        statusLabel = isTamil ? 'தீர்வு காணப்பட்டது' : 'RESOLVED';
        break;
      case 'IN_PROGRESS':
      case 'ACTION_TAKEN':
        stripColor = const Color(0xFF096DD9);
        badgeBg = const Color(0xFFE6F7FF);
        badgeText = const Color(0xFF096DD9);
        statusLabel = isTamil ? 'களப்பணியில்' : 'IN PROGRESS';
        break;
      case 'OFFICER_ASSIGNED':
        stripColor = const Color(0xFF4F46E5);
        badgeBg = const Color(0xFFEEF2FF);
        badgeText = const Color(0xFF4F46E5);
        statusLabel = isTamil ? 'பொறுப்பாளர் ஒதுக்கீடு' : 'OFFICER ASSIGNED';
        break;
      case 'UNDER_REVIEW':
      case 'IN_REVIEW':
        stripColor = const Color(0xFFD48800);
        badgeBg = const Color(0xFFFFF7E6);
        badgeText = const Color(0xFFD48800);
        statusLabel = isTamil ? 'பரிசீலனையில்' : 'IN REVIEW';
        break;
      case 'OTHERS':
        stripColor = const Color(0xFF7E22CE);
        badgeBg = const Color(0xFFFAF5FF);
        badgeText = const Color(0xFF7E22CE);
        statusLabel = isTamil ? 'நிர்வாகக் குறிப்பு' : 'REMARKS / NOTES';
        break;
      case 'SUBMITTED':
      default:
        stripColor = const Color(0xFFCF1322);
        badgeBg = const Color(0xFFFFF1F0);
        badgeText = const Color(0xFFCF1322);
        statusLabel = isTamil ? 'புதிய மனு' : 'SUBMITTED';
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBE5E5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Vertical Color Strip Accent
              Container(
                width: 6,
                color: stripColor,
              ),

              // Card Content Padding
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Reference ID & Status Badge Pill
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              referenceId,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF750000),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                color: badgeText,
                                fontSize: isTamil ? 10 : 10.5,
                                fontWeight: isTamil ? FontWeight.w700 : FontWeight.bold,
                                letterSpacing: isTamil ? 0.0 : 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      const Divider(height: 1, color: Color(0xFFF5EEEE)),

                      const SizedBox(height: 12),

                      // Bottom Row: Date & Compact View Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: Color(0xFF9E8E8E),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                date,
                                style: const TextStyle(
                                  color: Color(0xFF8E7E7E),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          // Compact View Button
                          InkWell(
                            onTap: onViewPressed,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF750000).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    isTamil ? 'பார்க்க' : 'View',
                                    style: const TextStyle(
                                      color: Color(0xFF750000),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Color(0xFF750000),
                                    size: 11,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
