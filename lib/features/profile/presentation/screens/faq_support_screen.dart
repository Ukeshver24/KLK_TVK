import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../../../shell/presentation/screens/main_shell_screen.dart';
import '../widgets/faq_accordion_card.dart';

class FaqSupportScreen extends StatefulWidget {
  final String selectedLanguage;

  const FaqSupportScreen({
    super.key,
    required this.selectedLanguage,
  });

  @override
  State<FaqSupportScreen> createState() => _FaqSupportScreenState();
}

class _FaqSupportScreenState extends State<FaqSupportScreen> {
  int? _expandedIndex = 0; // Q1 expanded by default as shown in UI screenshot

  @override
  Widget build(BuildContext context) {
    final lang = widget.selectedLanguage.trim().toLowerCase();
    final isTamil = lang == 'ta' || lang == 'tamil';
    final isTablet = Responsive.isTablet(context);
    final size = MediaQuery.of(context).size;
    const int currentBottomIndex = 4; // Active on Profile tab

    final faqItems = [
      {
        'qEn': 'How long will it take to resolve a complaint?',
        'qTa': 'புகார் மீது நடவடிக்கை எடுக்க எவ்வளவு காலம் ஆகும்?',
        'aEn':
            'Usually, complaints are reviewed within 24–48 hours. Resolution time depends on the complexity of the issue and department availability.',
        'aTa':
            'பொதுவாக, 24-48 மணி நேரத்திற்குள் புகார்கள் பரிசீலிக்கப்படும். புகாரின் தன்மை மற்றும் துறை சார்ந்த பணிகளைப் பொறுத்து தீர்வு காணப்படும்.',
      },
      {
        'qEn': 'Can I edit my complaint after submitting?',
        'qTa': 'சமர்ப்பித்த பிறகு புகாரைத் திருத்த முடியுமா?',
        'aEn':
            'Once submitted, details cannot be edited directly. However, you can add additional notes or contact the MLA office directly.',
        'aTa':
            'சமர்ப்பித்த பிறகு விவரங்களை நேரடியாகத் திருத்த முடியாது. இருப்பினும், கூடுதல் தகவல்களை அலுவலகத்திற்குத் தெரிவிக்கலாம்.',
      },
      {
        'qEn': 'How do I contact higher officials?',
        'qTa': 'உயர் அதிகாரிகளை எவ்வாறு தொடர்பு கொள்வது?',
        'aEn':
            'You can use the "Contact MLA" feature in the app or visit the Kallakurichi MLA office during public visiting hours.',
        'aTa':
            'பயன்பாட்டில் உள்ள "Contact MLA" பக்கத்தின் மூலமாகவோ அல்லது அலுவலக வேலை நேரத்திலோ நேரடியாகச் சந்திக்கலாம்.',
      },
      {
        'qEn': 'Is my personal information secure?',
        'qTa': 'எனது தனிப்பட்ட விவரங்கள் பாதுகாப்பாக இருக்குமா?',
        'aEn':
            'Yes, all personal details and registered mobile numbers are encrypted and stored with high security protocol.',
        'aTa':
            'ஆம், உங்களின் தனிப்பட்ட விவரங்கள் மற்றும் கைபேசி எண்கள் உயர் பாதுகாப்புடன் பாதுகாக்கப்படும்.',
      },
      {
        'qEn': 'How do I receive status updates regarding my complaint?',
        'qTa': 'எனது புகார் குறித்த அறிவிப்புகளை நான் எவ்வாறு பெறுவது?',
        'aEn':
            'Status updates will be notified via Push Notifications and will also be updated live under the "Track" and "History" sections in the app.',
        'aTa':
            'புகாரின் புதிய நிலைகள் Push Notifications மூலமாகவும், பயன்பாட்டில் உள்ள "Track" மற்றும் "History" பக்கங்களிலும் நேரலையாக அறிவிக்கப்படும்.',
      },
      {
        'qEn': 'Who can use the TVK Grievance Redressal Portal?',
        'qTa': 'இந்த TVK புகார் செயலியை யாரெல்லாம் பயன்படுத்தலாம்?',
        'aEn':
            'Any citizen residing in the Kallakurichi constituency can register grievances regarding civic issues, public utilities, and infrastructure.',
        'aTa':
            'கள்ளக்குறிச்சி தொகுதியில் வசிக்கும் அனைத்து பொதுமக்களும் தங்களின் குடிநீர், சாலை, மின்சாரம் போன்ற குறைபாடுகளைப் பதிவு செய்யலாம்.',
      },
      {
        'qEn':
            'What should I do if my complaint is marked resolved but work is incomplete?',
        'qTa':
            'புகார் தீர்க்கப்பட்டதாகக் காட்டியும் வேலை முடியாவிட்டால் என்ன செய்வது?',
        'aEn':
            'You can directly contact the MLA office through the "Contact MLA" feature or re-submit a follow-up request with reference details.',
        'aTa':
            'நீங்கள் செயலியில் உள்ள "Contact MLA" வசதியைப் பயன்படுத்தி நேரடியாகத் தெரிவிக்கலாம் அல்லது புதிய கோரிக்கையை அனுப்பலாம்.',
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
              selectedLanguage: widget.selectedLanguage,
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
                      isTamil ? 'கேள்வி & உதவி' : 'FAQ & Support',
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

                // Section Header Text
                Text(
                  isTamil ? 'பொதுவான கேள்விகள்' : 'COMMON QUESTIONS',
                  style: const TextStyle(
                    color: Color(0xFF6E6E6E),
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),

                const SizedBox(height: 16),

                // Accordion Q&A List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: faqItems.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = faqItems[index];
                    final question = isTamil ? item['qTa']! : item['qEn']!;
                    final answer = isTamil ? item['aTa']! : item['aEn']!;
                    final isExpanded = _expandedIndex == index;

                    return FaqAccordionCard(
                      question: question,
                      answer: answer,
                      isExpanded: isExpanded,
                      onTap: () {
                        setState(() {
                          _expandedIndex = isExpanded ? null : index;
                        });
                      },
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
    selectedLanguage: widget.selectedLanguage,
  ),
),
);
}
}
