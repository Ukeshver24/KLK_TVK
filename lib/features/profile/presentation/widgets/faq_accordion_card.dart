import 'package:flutter/material.dart';

class FaqAccordionCard extends StatelessWidget {
  final String question;
  final String answer;
  final bool isExpanded;
  final VoidCallback onTap;

  const FaqAccordionCard({
    super.key,
    required this.question,
    required this.answer,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExpanded
              ? const Color(0xFFFFC5C5)
              : const Color(0xFFEBE5E5),
          width: isExpanded ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isExpanded
                ? const Color(0xFF800000).withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: isExpanded ? 14 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question Row with Toggle Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        question,
                        style: TextStyle(
                          color: isExpanded
                              ? const Color(0xFF800000)
                              : const Color(0xFF2C0000),
                          fontSize: 15,
                          fontWeight: isExpanded
                              ? FontWeight.w900
                              : FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Circular Toggle Chevron Badge
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isExpanded
                            ? const Color(0xFFFFF1F0)
                            : const Color(0xFFF5F0F0),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: isExpanded
                            ? const Color(0xFF800000)
                            : const Color(0xFF8E7E7E),
                        size: 20,
                      ),
                    ),
                  ],
                ),

                // Expanded Answer Content
                AnimatedCrossFade(
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: Color(0xFFF5EEEE)),
                      const SizedBox(height: 12),
                      Text(
                        answer,
                        style: const TextStyle(
                          color: Color(0xFF5A5A5A),
                          fontSize: 13.5,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
