import 'package:flutter/material.dart';

class QuickActionCardWidget extends StatelessWidget {
  final bool isTamil;
  final VoidCallback onRaiseComplaint;
  final VoidCallback onTrackStatus;
  final VoidCallback onContactMla;

  const QuickActionCardWidget({
    super.key,
    required this.isTamil,
    required this.onRaiseComplaint,
    required this.onTrackStatus,
    required this.onContactMla,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // QUICK ACTIONS HEADER
        Text(
          isTamil ? 'விரைவுச் செயல்பாடுகள்' : 'QUICK ACTIONS',
          style: const TextStyle(
            color: Color(0xFF6E6E6E),
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),

        const SizedBox(height: 14),

        // Action Card 1: Raise a Complaint (Red Gradient Card)
        GestureDetector(
          onTap: onRaiseComplaint,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFD32F2F),
                  Color(0xFF8C0000),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8C0000).withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTamil ? 'புகார் பதிவு செய்க' : 'Raise a Complaint',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTamil ? 19 : 20,
                          fontWeight: isTamil ? FontWeight.w700 : FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isTamil
                            ? 'தலைவரிடம் நேரடியாக புகார் தெரிவிக்கவும்'
                            : 'Report issues directly to the MLA',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.88),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          height: isTamil ? 1.45 : 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.campaign_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Action Cards Row: Track Status & Contact MLA
        Row(
          children: [
            // Track Status Card
            Expanded(
              child: GestureDetector(
                onTap: onTrackStatus,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFEBE5E5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF9E6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFFD48800),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            isTamil ? 'புகார்\nநிலை' : 'Track\nStatus',
                            style: TextStyle(
                              color: const Color(0xFF2C0000),
                              fontSize: isTamil ? 12.5 : 13,
                              fontWeight: isTamil ? FontWeight.w700 : FontWeight.bold,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Contact MLA Card
            Expanded(
              child: GestureDetector(
                onTap: onContactMla,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFEBE5E5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE6F4FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.contact_phone_outlined,
                          color: Color(0xFF0958D9),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            isTamil ? 'எம்எல்ஏ\nதொடர்புக்கு' : 'Contact\nMLA',
                            style: TextStyle(
                              color: const Color(0xFF2C0000),
                              fontSize: isTamil ? 12.5 : 13,
                              fontWeight: isTamil ? FontWeight.w700 : FontWeight.bold,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
