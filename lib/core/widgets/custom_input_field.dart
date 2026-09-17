import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final String? prefixText;
  final TextInputType keyboardType;
  final int maxLines;
  final VoidCallback? onTap;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.prefixText,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.onTap,
    this.readOnly = false,
    this.inputFormatters,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5DCDC)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: maxLines > 1 ? 8 : 4,
      ),
      child: Row(
        crossAxisAlignment:
            maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          if (prefixIcon != null) ...[
            Padding(
              padding: EdgeInsets.only(top: maxLines > 1 ? 10 : 0),
              child: Icon(prefixIcon, color: const Color(0xFF8E7A7A), size: 20),
            ),
            const SizedBox(width: 12),
          ],
          if (prefixText != null) ...[
            Text(
              prefixText!,
              style: const TextStyle(
                color: Color(0xFF6B0000),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            Container(
              height: 20,
              width: 1,
              color: const Color(0xFFD4C5C5),
              margin: const EdgeInsets.only(right: 12),
            ),
          ],
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              maxLength: maxLength,
              maxLines: maxLines,
              readOnly: readOnly,
              onTap: onTap,
              style: const TextStyle(
                color: Color(0xFF2C0000),
                fontWeight: FontWeight.w600,
                fontSize: 14.5,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: maxLines > 1
                    ? const EdgeInsets.symmetric(vertical: 8)
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
