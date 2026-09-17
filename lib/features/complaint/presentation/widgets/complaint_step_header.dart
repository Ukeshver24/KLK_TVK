import 'package:flutter/material.dart';

class ComplaintStepHeader extends StatelessWidget {
  final String title;
  final String stepSubtitle;
  final VoidCallback onBackPressed;

  const ComplaintStepHeader({
    super.key,
    required this.title,
    required this.stepSubtitle,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Back Button
        GestureDetector(
          onTap: onBackPressed,
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F0F0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF2C0000),
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF1E1E1E),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                stepSubtitle,
                style: const TextStyle(
                  color: Color(0xFF8E7E7E),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
