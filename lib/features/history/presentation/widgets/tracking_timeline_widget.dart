import 'package:flutter/material.dart';
import 'officer_remarks_widget.dart';

class TrackingTimelineWidget extends StatelessWidget {
  final bool isTamil;
  final List<Map<String, dynamic>> timelineSteps;

  const TrackingTimelineWidget({
    super.key,
    required this.isTamil,
    required this.timelineSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isTamil ? 'புகார் கண்காணிப்பு காலக்கோடு' : 'TRACKING TIMELINE',
          style: const TextStyle(
            color: Color(0xFF6E6E6E),
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),

        const SizedBox(height: 16),

        // Vertical Timeline Stepper List (Seamlessly blends Steps and In-line Notices)
        ...timelineSteps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final bool isNotice = step['isNotice'] == true;
          final title = isTamil ? (step['titleTa'] ?? step['titleEn']) : (step['titleEn'] ?? step['titleTa']);
          final date = step['date'] as String?;
          final isCompleted = step['isCompleted'] == true;
          final isCurrent = step['isCurrent'] == true;
          final notes = (step['notes'] as String?) ?? '';
          final isLast = index == timelineSteps.length - 1;

          // 1. INLINE NOTICE CARD (When an Admin issued a custom notice/delay at this point)
          if (isNotice) {
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Purple Pin Icon & Connecting Line
                  Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Color(0xFF7E22CE),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.info_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: const Color(0xFFD8B4FE),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(width: 16),

                  // Notice Content Card
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: OfficerRemarksWidget(
                        isTamil: isTamil,
                        remarks: notes.isNotEmpty ? notes : (title as String),
                        date: date,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // 2. STANDARD PROGRESSIVE TIMELINE STEP
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vertical Stepper Indicator & Connecting Line
                Column(
                  children: [
                    // Node Badge Icon
                    if (isCompleted)
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2ECC71),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      )
                    else if (isCurrent)
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F0),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF8C0000),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFF8C0000),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F0F0),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFD4C5C5),
                            width: 1.5,
                          ),
                        ),
                      ),

                    // Connecting Line
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: isCompleted
                              ? const Color(0xFF2ECC71)
                              : const Color(0xFFE5DCDC),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 16),

                // Step Content Column
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title as String,
                          style: TextStyle(
                            color: isCompleted || isCurrent
                                ? const Color(0xFF2C0000)
                                : const Color(0xFFA09090),
                            fontSize: isTamil ? 13.5 : 14.5,
                            fontWeight: isCurrent
                                ? (isTamil ? FontWeight.w700 : FontWeight.w800)
                                : isCompleted
                                    ? (isTamil ? FontWeight.w600 : FontWeight.bold)
                                    : FontWeight.w500,
                            height: isTamil ? 1.4 : 1.25,
                          ),
                        ),

                        if (date != null && date.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            date,
                            style: TextStyle(
                              color: isCompleted || isCurrent
                                  ? const Color(0xFF8E7E7E)
                                  : const Color(0xFFB8A8A8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
