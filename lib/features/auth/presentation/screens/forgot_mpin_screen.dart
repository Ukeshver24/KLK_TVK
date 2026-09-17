import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../shell/presentation/screens/main_shell_screen.dart';
import '../../data/auth_api_service.dart';
import 'login_screen.dart';

class ForgotMpinScreen extends StatefulWidget {
  final String selectedLanguage;

  const ForgotMpinScreen({
    super.key,
    required this.selectedLanguage,
  });

  @override
  State<ForgotMpinScreen> createState() => _ForgotMpinScreenState();
}

class _ForgotMpinScreenState extends State<ForgotMpinScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  // 4 Controllers & FocusNodes for MPIN
  final List<TextEditingController> _pinControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _pinFocusNodes = List.generate(4, (_) => FocusNode());

  final AuthApiService _authService = AuthApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _mobileController.dispose();
    _dobController.dispose();
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

  Future<void> _onResetPressed() async {
    final isTamil = widget.selectedLanguage == 'ta';

    final mobile = _mobileController.text.trim();
    if (mobile.isEmpty || !RegExp(r'^[6-9]\d{9}$').hasMatch(mobile)) {
      AppToast.showError(
        context,
        isTamil
            ? 'தயவுசெய்து சரியான 10-இலக்க கைபேசி எண்ணை உள்ளிடவும்'
            : 'Please enter a valid 10-digit mobile number',
      );
      return;
    }

    final dob = _dobController.text.trim();
    if (dob.isEmpty) {
      AppToast.showError(
        context,
        isTamil
            ? 'தயவுசெய்து உங்கள் பிறந்த தேதியைத் தேர்ந்தெடுக்கவும்'
            : 'Please select your Date of Birth',
      );
      return;
    }

    final mpin = _pinControllers.map((c) => c.text).join();
    if (mpin.length != 4) {
      AppToast.showError(
        context,
        isTamil
            ? 'தயவுசெய்து புதிய 4-இலக்க MPIN-ஐ முழுமையாக உள்ளிடவும்'
            : 'Please enter a complete 4-digit new MPIN',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _authService.resetMpin(
      mobile: mobile,
      dob: dob,
      newMpin: mpin,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.isSuccess) {
      _showResetSuccessDialog();
    } else {
      for (var controller in _pinControllers) {
        controller.clear();
      }
      _pinFocusNodes[0].requestFocus();

      AppToast.showError(
        context,
        result.message,
      );
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LoginScreen(selectedLanguage: widget.selectedLanguage),
      ),
    );
  }

  void _showResetSuccessDialog() {
    final isTamil = widget.selectedLanguage == 'ta';
    final isTablet = Responsive.isTablet(context);

    bool hasNavigated = false;

    void performNavigation() {
      if (hasNavigated) return;
      hasNavigated = true;
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop(); // Close dialog
      }
      _navigateToLogin();
    }

    // Auto-dismiss and navigate after 3 seconds
    final timer = Timer(const Duration(seconds: 3), () {
      performNavigation();
    });

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'ResetMpinSuccess',
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
                    // Success Key Badge Icon
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
                      isTamil
                          ? 'MPIN வெற்றிகரமாக மீட்டமைக்கப்பட்டது!'
                          : 'MPIN Reset Successful!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF1F0000),
                        fontSize: isTablet ? 22 : 17.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Success Description
                    Text(
                      isTamil
                          ? 'உங்கள் புதிய MPIN வெற்றிகரமாக புதுப்பிக்கப்பட்டது. உள்நுழைவுக்குச் செல்கிறது...'
                          : 'Your MPIN has been reset successfully. Redirecting to login...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF6E6E6E),
                        fontSize: isTablet ? 14 : 12.5,
                        height: 1.45,
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

                    // Proceed to Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          timer.cancel();
                          performNavigation();
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
                                isTamil
                                    ? 'உள்நுழைவுக்குச் செல்லவும்'
                                    : 'Proceed to Login',
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
                              const Spacer(),

                              // Main Reset MPIN Card Container (Centered)
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
                                      // Header Icon: Key
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
                                          Icons.vpn_key_rounded,
                                          color: AppColors.goldAccent,
                                          size: 32,
                                        ),
                                      ),

                                      const SizedBox(height: 18),

                                      // Title (Centered)
                                      Text(
                                        isTamil
                                            ? 'MPIN-ஐ மீட்டமைக்கவும்'
                                            : 'Reset MPIN',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: const Color(0xFF1F0000),
                                          fontSize: isTablet ? 28 : (isTamil ? 22 : 24),
                                          fontWeight: isTamil ? FontWeight.w700 : FontWeight.w800,
                                          letterSpacing: isTamil ? 0.2 : 0.3,
                                        ),
                                      ),

                                  const SizedBox(height: 6),

                                  // Subtitle
                                  Text(
                                    isTamil
                                        ? 'புதிய MPIN-ஐ உருவாக்க உங்கள் விவரங்களை சரிபார்க்கவும்.'
                                        : 'Verify your details to create a new MPIN.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xFF6E6E6E),
                                      fontSize: isTablet ? 14 : 12.5,
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
                                    ),
                                  ),

                                  const SizedBox(height: 26),

                                  // Mobile Number Input
                                  _buildInputField(
                                    controller: _mobileController,
                                    hintText: isTamil ? 'கைபேசி எண்' : 'Mobile Number',
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
                                  GestureDetector(
                                    onTap: _selectDateOfBirth,
                                    child: AbsorbPointer(
                                      child: _buildInputField(
                                        controller: _dobController,
                                        hintText: isTamil
                                            ? 'பிறந்த தேதி (தேதி/மாதம்/வருடம்)'
                                            : 'Date of Birth (DD/MM/YYYY)',
                                        prefixIcon: Icons.calendar_today_outlined,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // MPIN Section Header
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      isTamil
                                          ? 'புதிய 4-இலக்க MPIN'
                                          : 'NEW 4-DIGIT MPIN',
                                      style: TextStyle(
                                        color: const Color(0xFF8E7A7A),
                                        fontSize: isTablet ? 11.5 : 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // 4 Digit MPIN Inputs
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: List.generate(4, (index) {
                                      return SizedBox(
                                        width: isTablet ? 68 : 54,
                                        height: isTablet ? 60 : 52,
                                        child: TextField(
                                          controller: _pinControllers[index],
                                          focusNode: _pinFocusNodes[index],
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
                                              _pinFocusNodes[index + 1].requestFocus();
                                            } else if (value.isEmpty && index > 0) {
                                              _pinFocusNodes[index - 1].requestFocus();
                                            }
                                          },
                                        ),
                                      );
                                    }),
                                  ),

                                  const SizedBox(height: 26),

                                  // Reset & Login Action Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: isTablet ? 56 : 50,
                                    child: ElevatedButton(
                                      onPressed: _onResetPressed,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF750000),
                                        foregroundColor: AppColors.goldAccent,
                                        elevation: 8,
                                        shadowColor: const Color(0xFF750000)
                                            .withValues(alpha: 0.4),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<Color>(
                                                        AppColors.goldAccent),
                                              ),
                                            )
                                          : FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                isTamil
                                                    ? 'மீட்டமைத்து உள்நுழைக'
                                                    : 'Reset & Login',
                                                style: TextStyle(
                                                  fontSize: isTablet ? 18 : 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.goldAccent,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),

                                  const SizedBox(height: 18),

                                  // Back to Login Link (NO UNDERLINE)
                                  GestureDetector(
                                    onTap: _navigateToLogin,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.arrow_back_rounded,
                                          size: 16,
                                          color: Color(0xFF750000),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          isTamil
                                              ? 'உள்நுழைவுக்குத் திரும்பவும்'
                                              : 'Back to Login',
                                          style: TextStyle(
                                            color: const Color(0xFF750000),
                                            fontSize: isTablet ? 14 : 13,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                            const Spacer(),

                            // Subtle Footer Branding
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Row(
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    IconData? prefixIcon,
    String? prefixText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5DCDC)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          if (prefixIcon != null) ...[
            Icon(prefixIcon, color: const Color(0xFF8E7A7A), size: 20),
            const SizedBox(width: 12),
          ],
          if (prefixText != null) ...[
            Text(
              prefixText,
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
              maxLength: maxLength,
              inputFormatters: inputFormatters,
              maxLines: maxLines,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
