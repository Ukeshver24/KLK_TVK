import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/utils/responsive.dart';
import '../../../shell/presentation/screens/main_shell_screen.dart';
import '../widgets/language_toggle_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Selected language state: defaults to 'en'
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _selectedLanguage = SessionService.instance.savedLanguage;
  }

  void _onLanguageSelected(String lang) {
    setState(() {
      _selectedLanguage = lang;
    });
    SessionService.instance.saveLanguage(lang);
  }

  void _onContinuePressed() {
    SessionService.instance.saveLanguage(_selectedLanguage);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MainShellScreen(
          initialIndex: 0,
          selectedLanguage: _selectedLanguage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
    final size = MediaQuery.of(context).size;
    final isTamil = _selectedLanguage == 'ta';

    return Scaffold(
      backgroundColor: const Color(0xFF7A0000),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8C0000),
              Color(0xFF7A0000),
              Color(0xFF680000),
              Color(0xFF4E0000),
            ],
            stops: [0.0, 0.35, 0.70, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? size.width * 0.15 : 20,
            ),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.03),

                // Top Header (Tamil 'தமிழக வெற்றிக் கழகம்' in Yellow Gold + Subtitles)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'தமிழக வெற்றிக் கழகம்',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.goldAccent,
                          fontSize: isTablet ? 32 : 23,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.6),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'G R I E V A N C E   P O R T A L',
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.95),
                        fontSize: isTablet ? 14 : 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'கள்ளக்குறிச்சி சட்டமன்ற தொகுதி',
                      style: TextStyle(
                        color: AppColors.goldLight.withValues(alpha: 0.9),
                        fontSize: isTablet ? 13 : 10.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),

                // Balanced Top Spacer to center the card vertically
                const Spacer(flex: 2),

                // Centered Language & Welcome Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 28 : 22,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF560000).withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: AppColors.goldAccent.withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Welcome Title
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          isTamil ? 'மக்கள் குரல்' : "People's Voice",
                          key: ValueKey('welcome_$isTamil'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: isTablet ? 26 : 22,
                            fontWeight: isTamil ? FontWeight.w700 : FontWeight.w800,
                            letterSpacing: isTamil ? 0.2 : 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Welcome Subtitle
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          isTamil
                              ? 'உங்கள் தலைவர்களிடம் நேரடியாக புகார்களை தெரிவியுங்கள். உடனுக்குடன் நிலவரத்தை அறிந்து கொண்டு சிறந்த கள்ளக்குறிச்சியை உருவாக்குவோம்.'
                              : 'Directly voice your complaints to your leaders. Track real-time progress and build a better Kallakurichi.',
                          key: ValueKey('desc_$isTamil'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.white70,
                            fontSize: isTablet ? 14 : 12.5,
                            height: isTamil ? 1.5 : 1.4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Choose Language Label
                      Center(
                        child: Text(
                          isTamil
                              ? 'மொழியைத் தேர்ந்தெடுக்கவும்'
                              : 'SELECT LANGUAGE',
                          style: const TextStyle(
                            color: AppColors.goldAccent,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Language Selector Toggle Widget
                      LanguageToggleWidget(
                        selectedLanguage: _selectedLanguage,
                        onLanguageSelected: _onLanguageSelected,
                      ),

                      const SizedBox(height: 22),

                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        height: isTablet ? 56 : 50,
                        child: ElevatedButton(
                          onPressed: _onContinuePressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.goldAccent,
                            foregroundColor: const Color(0xFF4A0000),
                            elevation: 8,
                            shadowColor: AppColors.goldAccent.withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isTamil ? 'தொடரவும்' : 'Continue',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: Color(0xFF4A0000),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Balanced Bottom Spacer
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
