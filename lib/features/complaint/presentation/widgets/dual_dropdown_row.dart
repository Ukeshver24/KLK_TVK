import 'package:flutter/material.dart';
import 'complaint_dropdown_field.dart';

class DualDropdownRow extends StatelessWidget {
  final String leftLabel;
  final String leftValue;
  final List<String> leftItems;
  final ValueChanged<String?> onLeftChanged;

  final String rightLabel;
  final String rightValue;
  final List<String> rightItems;
  final ValueChanged<String?> onRightChanged;

  const DualDropdownRow({
    super.key,
    required this.leftLabel,
    required this.leftValue,
    required this.leftItems,
    required this.onLeftChanged,
    required this.rightLabel,
    required this.rightValue,
    required this.rightItems,
    required this.onRightChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ComplaintDropdownField(
            label: leftLabel,
            selectedValue: leftValue,
            items: leftItems,
            onChanged: onLeftChanged,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: ComplaintDropdownField(
            label: rightLabel,
            selectedValue: rightValue,
            items: rightItems,
            onChanged: onRightChanged,
          ),
        ),
      ],
    );
  }
}
