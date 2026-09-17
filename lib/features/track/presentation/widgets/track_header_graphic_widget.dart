import 'package:flutter/material.dart';

class TrackHeaderGraphicWidget extends StatelessWidget {
  final bool isTamil;

  const TrackHeaderGraphicWidget({
    super.key,
    required this.isTamil,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Center Circular Search Pin Badge Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9E6),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFC107).withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.content_paste_search_rounded,
            color: Color(0xFFD48800),
            size: 38,
          ),
        ),

        const SizedBox(height: 18),

        // Headline
        Text(
          isTamil ? 'நிலையை சரிபார்க்கவும்' : 'Check Status',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF1E1E1E),
            fontSize: isTamil ? 20 : 22,
            fontWeight: isTamil ? FontWeight.w700 : FontWeight.w800,
            letterSpacing: isTamil ? 0.2 : 0.3,
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            isTamil
                ? 'உங்கள் புகார் குறிப்பு எண் அல்லது பதிவு செய்யப்பட்ட கைபேசி எண்ணை உள்ளிட்டு நிலையை அறியவும்.'
                : 'Enter your complaint reference ID or registered mobile number to track progress.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF6E6E6E),
              fontSize: 13,
              height: isTamil ? 1.5 : 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
