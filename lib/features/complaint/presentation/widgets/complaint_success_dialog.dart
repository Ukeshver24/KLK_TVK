import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_date_formatter.dart';

class ComplaintSuccessDialog extends StatelessWidget {
  final bool isTamil;
  final String complaintId;
  final VoidCallback onGoHome;

  const ComplaintSuccessDialog({
    super.key,
    required this.isTamil,
    required this.complaintId,
    required this.onGoHome,
  });

  static void show(
    BuildContext context, {
    required bool isTamil,
    required String complaintId,
    required VoidCallback onGoHome,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'ComplaintSuccess',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curvedValue = Curves.easeOutBack.transform(anim1.value);
        return Transform.scale(
          scale: curvedValue,
          child: Opacity(
            opacity: anim1.value,
            child: ComplaintSuccessDialog(
              isTamil: isTamil,
              complaintId: complaintId,
              onGoHome: onGoHome,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      elevation: 16,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Badge Icon
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF2E7D32),
                size: 48,
              ),
            ),

            const SizedBox(height: 18),

            // Success Title
            Text(
              isTamil ? 'புகார் வெற்றிகரமாக பதிவானது!' : 'Complaint Registered!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2C0000),
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              isTamil
                  ? 'உங்கள் புகார் பெறப்பட்டு ஆய்வுக்கு அனுப்பப்பட்டுள்ளது.'
                  : 'Your grievance has been submitted and forwarded for review.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6E6E6E),
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),

            // Complaint Tracking ID Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFE58F)),
              ),
              child: Column(
                children: [
                  Text(
                    isTamil ? 'புகார் கண்காணிப்பு எண்' : 'COMPLAINT TRACKING ID',
                    style: const TextStyle(
                      color: Color(0xFF8C6B00),
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    complaintId,
                    style: const TextStyle(
                      color: Color(0xFF500000),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${isTamil ? "பதிவு செய்த நேரம்: " : "Submitted at: "}${AppDateFormatter.formatDateTime(DateTime.now())}',
                    style: const TextStyle(
                      color: Color(0xFF8C6B00),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Back to Home Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onGoHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF750000),
                  foregroundColor: AppColors.goldAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  isTamil ? 'முகப்பு பக்கத்திற்குச் செல்க ➔' : 'Back to Home ➔',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
