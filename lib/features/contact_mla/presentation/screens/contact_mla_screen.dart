import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../../../shell/presentation/screens/main_shell_screen.dart';
import '../../data/mla_contact_api_service.dart';
import '../widgets/mla_contact_action_card.dart';
import '../widgets/mla_profile_card.dart';

class ContactMlaScreen extends StatefulWidget {
  final String selectedLanguage;

  const ContactMlaScreen({super.key, required this.selectedLanguage});

  @override
  State<ContactMlaScreen> createState() => _ContactMlaScreenState();
}

class _ContactMlaScreenState extends State<ContactMlaScreen> {
  final MlaContactApiService _contactApiService = MlaContactApiService();
  MlaContactModel _contact = MlaContactModel.defaultContact;

  @override
  void initState() {
    super.initState();
    _loadContactData();
  }

  Future<void> _loadContactData() async {
    final data = await _contactApiService.getContact();
    if (mounted) {
      setState(() {
        _contact = data;
      });
    }
  }

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MainShellScreen(
            initialIndex: 0,
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
    final size = MediaQuery.of(context).size;
    const int currentBottomIndex = 0; // Active on Home tab

    final String activeDesignation =
        isTamil ? _contact.designationTa : _contact.designationEn;
    final String activeAddress =
        isTamil ? _contact.addressTa : _contact.addressEn;
    final String activeVisitingHours =
        isTamil ? _contact.visitingHoursTa : _contact.visitingHoursEn;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F6F6),
        body: RefreshIndicator(
          color: AppColors.goldAccent,
          backgroundColor: const Color(0xFF500000),
          onRefresh: _loadContactData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            child: Column(
              children: [
                // Top Curved Deep Maroon Header Container with Overlapping Avatar
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    // 🔴 DEEP MAROON HEADER BACKGROUND
                    Container(
                      width: double.infinity,
                      height: 260,
                      decoration: const BoxDecoration(
                        color: Color(0xFF800000),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(36),
                          bottomRight: Radius.circular(36),
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? size.width * 0.15 : 20,
                            vertical: 10,
                          ),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: GestureDetector(
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
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // MLA PROFILE CARD CONTAINER
                  Padding(
                    padding: EdgeInsets.only(
                      top: 160,
                      left: isTablet ? size.width * 0.15 : 20,
                      right: isTablet ? size.width * 0.15 : 20,
                    ),
                    child: MlaProfileCard(
                      isTamil: isTamil,
                      name: _contact.name,
                      degree: _contact.degree,
                      designation: activeDesignation,
                    ),
                  ),

                  // 👤 CIRCULAR AVATAR
                  Positioned(
                    top: 92,
                    child: Container(
                      width: 148,
                      height: 148,
                      decoration: BoxDecoration(
                        color: const Color(0xFF800000),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _buildAvatarImage(_contact.fullPhotoUrl),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // CONTACT ACTION CARDS LIST
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? size.width * 0.15 : 20,
                ),
                child: Column(
                  children: [
                    // 📍 OFFICE ADDRESS
                    MlaContactActionCard(
                      icon: Icons.location_on_rounded,
                      title: isTamil ? 'அலுவலக முகவரி' : 'OFFICE ADDRESS',
                      content: activeAddress,
                      showExternalIcon: true,
                      onTap: () {},
                    ),

                    const SizedBox(height: 14),

                    // 📞 PHONE / WHATSAPP
                    MlaContactActionCard(
                      icon: Icons.phone_rounded,
                      title: isTamil
                          ? 'தொலைபேசி / வாட்ஸ்அப்'
                          : 'PHONE / WHATSAPP',
                      content: _contact.phone,
                      onTap: () {},
                    ),

                    const SizedBox(height: 14),

                    // ✉️ EMAIL ADDRESS
                    MlaContactActionCard(
                      icon: Icons.email_rounded,
                      title: isTamil ? 'மின்னஞ்சல் முகவரி' : 'EMAIL ADDRESS',
                      content: _contact.email,
                      onTap: () {},
                    ),

                    const SizedBox(height: 14),

                    // 🕒 PUBLIC VISITING HOURS
                    MlaContactActionCard(
                      icon: Icons.access_time_filled_rounded,
                      title: isTamil
                          ? 'பொதுமக்கள் பார்வையாளர் நேரம்'
                          : 'PUBLIC VISITING HOURS',
                      content: activeVisitingHours,
                      onTap: () {},
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
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

  Widget _buildAvatarImage(String photoUrl) {
    if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://')) {
      return Image.network(
        photoUrl,
        width: 148,
        height: 148,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: const Color(0xFF380000),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.goldAccent,
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackInitials();
        },
      );
    }

    return Image.asset(
      photoUrl.isNotEmpty ? photoUrl : 'assets/images/mla_photo.jpg',
      width: 148,
      height: 148,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildFallbackInitials();
      },
    );
  }

  Widget _buildFallbackInitials() {
    final initials = _contact.name.isNotEmpty
        ? _contact.name
            .trim()
            .split(' ')
            .map((e) => e.isNotEmpty ? e[0] : '')
            .take(2)
            .join()
            .toUpperCase()
        : 'AV';

    return Container(
      color: const Color(0xFF750000),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: AppColors.goldAccent,
            fontSize: 48,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
