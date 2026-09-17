import 'package:flutter/material.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/widgets/app_dialog.dart';

/// Lightweight Navigation Provider for ultra-smooth tab switching.
/// Maintains active tab index and state in memory without page rebuilding.
class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  String _selectedLanguage = 'ta';

  int get currentIndex => _currentIndex;
  String get selectedLanguage => _selectedLanguage;

  NavigationProvider({int initialIndex = 0, String initialLanguage = 'ta'}) {
    final bool isUserLoggedIn = SessionService.instance.isLoggedIn;
    _currentIndex = (!isUserLoggedIn && initialIndex != 0) ? 0 : initialIndex.clamp(0, 4);
    final savedLang = SessionService.instance.savedLanguage;
    _selectedLanguage = (savedLang.isNotEmpty) ? savedLang : initialLanguage;
  }

  void setLanguage(String language) {
    if (_selectedLanguage != language) {
      _selectedLanguage = language;
      SessionService.instance.saveLanguage(language);
      notifyListeners();
    }
  }

  /// Change active tab with login authentication guard
  bool setIndex(int index, BuildContext context) {
    if (index == _currentIndex) return true;

    final bool isUserLoggedIn = SessionService.instance.isLoggedIn;

    // Tab 0 (Home) is public. Tabs 1 (Register), 2 (History), 3 (Track), 4 (Profile) require user login.
    if (index != 0 && !isUserLoggedIn) {
      AppDialog.showLoginRequired(
        context,
        selectedLanguage: _selectedLanguage,
      );
      return false;
    }

    _currentIndex = index.clamp(0, 4);
    notifyListeners();
    return true;
  }

  /// Switch tab programmatically (e.g. from Home Quick Actions or Success Screens)
  void switchToTab(int index, {BuildContext? context}) {
    final bool isUserLoggedIn = SessionService.instance.isLoggedIn;
    if (index != 0 && !isUserLoggedIn) {
      if (context != null) {
        AppDialog.showLoginRequired(
          context,
          selectedLanguage: _selectedLanguage,
        );
      }
      return;
    }
    _currentIndex = index.clamp(0, 4);
    notifyListeners();
  }
}
