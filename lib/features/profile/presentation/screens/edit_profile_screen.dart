import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../auth/data/auth_api_service.dart';
import '../../../shell/presentation/screens/main_shell_screen.dart';
import '../widgets/edit_profile_form_widget.dart';

class EditProfileScreen extends StatefulWidget {
  final String selectedLanguage;
  final String? initialMobile;
  final String? initialAddress;

  const EditProfileScreen({
    super.key,
    required this.selectedLanguage,
    this.initialMobile,
    this.initialAddress,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _mobileController;
  late TextEditingController _addressController;

  final AuthApiService _authService = AuthApiService();
  bool _isLoading = false;
  final int _currentBottomIndex = 4; // Active on Profile tab

  @override
  void initState() {
    super.initState();
    final session = SessionService.instance;
    _mobileController = TextEditingController(
      text: widget.initialMobile ?? session.mobile,
    );
    _addressController = TextEditingController(
      text: widget.initialAddress ?? session.address,
    );
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _onSaveChangesPressed() async {
    final isTamil = widget.selectedLanguage.trim().toLowerCase() == 'ta' ||
        widget.selectedLanguage.trim().toLowerCase() == 'tamil';

    final rawMobile = _mobileController.text.trim();
    final cleanMobile = rawMobile.replaceAll('+91', '').replaceAll(' ', '').trim();
    final address = _addressController.text.trim();

    if (cleanMobile.isEmpty || !RegExp(r'^[6-9]\d{9}$').hasMatch(cleanMobile)) {
      AppToast.showError(
        context,
        isTamil
            ? 'தயவுசெய்து சரியான 10-இலக்க கைபேசி எண்ணை உள்ளிடவும்!'
            : 'Please enter a valid 10-digit mobile number!',
      );
      return;
    }

    // Previous values for instant rollback in case of error
    final oldMobile = SessionService.instance.mobile;
    final oldAddress = SessionService.instance.address;

    // ⚡ LIGHTNING SPEED: Instant in-memory & local storage update
    await SessionService.instance.updateProfile(
      mobile: cleanMobile,
      address: address,
    );

    setState(() {
      _isLoading = true;
    });

    final userId = SessionService.instance.userCode.isNotEmpty
        ? SessionService.instance.userCode
        : (SessionService.instance.currentUser?.id ?? '');

    final result = await _authService.updateProfile(
      userId: userId,
      mobile: cleanMobile,
      address: address,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.isSuccess) {
      if (result.data != null) {
        await SessionService.instance.saveUser(result.data!);
      }

      if (!mounted) return;

      AppToast.showSuccess(
        context,
        isTamil
            ? 'சுயவிவர விவரங்கள் வெற்றிகரமாகப் புதுப்பிக்கப்பட்டன!'
            : 'Profile updated successfully!',
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      });
    } else {
      // Revert local state on backend failure
      await SessionService.instance.updateProfile(
        mobile: oldMobile,
        address: oldAddress,
      );

      if (!mounted) return;

      AppToast.showError(
        context,
        result.message,
      );
    }
  }

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MainShellScreen(
            initialIndex: 4,
            selectedLanguage: widget.selectedLanguage,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.selectedLanguage.trim().toLowerCase();
    final isTamil = lang == 'ta' || lang == 'tamil';
    final isTablet = Responsive.isTablet(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F6F6),
        body: Column(
          children: [
            // 🔴 DEEP MAROON TOP HEADER BAR
            Container(
              width: double.infinity,
              color: const Color(0xFF800000),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? MediaQuery.of(context).size.width * 0.15 : 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      // Back Arrow Circle Button
                      GestureDetector(
                        onTap: _handleBack,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.goldAccent,
                            size: 20,
                          ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      isTamil ? 'சுயவிவரத்தைத் திருத்து' : 'Edit Profile',
                      style: const TextStyle(
                        color: AppColors.goldAccent,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 📜 SCROLLABLE FORM BODY
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  // Deep Maroon Extended Header Curved Container
                  Container(
                    width: double.infinity,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFF800000),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                    ),
                  ),

                  // Form Padding
                  Transform.translate(
                    offset: const Offset(0, -18),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? MediaQuery.of(context).size.width * 0.15 : 20,
                      ),
                      child: Column(
                        children: [
                          EditProfileFormWidget(
                            isTamil: isTamil,
                            mobileController: _mobileController,
                            addressController: _addressController,
                          ),

                          const SizedBox(height: 36),

                          // SAVE CHANGES BUTTON
                          CustomButton(
                            text: isTamil
                                ? 'மாற்றங்களைச் சேமி 💾'
                                : 'Save Changes',
                            isLoading: _isLoading,
                            onPressed: _onSaveChangesPressed,
                            height: isTablet ? 54 : 48,
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentBottomIndex,
        selectedLanguage: widget.selectedLanguage,
      ),
    ),
  );
}
}
