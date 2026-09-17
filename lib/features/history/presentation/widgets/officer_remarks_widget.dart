import 'package:flutter/material.dart';

class OfficerRemarksWidget extends StatelessWidget {
  final bool isTamil;
  final String remarks;
  final String? date;

  const OfficerRemarksWidget({
    super.key,
    required this.isTamil,
    required this.remarks,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE9D5FF),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Title and Date
          Row(
            children: [
              const Icon(
                Icons.sticky_note_2_rounded,
                color: Color(0xFF7E22CE),
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isTamil ? 'நிர்வாகக் குறிப்பு (Remarks)' : 'REMARKS & NOTES',
                  style: const TextStyle(
                    color: Color(0xFF7E22CE),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (date != null && date!.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(
                  date!,
                  style: const TextStyle(
                    color: Color(0xFFA855F7),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 8),

          // Remarks Body Text
          Text(
            remarks,
            style: const TextStyle(
              color: Color(0xFF3B0764),
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
