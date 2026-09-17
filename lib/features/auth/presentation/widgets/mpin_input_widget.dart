import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class MpinInputWidget extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;

  const MpinInputWidget({
    super.key,
    required this.controllers,
    required this.focusNodes,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (index) {
        return SizedBox(
          width: 54,
          height: 52,
          child: TextField(
            controller: controllers[index],
            focusNode: focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            obscureText: true,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B0000),
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: const Color(0xFFF8F5F5),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFFE5DCDC),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.primaryMaroon,
                  width: 2.0,
                ),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 3) {
                focusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                focusNodes[index - 1].requestFocus();
              }
            },
          ),
        );
      }),
    );
  }
}
