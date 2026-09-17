import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/services/session_service.dart';
import '../providers/navigation_provider.dart';
import '../../../home/presentation/screens/home_dashboard_screen.dart';
import '../../../complaint/presentation/screens/register_complaint_step1_screen.dart';
import '../../../history/presentation/screens/my_complaints_history_screen.dart';
import '../../../track/presentation/screens/track_complaint_screen.dart';
import '../../../profile/presentation/screens/profile_settings_screen.dart';

class MainShellScreen extends StatelessWidget {
  final int initialIndex;
  final String selectedLanguage;

  const MainShellScreen({
    super.key,
    this.initialIndex = 0,
    this.selectedLanguage = 'ta',
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavigationProvider(
        initialIndex: initialIndex,
        initialLanguage: selectedLanguage,
      ),
      child: const _MainShellView(),
    );
  }
}

class _MainShellView extends StatefulWidget {
  const _MainShellView();

  @override
  State<_MainShellView> createState() => _MainShellViewState();
}

class _MainShellViewState extends State<_MainShellView> {
  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    final currentIndex = navProvider.currentIndex;
    final selectedLanguage = navProvider.selectedLanguage;
    final lang = selectedLanguage.trim().toLowerCase();
    final isTamil = lang == 'ta' || lang == 'tamil';

    final pages = [
      HomeDashboardScreen(
        key: const PageStorageKey('HomeDashboardScreen'),
        selectedLanguage: selectedLanguage,
        isLoggedIn: SessionService.instance.isLoggedIn,
        isNestedInShell: true,
      ),
      RegisterComplaintStep1Screen(
        key: const PageStorageKey('RegisterComplaintStep1Screen'),
        selectedLanguage: selectedLanguage,
        isNestedInShell: true,
      ),
      MyComplaintsHistoryScreen(
        key: const PageStorageKey('MyComplaintsHistoryScreen'),
        selectedLanguage: selectedLanguage,
        isNestedInShell: true,
      ),
      TrackComplaintScreen(
        key: const PageStorageKey('TrackComplaintScreen'),
        selectedLanguage: selectedLanguage,
        isNestedInShell: true,
      ),
      ProfileSettingsScreen(
        key: const PageStorageKey('ProfileSettingsScreen'),
        selectedLanguage: selectedLanguage,
        onLanguageChanged: (newLang) {
          context.read<NavigationProvider>().setLanguage(newLang);
        },
        isNestedInShell: true,
      ),
    ];

    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (currentIndex != 0) {
          navProvider.setIndex(0, context);
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F6F6),
        body: IndexedStack(
          index: currentIndex,
          children: pages,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: AppColors.goldAccent.withValues(alpha: 0.25),
              labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
                (Set<WidgetState> states) {
                  final isSelected = states.contains(WidgetState.selected);
                  return TextStyle(
                    fontFamily: isTamil ? AppFonts.fontFamilyTamil : AppFonts.fontFamilyEnglish,
                    fontFamilyFallback: const [AppFonts.fontFamilyTamil, AppFonts.fontFamilyEnglish],
                    color: isSelected ? const Color(0xFF8C0000) : const Color(0xFF8A7A7A),
                    fontSize: isTamil ? 10.0 : 11.0,
                    fontWeight: isSelected ? (isTamil ? FontWeight.w700 : FontWeight.bold) : FontWeight.w500,
                    letterSpacing: isTamil ? 0.0 : 0.2,
                  );
                },
              ),
              iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return const IconThemeData(
                      color: Color(0xFF8C0000),
                      size: 24,
                    );
                  }
                  return const IconThemeData(
                    color: Color(0xFF8A7A7A),
                    size: 24,
                  );
                },
              ),
            ),
            child: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) {
                navProvider.setIndex(index, context);
              },
              backgroundColor: Colors.white,
              elevation: 0,
              height: 65,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home_rounded),
                  label: isTamil ? 'முகப்பு' : 'Home',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.edit_note_outlined),
                  selectedIcon: const Icon(Icons.edit_square),
                  label: isTamil ? 'பதிவு' : 'Register',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.assignment_outlined),
                  selectedIcon: const Icon(Icons.assignment_rounded),
                  label: isTamil ? 'வரலாறு' : 'History',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.location_on_outlined),
                  selectedIcon: const Icon(Icons.location_on_rounded),
                  label: isTamil ? 'நிலை' : 'Track',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline_rounded),
                  selectedIcon: const Icon(Icons.person_rounded),
                  label: isTamil ? 'சுயவிவரம்' : 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
