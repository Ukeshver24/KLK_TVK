import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/session_service.dart';
import '../widgets/app_dialog.dart';
import '../../features/shell/presentation/providers/navigation_provider.dart';
import '../../features/shell/presentation/screens/main_shell_screen.dart';

/// Lightweight Bottom Navigation Bar that smoothly switches tabs via NavigationProvider.
/// Uses Flutter's official Material Navigation rendering with zero frame drop.
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final String selectedLanguage;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.selectedLanguage,
  });

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    final bool isUserLoggedIn = SessionService.instance.isLoggedIn;
    if (index != 0 && !isUserLoggedIn) {
      AppDialog.showLoginRequired(
        context,
        selectedLanguage: selectedLanguage,
      );
      return;
    }

    NavigationProvider? navProvider;
    try {
      navProvider = Provider.of<NavigationProvider>(context, listen: false);
    } catch (_) {
      navProvider = null;
    }

    if (navProvider != null) {
      navProvider.setIndex(index, context);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => MainShellScreen(
            initialIndex: index,
            selectedLanguage: selectedLanguage,
          ),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = selectedLanguage.trim().toLowerCase();
    final isTamil = lang == 'ta' || lang == 'tamil';

    return Container(
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
      child: BottomNavigationBar(
        currentIndex: currentIndex.clamp(0, 4),
        onTap: (index) => _onTap(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF8C0000),
        unselectedItemColor: const Color(0xFF8A7A7A),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded),
            label: isTamil ? 'முகப்பு' : 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.edit_square),
            label: isTamil ? 'பதிவு' : 'Register',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.assignment_outlined),
            label: isTamil ? 'வரலாறு' : 'History',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.location_on_outlined),
            label: isTamil ? 'நிலை' : 'Track',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline_rounded),
            label: isTamil ? 'சுயவிவரம்' : 'Profile',
          ),
        ],
      ),
    );
  }
}
