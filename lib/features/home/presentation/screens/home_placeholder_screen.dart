import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive.dart';

class HomePlaceholderScreen extends StatelessWidget {
  const HomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.goldAccent,
              ),
              child: const Center(
                child: Text(
                  'TVK',
                  style: TextStyle(
                    color: AppColors.primaryMaroon,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'TVK Grievance Portal',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF280000),
              Color(0xFF140000),
            ],
          ),
        ),
        child: Padding(
          padding: Responsive.screenPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Banner
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isTablet ? 24 : 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primaryMaroon,
                      AppColors.darkMaroon,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.goldAccent.withValues(alpha: 0.4),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_user_rounded,
                          color: AppColors.goldAccent,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Empowering Kallakurichi',
                          style: TextStyle(
                            color: AppColors.goldAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 18 : 14,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Welcome to TVK Public Grievance Portal',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: isTablet ? 24 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Submit your grievance directly and track resolution status transparently.',
                      style: TextStyle(
                        color: AppColors.white70,
                        fontSize: isTablet ? 14 : 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Quick Actions',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: isTablet ? 20 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Action Cards Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: isTablet ? 3 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _buildActionCard(
                      context,
                      icon: Icons.add_task_rounded,
                      title: 'New Grievance',
                      subtitle: 'Register issue with photo',
                      color: AppColors.goldAccent,
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.track_changes_rounded,
                      title: 'Track Status',
                      subtitle: 'Check grievance progress',
                      color: AppColors.white,
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.location_on_outlined,
                      title: 'Kallakurichi Wards',
                      subtitle: 'Local area overview',
                      color: AppColors.goldAccent,
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.support_agent_rounded,
                      title: 'Helpdesk',
                      subtitle: 'Contact support',
                      color: AppColors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.goldAccent.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
