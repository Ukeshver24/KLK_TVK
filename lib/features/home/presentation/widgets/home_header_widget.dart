import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/session_service.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class HomeHeaderWidget extends StatelessWidget {
  final bool isTamil;
  final bool isLoggedIn;
  final String? userName;

  const HomeHeaderWidget({
    super.key,
    required this.isTamil,
    required this.isLoggedIn,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final sessionUser = SessionService.instance.userName;
    final displayName = userName ?? sessionUser;
    final bool isUserLoggedIn =
        (isLoggedIn || SessionService.instance.isLoggedIn) &&
            displayName.isNotEmpty;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Side: User Avatar & Greeting / Login Button
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Sleek Compact User Avatar
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.goldAccent,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Color(0xFF500000),
                size: 22,
              ),
            ),
            const SizedBox(width: 10),

            // User Info or Compact Login Pill
            isUserLoggedIn
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isTamil ? 'வணக்கம்' : 'VANAKKAM',
                        style: const TextStyle(
                          color: AppColors.goldAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: isTamil ? FontWeight.w700 : FontWeight.w800,
                        ),
                      ),
                    ],
                  )
                : InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(
                            selectedLanguage: isTamil ? 'ta' : 'en',
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.goldAccent,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.login_rounded,
                            color: Color(0xFF500000),
                            size: 15,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isTamil ? 'உள்நுழைக' : 'Login',
                            style: const TextStyle(
                              color: Color(0xFF500000),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),

        // Right Side: Small TVK Constituency Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.goldAccent.withValues(alpha: 0.3),
              width: 0.8,
            ),
          ),
          child: Text(
            isTamil ? 'கள்ளக்குறிச்சி' : 'Kallakurichi',
            style: const TextStyle(
              color: AppColors.goldAccent,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}
