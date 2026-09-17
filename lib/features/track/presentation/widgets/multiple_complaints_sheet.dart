import 'package:flutter/material.dart';
import '../../../../core/utils/app_date_formatter.dart';
import '../../../complaint/data/complaint_api_service.dart';
import '../screens/track_status_details_screen.dart';

class MultipleComplaintsSheet {
  static void show(
    BuildContext context, {
    required bool isTamil,
    required String selectedLanguage,
    required String searchQuery,
    required List<ComplaintModel> complaints,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;
        return Container(
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.85,
            minHeight: screenHeight * 0.40,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            bottom: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top drag pill handle
                const SizedBox(height: 12),
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4C5C5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),

                // Sticky Header Row
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF1F0),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.receipt_long_rounded,
                                    color: Color(0xFF8C0000),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    isTamil
                                        ? '${complaints.length} புகார்கள் கண்டறியப்பட்டன'
                                        : 'Found ${complaints.length} Complaints',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: const Color(0xFF1E1E1E),
                                      fontSize: isTamil ? 15 : 16,
                                      fontWeight: isTamil ? FontWeight.w700 : FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isTamil
                                  ? '$searchQuery-க்கான புகார்கள். கண்காணிக்க ஒன்றை தேர்வு செய்யவும்.'
                                  : 'Registered for $searchQuery. Select to track status.',
                              style: const TextStyle(
                                color: Color(0xFF7A6A6A),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Close / Back Circular Button
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5EFEF),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE5DCDC)),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF5A4A4A),
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, color: Color(0xFFEBE5E5)),

                // Complaints Scrollable List (Handles 3, 10, 20+ complaints cleanly)
                Flexible(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: complaints.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = complaints[index];
                      return _buildComplaintCard(
                        context,
                        item: item,
                        isTamil: isTamil,
                        selectedLanguage: selectedLanguage,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildComplaintCard(
    BuildContext context, {
    required ComplaintModel item,
    required bool isTamil,
    required String selectedLanguage,
  }) {
    Color badgeBg;
    Color badgeText;
    String statusLabel;

    final normStatus = item.status.toUpperCase().replaceAll(' ', '_');
    if (normStatus == 'RESOLVED') {
      badgeBg = const Color(0xFFF6FFED);
      badgeText = const Color(0xFF389E0D);
      statusLabel = isTamil ? 'தீர்வு காணப்பட்டது' : 'RESOLVED';
    } else if (normStatus == 'ACTION_TAKEN' || normStatus == 'IN_PROGRESS') {
      badgeBg = const Color(0xFFE6F7FF);
      badgeText = const Color(0xFF096DD9);
      statusLabel = isTamil ? 'களப்பணியில்' : 'IN PROGRESS';
    } else if (normStatus == 'UNDER_REVIEW' || normStatus == 'IN_REVIEW' || normStatus == 'OFFICER_ASSIGNED') {
      badgeBg = const Color(0xFFFFF7E6);
      badgeText = const Color(0xFFD48800);
      statusLabel = isTamil ? 'பரிசீலனையில்' : 'IN REVIEW';
    } else {
      badgeBg = const Color(0xFFFFF1F0);
      badgeText = const Color(0xFFCF1322);
      statusLabel = isTamil ? 'புதிய மனு' : 'SUBMITTED';
    }

    return InkWell(
      onTap: () {
        Navigator.of(context).pop(); // Close sheet
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TrackStatusDetailsScreen(
              selectedLanguage: selectedLanguage,
              referenceId: item.referenceId,
              citizenId: item.citizenId,
              status: item.status,
              date: AppDateFormatter.formatDateTime(item.createdAt),
              statusReason: item.statusReason,
              adminRemarks: item.adminRemarks,
              timelineEvents: item.timelineEvents,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF7F7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5DCDC)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Token ID & Status Badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.referenceId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF750000),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
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
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Row 2: Category & Location
            Row(
              children: [
                const Icon(
                  Icons.category_outlined,
                  size: 14,
                  color: Color(0xFF8E7E7E),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${item.category} • ${item.village}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF4A3A3A),
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Row 3: Submission Date & Time
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 12,
                  color: Color(0xFF8E7E7E),
                ),
                const SizedBox(width: 6),
                Text(
                  AppDateFormatter.formatDateTime(item.createdAt),
                  style: const TextStyle(
                    color: Color(0xFF6E5E5E),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Row 4: Description snippet & Arrow
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF7E6E6E),
                      fontSize: 11.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Track',
                      style: TextStyle(
                        color: Color(0xFF8C0000),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xFF8C0000),
                      size: 11,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
