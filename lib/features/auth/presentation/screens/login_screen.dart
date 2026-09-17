import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../shell/presentation/screens/main_shell_screen.dart';
import '../../data/auth_api_service.dart';
import 'forgot_mpin_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final String selectedLanguage;

  const LoginScreen({
    super.key,
    required this.selectedLanguage,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mobileController = TextEditingController();

  // 4 Controllers & FocusNodes for MPIN
  final List<TextEditingController> _pinControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _pinFocusNodes = List.generate(4, (_) => FocusNode());

  final AuthApiService _authService = AuthApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _mobileController.dispose();
    for (var controller in _pinControllers) {
      controller.dispose();
    }
    for (var focusNode in _pinFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    final isTamil = widget.selectedLanguage == 'ta';

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final mpin = _pinControllers.map((c) => c.text).join();
    if (mpin.length != 4) {
      AppToast.showError(
        context,
        isTamil
            ? 'தயவுசெய்து 4-இலக்க MPIN-ஐ முழுமையாக உள்ளிடவும்'
            : 'Please enter a complete 4-digit MPIN',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _authService.login(
      mobile: _mobileController.text,
      mpin: mpin,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.isSuccess) {
      if (result.data != null) {
        await SessionService.instance.saveUser(result.data!);
      }
      // Sync device FCM push token with backend
      final currentFcmToken = PushNotificationService.instance.fcmToken;
      if (currentFcmToken != null && currentFcmToken.isNotEmpty) {
        _authService.syncFcmToken(currentFcmToken);
      }
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => MainShellScreen(
            selectedLanguage: widget.selectedLanguage,
          ),
        ),
        (route) => false,
      );
    } else {
      // Clear MPIN on error so user can re-type fresh
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

  void _navigateToRegister() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            RegisterScreen(selectedLanguage: widget.selectedLanguage),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTamil = widget.selectedLanguage == 'ta';
    final isTablet = Responsive.isTablet(context);

    return Scaffold(
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
                        horizontal:
                            isTablet ? constraints.maxWidth * 0.22 : 24,
                        vertical: 24,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const Spacer(),

                            // Center Content Card
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(isTablet ? 32 : 24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: AppColors.primaryMaroon
                                      .withValues(alpha: 0.1),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryMaroon
                                        .withValues(alpha: 0.08),
                                    blurRadius: 28,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Back Button to Main Screen
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    child: InkWell(
                                      onTap: () {
                                        if (Navigator.of(context).canPop()) {
                                          Navigator.of(context).pop();
                                        } else {
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MainShellScreen(
                                                selectedLanguage:
                                                    widget.selectedLanguage,
                                              ),
                                            ),
                                          );
                                        }
                                      },
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
                                      // Top Badge Icon
                                      Container(
                                        width: 68,
                                        height: 68,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFF8C0000),
                                              Color(0xFF5E0000),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(22),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF750000)
                                                  .withValues(alpha: 0.35),
                                              blurRadius: 18,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.login_rounded,
                                          color: AppColors.goldAccent,
                                          size: 34,
                                        ),
                                      ),

                                      const SizedBox(height: 22),

                                      // Title (Centered)
                                      Text(
                                        isTamil ? 'மீண்டும் வருக' : 'Welcome Back',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: const Color(0xFF1F0000),
                                          fontSize: isTablet ? 28 : (isTamil ? 22 : 24),
                                          fontWeight: isTamil ? FontWeight.w700 : FontWeight.w800,
                                          letterSpacing: isTamil ? 0.2 : 0.3,
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      // Subtitle
                                      Text(
                                        isTamil
                                            ? 'உங்கள் புகார்களைக் கண்காணிக்க கள்ளக்குறிச்சி குறைதீர்க்கும் தளத்தில் உள்நுழையவும்.'
                                            : 'Log in to Kallakurichi Grievance Portal to track your issues.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: const Color(0xFF6E6E6E),
                                          fontSize: isTablet ? 14.5 : 13,
                                          fontWeight: FontWeight.w500,
                                          height: isTamil ? 1.5 : 1.45,
                                        ),
                                      ),

                                      const SizedBox(height: 28),

                                      // Mobile Number Input
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8F5F5),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: const Color(0xFFE5DCDC),
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 4,
                                        ),
                                        child: Row(
                                          children: [
                                            const Text(
                                              '+91 ',
                                              style: TextStyle(
                                                color: Color(0xFF6B0000),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            Container(
                                              height: 20,
                                              width: 1,
                                              color: const Color(0xFFD4C5C5),
                                              margin: const EdgeInsets.only(
                                                  right: 12),
                                            ),
                                            Expanded(
                                              child: TextFormField(
                                                controller: _mobileController,
                                                keyboardType:
                                                    TextInputType.phone,
                                                maxLength: 10,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                  LengthLimitingTextInputFormatter(
                                                      10),
                                                ],
                                                style: const TextStyle(
                                                  color: Color(0xFF2C0000),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14.5,
                                                ),
                                                decoration: InputDecoration(
                                                  counterText: '',
                                                  hintText: isTamil
                                                      ? 'கைபேசி எண்'
                                                      : 'Mobile Number',
                                                  hintStyle: const TextStyle(
                                                    color: Color(0xFF9E9E9E),
                                                    fontWeight:
                                                        FontWeight.w500,
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

                                      // MPIN Section Label
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          isTamil ? '4-இலக்க MPIN' : '4-DIGIT MPIN',
                                          style: const TextStyle(
                                            color: Color(0xFF6E6E6E),
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      // 4-Box MPIN Input Row
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: List.generate(4, (index) {
                                          return SizedBox(
                                            width: isTablet ? 64 : 52,
                                            height: isTablet ? 64 : 52,
                                            child: TextFormField(
                                              controller:
                                                  _pinControllers[index],
                                              focusNode:
                                                  _pinFocusNodes[index],
                                              keyboardType:
                                                  TextInputType.number,
                                              textAlign: TextAlign.center,
                                              obscureText: true,
                                              obscuringCharacter: '●',
                                              maxLength: 1,
                                              style: TextStyle(
                                                fontSize: isTablet ? 24 : 20,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF500000),
                                              ),
                                              decoration: InputDecoration(
                                                counterText: '',
                                                filled: true,
                                                fillColor:
                                                    const Color(0xFFF8F5F5),
                                                contentPadding:
                                                    EdgeInsets.zero,
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  borderSide: const BorderSide(
                                                    color: Color(0xFFE5DCDC),
                                                    width: 1.2,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  borderSide: const BorderSide(
                                                    color: Color(0xFF750000),
                                                    width: 2.0,
                                                  ),
                                                ),
                                              ),
                                              onChanged: (value) {
                                                if (value.isNotEmpty &&
                                                    index < 3) {
                                                  _pinFocusNodes[index + 1]
                                                      .requestFocus();
                                                } else if (value.isEmpty &&
                                                    index > 0) {
                                                  _pinFocusNodes[index - 1]
                                                      .requestFocus();
                                                }
                                              },
                                            ),
                                          );
                                        }),
                                      ),

                                      const SizedBox(height: 12),

                                      // Forgot MPIN link
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ForgotMpinScreen(
                                                  selectedLanguage: widget
                                                      .selectedLanguage,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            isTamil
                                                ? 'MPIN மறந்துவிட்டதா?'
                                                : 'Forgot MPIN?',
                                            style: TextStyle(
                                              color: const Color(0xFF750000),
                                              fontSize: isTablet ? 13 : 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 28),

                                      // Login Action Button
                                      SizedBox(
                                        width: double.infinity,
                                        height: isTablet ? 56 : 52,
                                        child: ElevatedButton(
                                          onPressed: _isLoading
                                              ? () {}
                                              : _onLoginPressed,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF750000),
                                            foregroundColor:
                                                AppColors.goldAccent,
                                            elevation: 8,
                                            shadowColor:
                                                const Color(0xFF750000)
                                                    .withValues(alpha: 0.4),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          child: _isLoading
                                              ? const SizedBox(
                                                  width: 22,
                                                  height: 22,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2.2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            AppColors
                                                                .goldAccent),
                                                  ),
                                                )
                                              : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      isTamil
                                                          ? 'உள்நுழைக'
                                                          : 'Login',
                                                      style: TextStyle(
                                                        fontSize: isTablet
                                                            ? 18
                                                            : 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors
                                                            .goldAccent,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    const Icon(
                                                      Icons
                                                          .arrow_forward_rounded,
                                                      color:
                                                          AppColors.goldAccent,
                                                      size: 20,
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),

                                      const SizedBox(height: 22),

                                      // Footer Register Link
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            isTamil
                                                ? 'கணக்கு இல்லையா? '
                                                : "Don't have an account? ",
                                            style: TextStyle(
                                              color: const Color(0xFF6E6E6E),
                                              fontSize:
                                                  isTablet ? 14 : 12.5,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: _navigateToRegister,
                                            child: Text(
                                              isTamil
                                                  ? 'பதிவு செய்க'
                                                  : 'Register',
                                              style: TextStyle(
                                                color:
                                                    const Color(0xFF750000),
                                                fontSize:
                                                    isTablet ? 14 : 12.5,
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

                            const Spacer(),

                            // Subtle Footer Branding
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
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
    );
  }
}
