import 'package:flutter/material.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/utils/app_date_formatter.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/utils/network_error_helper.dart';
import '../../data/complaint_api_service.dart';
import '../widgets/complaint_dropdown_field.dart';
import '../widgets/complaint_step_header.dart';
import '../widgets/file_upload_area_widget.dart';
import '../widgets/location_picker_widget.dart';
import 'complaint_success_screen.dart';

class RegisterComplaintStep2Screen extends StatefulWidget {
  final String selectedLanguage;
  final Map<String, String>? step1Data;

  const RegisterComplaintStep2Screen({
    super.key,
    required this.selectedLanguage,
    this.step1Data,
  });

  @override
  State<RegisterComplaintStep2Screen> createState() =>
      _RegisterComplaintStep2ScreenState();
}

class _RegisterComplaintStep2ScreenState
    extends State<RegisterComplaintStep2Screen> {
  final _descriptionController = TextEditingController();
  List<String> _selectedImages = [];
  LocationDataModel? _selectedLocation;
  final int _currentBottomIndex = 1;

  final ComplaintApiService _complaintApiService = ComplaintApiService();
  bool _isSubmitting = false;

  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    final isTamil = widget.selectedLanguage == 'ta';
    _selectedCategory =
        isTamil ? 'சாலை & உள்கட்டமைப்பு' : 'Roads & Infrastructure';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _onRegisterComplaintPressed() async {
    final isTamil = widget.selectedLanguage == 'ta';

    if (_descriptionController.text.trim().isEmpty) {
      AppToast.showError(
        context,
        isTamil
            ? 'தயவுசெய்து பிரச்சனையைப் பற்றிய விவரங்களை எழுதவும்!'
            : 'Please enter complaint description details!',
      );
      return;
    }

    if (_selectedLocation == null ||
        _selectedLocation?.latitude == null ||
        _selectedLocation?.longitude == null) {
      AppToast.showError(
        context,
        isTamil
            ? 'பிரச்சனை உள்ள GPS இருப்பிடத்தை வரைபடத்தில் தேர்வு செய்வது கட்டாயமாகும்!'
            : 'Selecting the problem GPS location on the map is mandatory!',
      );
      return;
    }

    final user = SessionService.instance.currentUser;
    final userId = user?.id ?? '';
    final step1 = widget.step1Data ?? {};

    final fullName = step1['fullName'] ?? user?.fullName ?? '';
    final mobile = step1['mobile'] ?? user?.mobile ?? '';
    final taluk = step1['taluk'] ?? 'Kallakurichi';
    final village = step1['village'] ?? '';
    final address = step1['address'] ?? user?.address ?? '';
    final pincode = step1['pincode'] ?? '606202';

    setState(() => _isSubmitting = true);

    try {
      String? uploadedImageUrl;
      if (_selectedImages.isNotEmpty) {
        final List<String> localImages = [];
        final List<String> remoteUrls = [];
        for (final img in _selectedImages) {
          if (img.startsWith('http')) {
            remoteUrls.add(img);
          } else {
            localImages.add(img);
          }
        }

        if (localImages.isNotEmpty) {
          final uploaded = await _complaintApiService.uploadMultipleImages(localImages);
          if (uploaded.length < localImages.length) {
            setState(() => _isSubmitting = false);
            if (mounted) {
              AppToast.showError(
                context,
                isTamil
                    ? 'புகைப்படங்களை பதிவேற்றுவதில் சிக்கல் ஏற்பட்டது. மீண்டும் முயற்சிக்கவும்!'
                    : 'Failed to upload all complaint images. Please check your connection and try again!',
              );
            }
            return;
          }
          remoteUrls.addAll(uploaded);
        }

        if (remoteUrls.isNotEmpty) {
          uploadedImageUrl = remoteUrls.join(',');
        }
      }

      final result = await _complaintApiService.registerComplaint(
        userId: userId,
        fullName: fullName,
        mobile: mobile,
        taluk: taluk,
        village: village,
        address: address,
        pincode: pincode,
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        attachment: uploadedImageUrl,
        latitude: _selectedLocation?.latitude,
        longitude: _selectedLocation?.longitude,
        locationUrl: _selectedLocation?.locationUrl,
        isTamil: isTamil,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (result.isSuccess && result.data != null) {
        // Navigate to Complaint Success Screen with real generated Reference ID (TVK-KKI-26-XXXX) and form data
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ComplaintSuccessScreen(
              selectedLanguage: widget.selectedLanguage,
              referenceId: result.data!.referenceId,
              applicantName: fullName,
              mobileNumber: mobile,
              constituency: isTamil ? 'கள்ளக்குறிச்சி' : 'Kallakurichi',
              submissionDate: AppDateFormatter.formatDateTime(
                result.data?.createdAt.isNotEmpty == true
                    ? result.data!.createdAt
                    : DateTime.now().toString(),
              ),
              complaintDescription: _descriptionController.text.trim(),
            ),
          ),
        );
      } else {
        AppToast.showError(
          context,
          result.message,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      AppToast.showError(
        context,
        NetworkErrorHelper.format(e, isTamil: isTamil),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTamil = widget.selectedLanguage == 'ta';
    final isTablet = Responsive.isTablet(context);
    final size = MediaQuery.of(context).size;

    final categories = isTamil
        ? [
            'சாலை & உள்கட்டமைப்பு',
            'குடிநீர் வசதி',
            'தெருவிளக்கு & மின்சாரம்',
            'கழிவுநீர் & துப்புரவு',
            'மருத்துவம் & சுகாதாரம்',
            'கல்வி & பள்ளிகள்',
            'வருவாய் & நில அளவை',
            'பிற தேவைகள் / பொதுவானவை',
          ]
        : [
            'Roads & Infrastructure',
            'Drinking Water Supply',
            'Street Lights & Electricity',
            'Sanitation & Drainage',
            'Healthcare & Hospitals',
            'Education & Schools',
            'Revenue & Land Services',
            'General & Other Issues',
          ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F6),
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Compact Top Header Bar
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? size.width * 0.15 : 16,
                vertical: 10,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFF9F6F6),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFEBE5E5), width: 0.8),
                ),
              ),
              child: ComplaintStepHeader(
                title: isTamil ? 'புகார் பதிவு' : 'Register Complaint',
                stepSubtitle: isTamil ? 'படி 2 / 2' : 'STEP 2 OF 2',
                onBackPressed: () => Navigator.of(context).pop(),
              ),
            ),

            // Scrollable Form Body
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
                      // GRIEVANCE CATEGORY DROPDOWN
                      ComplaintDropdownField(
                        label: isTamil ? 'பிரச்சனை வகை' : 'COMPLAINT CATEGORY',
                        selectedValue: categories.contains(_selectedCategory)
                            ? _selectedCategory
                            : categories.first,
                        items: categories,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedCategory = val);
                          }
                        },
                      ),

                      const SizedBox(height: 20),

                      // COMPLAINT DESCRIPTION (Increased Height Multi-line Textarea)
                      Text(
                        isTamil ? 'புகார் விவரம்' : 'COMPLAINT DESCRIPTION',
                        style: const TextStyle(
                          color: Color(0xFF6E6E6E),
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Spacious 6-line Textarea Field
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF8C0000),
                            width: 1.5,
                          ),
                        ),
                        child: TextFormField(
                          controller: _descriptionController,
                          maxLines: 6,
                          style: const TextStyle(
                            color: Color(0xFF2C0000),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            height: 1.35,
                          ),
                          decoration: InputDecoration(
                            hintText: isTamil
                                ? 'பிரச்சனையைப் பற்றி விரிவாக விவரிக்கவும்...'
                                : 'Describe the issue in detail...',
                            hintStyle: const TextStyle(
                              color: Color(0xFF9E9E9E),
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // UPLOAD PROOF IMAGE WIDGET (Max 2 Images • Auto-Compressed Zero Lag)
                      FileUploadAreaWidget(
                        isTamil: isTamil,
                        initialImages: _selectedImages,
                        onImagesSelected: (images) {
                          setState(() {
                            _selectedImages = images;
                          });
                        },
                      ),

                      const SizedBox(height: 22),

                      // GPS PROBLEM LOCATION PICKER (Current Location & Interactive Map Pin)
                      LocationPickerWidget(
                        isTamil: isTamil,
                        initialLocation: _selectedLocation,
                        onLocationSelected: (loc) {
                          setState(() {
                            _selectedLocation = loc;
                          });
                        },
                      ),

                      const SizedBox(height: 28),

                      // FINAL REGISTER COMPLAINT BUTTON
                      CustomButton(
                        text: _isSubmitting
                            ? (isTamil ? 'பதிவு செய்யப்படுகிறது...' : 'Registering...')
                            : (isTamil
                                ? 'புகார் பதிவு செய்க ➔'
                                : 'Register Complaint ➔'),
                        onPressed: _isSubmitting ? () {} : _onRegisterComplaintPressed,
                        height: isTablet ? 56 : 50,
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
  bottomNavigationBar: CustomBottomNavBar(
    currentIndex: _currentBottomIndex,
    selectedLanguage: widget.selectedLanguage,
  ),
);
  }
}
