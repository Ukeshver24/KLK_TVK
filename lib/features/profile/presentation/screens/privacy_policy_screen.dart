import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../../../shell/presentation/screens/main_shell_screen.dart';
import '../widgets/privacy_section_card.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final String selectedLanguage;

  const PrivacyPolicyScreen({
    super.key,
    required this.selectedLanguage,
  });

  @override
  Widget build(BuildContext context) {
    final lang = selectedLanguage.trim().toLowerCase();
    final isTamil = lang == 'ta' || lang == 'tamil';
    final isTablet = Responsive.isTablet(context);
    final size = MediaQuery.of(context).size;
    const int currentBottomIndex = 4; // Active on Profile tab

    final privacySections = [
      {
        'icon': Icons.info_outline_rounded,
        'titleEn': 'GOVERNMENT & OFFICIAL DISCLAIMER',
        'titleTa': 'அதிகாரப்பூர்வ பொறுப்புத் துறப்பு',
        'contentEn':
            'Disclaimer: This application is not an official government application and does not represent any government department or government agency. It is an independent civic communication portal managed by the constituency office of MLA C. Arul Vignesh / Tamizhaga Vettri Kazhagam (TVK) to receive and facilitate citizen grievances in the Kallakurichi constituency.',
        'contentTa':
            'பொறுப்புத் துறப்பு: இந்தச் செயலி எந்தவொரு அரசுத் துறை அல்லது அரசு நிறுவனத்தின் அதிகாரப்பூர்வ செயலி அல்ல. இது கள்ளக்குறிச்சி தொகுதி சட்டமன்ற உறுப்பினர் அலுவலகம் / தமிழக வெற்றிக் கழகம் (TVK) சார்பாக தொகுதி மக்களின் குறைகளைக் கேட்டறிந்து தீர்வு காண்பதற்காக உருவாக்கப்பட்ட சுயாதீன மக்கள் குறைதீர்ப்பு செயலியாகும்.',
      },
      {
        'icon': Icons.security_rounded,
        'titleEn': 'DATA COLLECTION',
        'titleTa': 'தகவல்கள் சேகரிப்பு',
        'contentEn':
            'We collect essential citizen information such as Name, Mobile Number, Constituency, Taluk, Village, and grievance description to process and resolve public petitions effectively.',
        'contentTa':
            'பொதுமக்களின் புகார்களைத் திறம்படப் பரிசீலித்து தீர்வு காண்பதற்காக பெயர், கைபேசி எண், தொகுதி, தாலுகா, கிராமம் மற்றும் புகார் விவரங்கள் போன்ற அத்தியாவசியத் தகவல்கள் மட்டுமே சேகரிக்கப்படுகின்றன.',
      },
      {
        'icon': Icons.lock_outline_rounded,
        'titleEn': 'DATA SECURITY & ENCRYPTION',
        'titleTa': 'தகவல் பாதுகாப்பு & குறியாக்கம்',
        'contentEn':
            'All citizen personal details, photos, and video evidence are transmitted securely using SSL/TLS encryption protocols and stored on protected cloud infrastructure.',
        'contentTa':
            'பொதுமக்களின் தனிப்பட்ட விவரங்கள், புகைப்படங்கள் மற்றும் வீடியோ சான்றுகள் அனைத்தும் SSL/TLS குறியாக்கப் பாதுகாப்புடன் பாதுகாப்பான சர்வர்களில் சேமிக்கப்படுகின்றன.',
      },
      {
        'icon': Icons.assignment_ind_rounded,
        'titleEn': 'INFORMATION USAGE',
        'titleTa': 'தகவல்களின் பயன்பாடு',
        'contentEn':
            'Your data is strictly utilized by authorized TVK Grievance Officers and local constituency representatives solely for verifying and addressing public petitions.',
        'contentTa':
            'உங்களின் தகவல்கள் பொதுமக்களின் புகார்களைச் சரிபார்த்து நடவடிக்கை எடுப்பதற்காக மட்டுமே TVK புகார் அதிகாரிகளால் பயன்படுத்தப்படும்.',
      },
      {
        'icon': Icons.block_rounded,
        'titleEn': 'THIRD-PARTY SHARING',
        'titleTa': 'மூன்றாம் தரப்பு பகிர்வு',
        'contentEn':
            'TVK respects your privacy and will never sell, rent, or share citizen personal information with external commercial entities or unauthorized third parties.',
        'contentTa':
            'TVK உங்களின் தனியுரிமையை மதிக்கிறது. பொதுமக்களின் தனிப்பட்ட தகவல்கள் எக்காரணம் கொண்டும் வர்த்தக நிறுவனங்களுக்கோ அல்லது மூன்றாம் தரப்பினருக்கோ விற்கப்படவோ அல்லது பகிரப்படவோ மாட்டாது.',
      },
      {
        'icon': Icons.contact_support_rounded,
        'titleEn': 'PRIVACY CONTACT',
        'titleTa': 'தனியுரிமை தொடர்புக்கு',
        'contentEn':
            'If you have any questions regarding our privacy practices or wish to update your registered information, please contact privacy@tvk.in or visit the Kallakurichi MLA Office.',
        'contentTa':
            'எங்களின் தனியுரிமைக் கொள்கை குறித்த சந்தேகங்களுக்கு privacy@tvk.in என்ற மின்னஞ்சல் அல்லது அலுவலகத்தை நேரடியாகத் தொடர்பு கொள்ளலாம்.',
      },
    ];

    void handleBack() {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainShellScreen(
              initialIndex: 4,
              selectedLanguage: selectedLanguage,
            ),
          ),
        );
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        handleBack();
      },
      child: Scaffold(
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
                    GestureDetector(
                      onTap: handleBack,
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
                    Text(
                      isTamil ? 'தனியுரிமைக் கொள்கை' : 'Privacy Policy',
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

                // Last Updated Date Pill Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7E6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFE58F)),
                  ),
                  child: Text(
                    isTamil
                        ? 'கடைசியாக புதுப்பிக்கப்பட்டது: 14 ஆகஸ்ட் 2026'
                        : 'LAST UPDATED: 14 AUG 2026',
                    style: const TextStyle(
                      color: Color(0xFFD48800),
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Privacy Policy Section List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: privacySections.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = privacySections[index];
                    final title =
                        isTamil ? item['titleTa'] as String : item['titleEn'] as String;
                    final content =
                        isTamil ? item['contentTa'] as String : item['contentEn'] as String;
                    final icon = item['icon'] as IconData;

                    return PrivacySectionCard(
                      icon: icon,
                      title: title,
                      content: content,
                    );
                  },
                ),

                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ],
    ),
  ),

  // Bottom Navigation Bar
  bottomNavigationBar: CustomBottomNavBar(
    currentIndex: currentBottomIndex,
    selectedLanguage: selectedLanguage,
  ),
),
);
}
}
