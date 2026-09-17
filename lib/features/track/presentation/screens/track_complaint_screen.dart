import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../complaint/data/complaint_api_service.dart';
import '../../../../core/utils/app_date_formatter.dart';
import '../widgets/track_header_graphic_widget.dart';
import '../widgets/multiple_complaints_sheet.dart';
import 'track_status_details_screen.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class TrackComplaintScreen extends StatefulWidget {
  final String selectedLanguage;
  final bool isNestedInShell;

  const TrackComplaintScreen({
    super.key,
    required this.selectedLanguage,
    this.isNestedInShell = false,
  });

  @override
  State<TrackComplaintScreen> createState() => _TrackComplaintScreenState();
}

class _TrackComplaintScreenState extends State<TrackComplaintScreen> {
  final _complaintIdController = TextEditingController();
  final _mobileController = TextEditingController();
  final ComplaintApiService _complaintApiService = ComplaintApiService();
  bool _isSearching = false;
  final int _currentBottomIndex = 3; // Active on Track tab

  @override
  void dispose() {
    _complaintIdController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _onTrackNowPressed() async {
    final isTamil = widget.selectedLanguage == 'ta';
    final complaintId = _complaintIdController.text.trim();
    final mobileNumber = _mobileController.text.trim();

    // Rule 1: EITHER Complaint ID OR Mobile Number must be entered
    if (complaintId.isEmpty && mobileNumber.isEmpty) {
      AppToast.showError(
        context,
        isTamil
            ? 'தயவுசெய்து புகார் எண் அல்லது கைபேசி எண்ணை உள்ளிடவும்!'
            : 'Please enter Complaint ID or Mobile Number!',
      );
      return;
    }

    // Rule 2: If searching with Mobile Number, it must be exactly 10 digits
    if (complaintId.isEmpty && mobileNumber.isNotEmpty && mobileNumber.length < 10) {
      AppToast.showError(
        context,
        isTamil
            ? 'தயவுசெய்து சரியான 10 இலக்க கைபேசி எண்ணை உள்ளிடவும்!'
            : 'Please enter a valid 10-digit mobile number!',
      );
      return;
    }

    final enteredValue = complaintId.isNotEmpty ? complaintId : mobileNumber;
    final cleanRefId = complaintId.replaceAll('#', '').toUpperCase();

    setState(() => _isSearching = true);

    try {
      final query = cleanRefId.isNotEmpty ? cleanRefId : enteredValue;
      final complaints = await _complaintApiService.trackComplaints(query);

      if (!mounted) return;
      setState(() => _isSearching = false);

      if (complaints.isEmpty) {
        AppToast.showError(
          context,
          isTamil
              ? 'புகார் எண் அல்லது கைபேசி எண் பதிவேட்டில் இல்லை!'
              : 'Complaint ID or Mobile Number not found in records!',
        );
      } else if (complaints.length == 1) {
        // Single complaint found -> Direct navigation to Track Status Details!
        final single = complaints.first;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TrackStatusDetailsScreen(
              selectedLanguage: widget.selectedLanguage,
              referenceId: single.referenceId,
              citizenId: single.citizenId,
              status: single.status,
              date: AppDateFormatter.formatDateTime(single.createdAt),
              statusReason: single.statusReason,
              adminRemarks: single.adminRemarks,
              timelineEvents: single.timelineEvents,
            ),
          ),
        );
      } else {
        // Multiple complaints found for this mobile number -> Show Multiple Complaints Selection Sheet!
        MultipleComplaintsSheet.show(
          context,
          isTamil: isTamil,
          selectedLanguage: widget.selectedLanguage,
          searchQuery: enteredValue,
          complaints: complaints,
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSearching = false);
      AppToast.showError(
        context,
        isTamil
            ? 'தகவலைப் பெறுவதில் பிழை ஏற்பட்டது. மீண்டும் முயற்சிக்கவும்.'
            : 'Error fetching records. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTamil = widget.selectedLanguage == 'ta';
    final isTablet = Responsive.isTablet(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F6),
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Compact Top Header Bar
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? size.width * 0.15 : 20,
                vertical: 12,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFF9F6F6),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFEBE5E5), width: 0.8),
                ),
              ),
              child: Row(
                children: [
                  if (!widget.isNestedInShell) ...[
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F0F0),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE5DCDC), width: 0.8),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFF2C0000),
                          size: 19,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],
                  Text(
                    isTamil ? 'புகார் நிலை அறிய' : 'Track Grievance',
                    style: const TextStyle(
                      color: Color(0xFF1E1E1E),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? size.width * 0.15 : 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                // Graphic Icon & Headline Widget
                TrackHeaderGraphicWidget(isTamil: isTamil),

                const SizedBox(height: 28),

                // Form Container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFEBE5E5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // COMPLAINT ID FIELD
                      _buildFieldLabel(isTamil ? 'புகார் எண்' : 'COMPLAINT ID'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _complaintIdController,
                        hintText: 'e.g. TVK-KKI-26-0001',
                        isUpperCase: true,
                      ),

                      const SizedBox(height: 18),

                      // MOBILE NUMBER FIELD WITH +91 PREFIX
                      _buildFieldLabel(
                          isTamil ? 'கைபேசி எண்' : 'MOBILE NUMBER'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5DCDC)),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              '+91',
                              style: TextStyle(
                                color: Color(0xFF6B0000),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              height: 20,
                              width: 1,
                              color: const Color(0xFFD4C5C5),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _mobileController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                style: const TextStyle(
                                  color: Color(0xFF2C0000),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                decoration: InputDecoration(
                                  hintText: isTamil
                                      ? '10 இலக்க எண்'
                                      : '10-digit number',
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF9E9E9E),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // TRACK NOW BUTTON
                      CustomButton(
                        text: _isSearching
                            ? (isTamil ? 'தேடப்படுகிறது...' : 'Searching...')
                            : (isTamil
                                ? 'இப்போதே கண்காணிக்க ➔'
                                : 'Track Now ➔'),
                        onPressed: _isSearching ? () {} : _onTrackNowPressed,
                        height: isTablet ? 54 : 48,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    ),
  ),

  // Bottom Navigation Bar
  bottomNavigationBar: widget.isNestedInShell
      ? null
      : CustomBottomNavBar(
          currentIndex: _currentBottomIndex,
          selectedLanguage: widget.selectedLanguage,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool isUpperCase = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5DCDC)),
      ),
      child: TextFormField(
        controller: controller,
        textCapitalization: isUpperCase
            ? TextCapitalization.characters
            : TextCapitalization.none,
        inputFormatters: isUpperCase ? [UpperCaseTextFormatter()] : null,
        style: const TextStyle(
          color: Color(0xFF2C0000),
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF9E9E9E),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
