import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../../../shell/presentation/screens/main_shell_screen.dart';
import '../widgets/terms_section_card.dart';

class TermsOfServiceScreen extends StatelessWidget {
  final String selectedLanguage;

  const TermsOfServiceScreen({
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

    final termsSections = [
      {
        'icon': Icons.description_rounded,
        'titleEn': 'ACCEPTANCE OF TERMS',
        'titleTa': 'விதிமுறைகளை ஏற்றுக்கொள்ளுதல்',
        'contentEn':
            'By downloading, accessing, or using the TVK Grievance Redressal Portal, citizens agree to abide by these official terms of service, community guidelines, and administrative policies.',
        'contentTa':
            'TVK புகார் செயலியைப் பதிவிறக்கம் செய்து பயன்படுத்துவதன் மூலம், பொதுமக்கள் இச்சேவை விதிமுறைகள், சமூக வழிகாட்டுதல்கள் மற்றும் நிர்வாகக் கொள்கைகளுக்குக் கட்டுப்பட ஒப்புக்கொள்கிறார்கள்.',
      },
      {
        'icon': Icons.edit_note_rounded,
        'titleEn': 'PETITION SUBMISSION GUIDELINES',
        'titleTa': 'மனுக்கள் சமர்ப்பிக்கும் வழிகாட்டுதல்கள்',
        'contentEn':
            'Citizens must provide accurate personal details and authentic grievance descriptions. Submitting false, misleading, defamatory, offensive, or abusive content is strictly prohibited.',
        'contentTa':
            'பொதுமக்கள் தங்களின் உண்மையான தகவல்கள் மற்றும் துல்லியமான புகார் விவரங்களை மட்டுமே வழங்க வேண்டும். தவறான, தவறாக வழிநடத்தும் அல்லது அவதூறான கருத்துகளைச் சமர்ப்பிக்கக் கூடாது.',
      },
      {
        'icon': Icons.gavel_rounded,
        'titleEn': 'INTELLECTUAL PROPERTY & BRANDING',
        'titleTa': 'அறிவுசார் சொத்துரிமை',
        'contentEn':
            'All party logos, trademarks, portal designs, and official seals of Tamilaga Vetri Kazhagam (TVK) are protected by applicable intellectual property laws and copyright regulations.',
        'contentTa':
            'தமிழக வெற்றிக் கழகம் (TVK) கட்சியின் சின்னங்கள், வர்த்தக முத்திரைகள் மற்றும் செயலி வடிவமைப்பு ஆகியவை அறிவுசார் சொத்துரிமைச் சட்டங்களால் பாதுகாக்கப்பட்டவை.',
      },
      {
        'icon': Icons.account_balance_rounded,
        'titleEn': 'LIMITATION OF LIABILITY',
        'titleTa': 'பொறுப்புத் துறப்பு',
        'contentEn':
            'The TVK Grievance Portal serves as a public facilitation bridge between citizens and constituency officials. Resolution timelines depend on local administrative procedures.',
        'contentTa':
            'TVK புகார் செயலி என்பது பொதுமக்களுக்கும் தொகுதி அதிகாரிகளுக்கும் இடையேயான தொடர்பைப் பாலமாக மட்டுமே செயல்படுத்துகிறது. தீர்வுகளின் காலம் உள்ளாட்சி நிர்வாக வழிமுறைகளைப் பொறுத்தது.',
      },
      {
        'icon': Icons.balance_rounded,
        'titleEn': 'GOVERNING LAW & JURISDICTION',
        'titleTa': 'ஆளுகைச் சட்டம் & அதிகார வரம்பு',
        'contentEn':
            'These terms shall be governed by and construed in accordance with the laws of India, subject to the exclusive jurisdiction of the courts in Tamil Nadu.',
        'contentTa':
            'இவ்விதிமுறைகள் இந்தியச் சட்டங்களின்படி நிர்வகிக்கப்படும், மேலும் தமிழ்நாட்டில் உள்ள நீதிமன்றங்களின் பிரத்யேக அதிகார வரம்பிற்கு உட்பட்டது.',
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
                      isTamil ? 'சேவை விதிமுறைகள்' : 'Terms of Service',
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

                // Effective Date Pill Badge
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
                        ? 'அமல்படுத்தப்பட்ட தேதி: 14 ஆகஸ்ட் 2026'
                        : 'EFFECTIVE DATE: 14 AUG 2026',
                    style: const TextStyle(
                      color: Color(0xFFD48800),
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Terms of Service Section List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: termsSections.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = termsSections[index];
                    final title =
                        isTamil ? item['titleTa'] as String : item['titleEn'] as String;
                    final content =
                        isTamil ? item['contentTa'] as String : item['contentEn'] as String;
                    final icon = item['icon'] as IconData;

                    return TermsSectionCard(
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
