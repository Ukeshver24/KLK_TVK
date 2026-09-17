import 'package:flutter/material.dart';

class ComplaintDropdownField extends StatelessWidget {
  final String label;
  final String selectedValue;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const ComplaintDropdownField({
    super.key,
    required this.label,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelectedPlaceholder = selectedValue.startsWith('Select') ||
        selectedValue.startsWith('வட்டத்') ||
        selectedValue.startsWith('கிராமத்') ||
        selectedValue == 'Taluk' ||
        selectedValue == 'Village' ||
        selectedValue == 'வட்டம்' ||
        selectedValue == 'கிராமம்' ||
        selectedValue == 'Loading...' ||
        selectedValue == 'ஏற்றுகிறது...' ||
        selectedValue == 'No taluks available' ||
        selectedValue == 'வட்டங்கள் இல்லை' ||
        selectedValue == 'No villages found' ||
        selectedValue == 'கிராமங்கள் இல்லை';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF6E6E6E),
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5DCDC)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(16),
              menuMaxHeight: 260,
              elevation: 8,
              value: items.contains(selectedValue) ? selectedValue : items.first,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF8E7E7E),
              ),
              style: TextStyle(
                color: isSelectedPlaceholder
                    ? const Color(0xFF8E7E7E)
                    : const Color(0xFF2C0000),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              onChanged: onChanged,
              items: items.map((String value) {
                final isPlaceholder = value.startsWith('Select') ||
                    value.startsWith('வட்டத்') ||
                    value.startsWith('கிராமத்') ||
                    value == 'வட்டம்' ||
                    value == 'கிராமம்' ||
                    value == 'Taluk' ||
                    value == 'Village' ||
                    value == 'Loading...' ||
                    value == 'ஏற்றுகிறது...' ||
                    value == 'No taluks available' ||
                    value == 'வட்டங்கள் இல்லை' ||
                    value == 'No villages found' ||
                    value == 'கிராமங்கள் இல்லை';

                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: isPlaceholder
                          ? const Color(0xFF8E7E7E)
                          : const Color(0xFF2C0000),
                      fontSize: 14.5,
                      fontWeight: isPlaceholder ? FontWeight.w500 : FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
