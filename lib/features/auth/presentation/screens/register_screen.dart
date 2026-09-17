import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_input_field.dart';
import '../../../shell/presentation/screens/main_shell_screen.dart';
import '../../data/auth_api_service.dart';
import '../widgets/mpin_input_widget.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  final String selectedLanguage;

  const RegisterScreen({
    super.key,
    required this.selectedLanguage,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // 4 Controllers & FocusNodes for MPIN
  final List<TextEditingController> _pinControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _pinFocusNodes = List.generate(4, (_) => FocusNode());

  final AuthApiService _authService = AuthApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    for (var controller in _pinControllers) {
      controller.dispose();
    }
    for (var focusNode in _pinFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryMaroon,
              onPrimary: AppColors.white,
              surface: Color(0xFF2A0808),
              onSurface: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _onRegisterPressed() async {
    final isTamil = widget.selectedLanguage == 'ta';

    final fullName = _fullNameController.text.trim();
    if (fullName.isEmpty) {
      AppToast.showError(
        context,
        isTamil
            ? 'தயவுசெய்து உங்கள் முழு பெயரை உள்ளிடவும்!'
            : 'Please enter your full name!',
      );
      return;
    }

    final mobile = _mobileController.text.trim();
    if (mobile.length != 10) {
      AppToast.showError(
        context,
        isTamil
            ? 'தயவுசெய்து சரியான 10-இலக்க கைபேசி எண்ணை உள்ளிடவும்!'
            : 'Please enter a valid 10-digit mobile number!',
      );
      return;
    }

    final dob = _dobController.text.trim();
    if (dob.isEmpty) {
      AppToast.showError(
        context,
        isTamil
            ? 'தயவுசெய்து உங்கள் பிறந்த தேதியைத் தேர்வு செய்யவும்!'
            : 'Please select your date of birth!',
      );
      return;
    }

    final address = _addressController.text.trim();
    if (address.isEmpty) {
      AppToast.showError(
        context,
        isTamil
            ? 'தயவுசெய்து உங்கள் முகவரியை உள்ளிடவும் (கட்டாயம்)!'
            : 'Please enter your residential address (Mandatory)!',
      );
      return;
    }

    final mpin = _pinControllers.map((c) => c.text).join();
    if (mpin.length != 4) {
      AppToast.showError(
        context,
        isTamil
            ? 'தயவுசெய்து 4-இலக்க MPIN-ஐ உள்ளிடவும்!'
            : 'Please enter a complete 4-digit MPIN!',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _authService.register(
      fullName: fullName,
      mobile: mobile,
      dob: dob,
      address: address,
      mpin: mpin,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.isSuccess) {
      _showRegistrationSuccessDialog();
    } else {
      AppToast.showError(
        context,
        result.message,
      );
    }
  }

  void _showRegistrationSuccessDialog() {
    final isTamil = widget.selectedLanguage == 'ta';
    final isTablet = Responsive.isTablet(context);

    bool hasNavigated = false;

    void navigateToLogin() {
      if (hasNavigated) return;
      hasNavigated = true;
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop(); // Close dialog
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginScreen(selectedLanguage: widget.selectedLanguage),
        ),
      );
    }

    // Auto-dismiss and navigate after 3 seconds
    final timer = Timer(const Duration(seconds: 3), () {
      navigateToLogin();
    });

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'RegistrationSuccess',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curve,
          child: FadeTransition(
            opacity: animation,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              elevation: 20,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: EdgeInsets.all(isTablet ? 28 : 22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: AppColors.goldAccent,
                    width: 1.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryMaroon.withValues(alpha: 0.35),
                      blurRadius: 30,
                      spreadRadius: 2,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Success Check Badge Icon
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF8C0000),
                            Color(0xFF5E0000),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryMaroon.withValues(alpha: 0.4),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.goldAccent,
                        size: 42,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Success Title
                    Text(
                      isTamil ? 'பதிவு வெற்றிகரமாக முடிந்தது!' : 'Registration Successful!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF1F0000),
                        fontSize: isTablet ? 22 : (isTamil ? 17 : 18),
                        fontWeight: isTamil ? FontWeight.w700 : FontWeight.w800,
                        letterSpacing: isTamil ? 0.2 : 0.4,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Success Description
                    Text(
                      isTamil
                          ? 'உங்கள் கணக்கு வெற்றிகரமாக உருவாக்கப்பட்டது. உங்கள் கைபேசி எண் மற்றும் MPIN பயன்படுத்தி உள்நுழையவும்.'
                          : 'Your account has been created successfully. Please log in using your Mobile Number and MPIN.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF6E6E6E),
                        fontSize: isTablet ? 14 : 12.5,
                        height: isTamil ? 1.5 : 1.45,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Auto Redirect Progress Bar
                    Container(
                      height: 3,
                      width: 140,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0E6E6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: const LinearProgressIndicator(
                          color: AppColors.goldAccent,
                          backgroundColor: Color(0xFFF0E6E6),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Proceed to Login Button (Fitted to prevent horizontal overflow)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          timer.cancel();
                          navigateToLogin();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF750000),
                          foregroundColor: AppColors.goldAccent,
                          elevation: 6,
                          shadowColor: const Color(0xFF750000).withValues(alpha: 0.35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isTamil ? 'உள்நுழைவுக்குச் செல்லவும்' : 'Proceed to Login',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.goldAccent,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: AppColors.goldAccent,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MainShellScreen(
            selectedLanguage: widget.selectedLanguage,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTamil = widget.selectedLanguage == 'ta';
    final isTablet = Responsive.isTablet(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF7F7),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFF7F7),
                Color(0xFFFAF2F2),
                Color(0xFFF5EAEA),
              ],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? constraints.maxWidth * 0.22 : 20,
                          vertical: 16,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Main Register Card Container
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(isTablet ? 32 : 22),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: AppColors.primaryMaroon.withValues(alpha: 0.1),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryMaroon.withValues(alpha: 0.08),
                                      blurRadius: 28,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // Back Button inside Card
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      child: InkWell(
                                        onTap: _handleBack,
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF8F3F3),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(0xFFEBE5E5),
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.arrow_back_rounded,
                                            color: Color(0xFF6B0000),
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Header Icon
                                      Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFF8C0000),
                                              Color(0xFF5E0000),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF750000)
                                                  .withValues(alpha: 0.35),
                                              blurRadius: 16,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.person_add_alt_1_rounded,
                                          color: AppColors.goldAccent,
                                          size: 32,
                                        ),
                                      ),

                                      const SizedBox(height: 18),

                                      // Title (Centered)
                                      Text(
                                        isTamil ? 'கணக்கை உருவாக்கவும்' : 'Create an Account',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: const Color(0xFF1F0000),
                                          fontSize: isTablet ? 28 : (isTamil ? 21 : 22),
                                          fontWeight: isTamil ? FontWeight.w700 : FontWeight.w800,
                                          letterSpacing: isTamil ? 0.2 : 0.3,
                                        ),
                                      ),

                                  const SizedBox(height: 6),

                                  // Subtitle
                                  Text(
                                    isTamil
                                        ? 'கள்ளக்குறிச்சி குறைதீர்க்கும் தளத்தில் இணையுங்கள்.'
                                        : 'Join the Kallakurichi Grievance Portal.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xFF6E6E6E),
                                      fontSize: isTablet ? 14 : 12.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Full Name Input
                                  CustomInputField(
                                    controller: _fullNameController,
                                    hintText: isTamil ? 'முழு பெயர் *' : 'Full Name *',
                                    prefixIcon: Icons.person_outline_rounded,
                                  ),

                                  const SizedBox(height: 14),

                                  // Mobile Number Input
                                  CustomInputField(
                                    controller: _mobileController,
                                    hintText: isTamil ? 'கைபேசி எண் *' : 'Mobile Number *',
                                    prefixText: '+91 ',
                                    keyboardType: TextInputType.phone,
                                    maxLength: 10,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                  ),

                                  const SizedBox(height: 14),

                                  // Date of Birth Input
                                  CustomInputField(
                                    controller: _dobController,
                                    hintText: isTamil
                                        ? 'பிறந்த தேதி (தேதி/மாதம்/வருடம்) *'
                                        : 'Date of Birth (DD/MM/YYYY) *',
                                    prefixIcon: Icons.calendar_today_outlined,
                                    readOnly: true,
                                    onTap: _selectDateOfBirth,
                                  ),

                                  const SizedBox(height: 14),

                                   // Address Input (Spacious 3-line Textarea)
                                   CustomInputField(
                                     controller: _addressController,
                                     hintText: isTamil ? 'முழு முகவரி (கட்டாயம்) *' : 'Full Residential Address (Required) *',
                                     prefixIcon: Icons.location_on_outlined,
                                     maxLines: 3,
                                   ),

                                  const SizedBox(height: 20),

                                  // MPIN Section Header
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      isTamil
                                          ? '4-இலக்க MPIN-ஐ உருவாக்கவும்'
                                          : 'CREATE 4-DIGIT MPIN',
                                      style: TextStyle(
                                        color: const Color(0xFF8E7A7A),
                                        fontSize: isTablet ? 11.5 : 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // 4 Digit MPIN Inputs Widget
                                  MpinInputWidget(
                                    controllers: _pinControllers,
                                    focusNodes: _pinFocusNodes,
                                  ),

                                  const SizedBox(height: 26),

                                  // Register Action Button Widget
                                  CustomButton(
                                    text: isTamil ? 'பதிவு செய்க' : 'Register',
                                    onPressed: _onRegisterPressed,
                                    height: isTablet ? 56 : 50,
                                    isLoading: _isLoading,
                                  ),

                                  const SizedBox(height: 18),

                                  // Footer Login Link
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        isTamil
                                            ? 'ஏற்கனவே கணக்கு உள்ளதா? '
                                            : 'Already have an account? ',
                                        style: TextStyle(
                                          color: const Color(0xFF6E6E6E),
                                          fontSize: isTablet ? 14 : 12.5,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (context) => LoginScreen(
                                                  selectedLanguage:
                                                      widget.selectedLanguage),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          isTamil ? 'உள்நுழையவும்' : 'Login',
                                          style: TextStyle(
                                            color: const Color(0xFF750000),
                                            fontSize: isTablet ? 14 : 12.5,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                 ],
                               ),
                             ],
                           ),
                         ),

                            const SizedBox(height: 16),

                            // Subtle Footer Branding
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF750000),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'TVK',
                                      style: TextStyle(
                                        color: AppColors.goldAccent,
                                        fontSize: 6.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'TVK Grievance Portal • Kallakurichi',
                                  style: TextStyle(
                                    color: const Color(0xFF8E7A7A),
                                    fontSize: isTablet ? 12 : 10.5,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}
}
