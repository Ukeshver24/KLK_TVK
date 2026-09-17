import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditProfileFormWidget extends StatelessWidget {
  final bool isTamil;
  final TextEditingController mobileController;
  final TextEditingController addressController;

  const EditProfileFormWidget({
    super.key,
    required this.isTamil,
    required this.mobileController,
    required this.addressController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEBE5E5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. MOBILE NUMBER FIELD
          _buildFieldLabel(isTamil ? 'கைபேசி எண்' : 'MOBILE NUMBER'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF5E6E6)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.phone_rounded,
                  color: Color(0xFF8C0000),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: mobileController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    style: const TextStyle(
                      color: Color(0xFF2C0000),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: isTamil ? '10-இலக்க கைபேசி எண்' : '10-digit Mobile Number',
                      hintStyle: const TextStyle(
                        color: Color(0xFFA09090),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. RESIDENTIAL ADDRESS FIELD
          _buildFieldLabel(isTamil ? 'வீட்டு முகவரி' : 'RESIDENTIAL ADDRESS'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF5E6E6)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFF8C0000),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: addressController,
                    maxLines: 3,
                    style: const TextStyle(
                      color: Color(0xFF2C0000),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      height: 1.35,
                    ),
                    decoration: InputDecoration(
                      hintText: isTamil ? 'முழு வீட்டு முகவரி' : 'Full Residential Address',
                      hintStyle: const TextStyle(
                        color: Color(0xFFA09090),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF6E6E6E),
        fontSize: 11.5,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
      ),
    );
  }
}
