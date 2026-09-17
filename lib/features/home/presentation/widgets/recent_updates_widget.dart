import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/utils/app_date_formatter.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../complaint/data/complaint_api_service.dart';
import '../../../complaint/presentation/screens/register_complaint_step1_screen.dart';
import '../../../history/presentation/screens/complaint_details_screen.dart';
import '../../../history/presentation/screens/my_complaints_history_screen.dart';

class RecentUpdatesWidget extends StatefulWidget {
  final bool isTamil;

  const RecentUpdatesWidget({
    super.key,
    required this.isTamil,
  });

  @override
  State<RecentUpdatesWidget> createState() => _RecentUpdatesWidgetState();
}

class _RecentUpdatesWidgetState extends State<RecentUpdatesWidget> {
  bool _isLoading = true;
  List<ComplaintModel> _complaints = [];
  final ComplaintApiService _apiService = ComplaintApiService();

  @override
  void initState() {
    super.initState();
    _loadRecentComplaints();
  }

  @override
  void didUpdateWidget(covariant RecentUpdatesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isTamil != widget.isTamil) {
      _loadRecentComplaints();
    }
  }

  Future<void> _loadRecentComplaints() async {
    if (!SessionService.instance.isLoggedIn) {
      if (mounted) {
        setState(() {
          _complaints = [];
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final user = SessionService.instance.currentUser;
      if (user != null && user.id.isNotEmpty) {
        final results = await _apiService.getMyComplaints(user.id);
        if (mounted) {
          setState(() {
            _complaints = results.take(3).toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _complaints = [];
            _isLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _complaints = [];
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(String isoString) {
    return AppDateFormatter.formatDateTime(isoString);
  }

  void _onViewComplaint(ComplaintModel item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ComplaintDetailsScreen(
          selectedLanguage: widget.isTamil ? 'ta' : 'en',
          referenceId: item.referenceId,
          citizenId: item.citizenId,
          status: item.status,
          statusReason: item.statusReason,
          adminRemarks: item.adminRemarks,
          timelineEvents: item.timelineEvents,
          attachment: item.attachment,
          latitude: item.latitude,
          longitude: item.longitude,
          locationUrl: item.locationUrl,
          date: _formatDate(item.createdAt),
        ),
      ),
    ).then((_) {
      if (mounted) _loadRecentComplaints();
    });
  }

  void _onViewAll() {
    if (!SessionService.instance.isLoggedIn) {
      AppDialog.showLoginRequired(
        context,
        selectedLanguage: widget.isTamil ? 'ta' : 'en',
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MyComplaintsHistoryScreen(
          selectedLanguage: widget.isTamil ? 'ta' : 'en',
        ),
      ),
    ).then((_) {
      if (mounted) _loadRecentComplaints();
    });
  }

  void _onRegisterComplaint() {
    if (!SessionService.instance.isLoggedIn) {
      AppDialog.showLoginRequired(
        context,
        selectedLanguage: widget.isTamil ? 'ta' : 'en',
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RegisterComplaintStep1Screen(
          selectedLanguage: widget.isTamil ? 'ta' : 'en',
        ),
      ),
    ).then((_) {
      if (mounted) _loadRecentComplaints();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTamil = widget.isTamil;
    final isLoggedIn = SessionService.instance.isLoggedIn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // RECENT GRIEVANCES HEADER & VIEW ALL
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  isTamil ? 'சமீபத்திய மனுக்கள்' : 'RECENT GRIEVANCES',
                  style: const TextStyle(
                    color: Color(0xFF6E6E6E),
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                if (isLoggedIn && _complaints.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF750000).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_complaints.length}',
                      style: const TextStyle(
                        color: Color(0xFF750000),
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (isLoggedIn && _complaints.isNotEmpty)
              GestureDetector(
                onTap: _onViewAll,
                child: Text(
                  isTamil ? 'அனைத்தும்' : 'VIEW ALL',
                  style: const TextStyle(
                    color: Color(0xFF750000),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 14),

        // BODY CONTENT: Loading / Grievance Cards / No Recent Grievance Empty State
        if (_isLoading) ...[
          // Shimmer loading card
          Shimmer.fromColors(
            baseColor: const Color(0xFFE8E2E2),
            highlightColor: const Color(0xFFFAF7F7),
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ] else if (!isLoggedIn || _complaints.isEmpty) ...[
          // 📭 NO RECENT GRIEVANCE EMPTY STATE CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFEBE5E5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F0),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFD4D1)),
                  ),
                  child: const Icon(
                    Icons.assignment_late_outlined,
                    color: Color(0xFF8C0000),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  isTamil ? 'சமீபத்திய புகார்கள் எதுவும் இல்லை' : 'No Recent Grievance',
                  style: const TextStyle(
                    color: Color(0xFF1E1E1E),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isTamil
                      ? 'நீங்கள் இதுவரை எந்த மனுவும் சமர்ப்பிக்கவில்லை. உங்கள் பகுதி பிரச்சனைகளை தெரிவிக்க கீழே கிளிக் செய்யவும்.'
                      : "You haven't submitted any grievances yet. Tap below to raise a new petition for your constituency.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF7E6E6E),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                InkWell(
                  onTap: _onRegisterComplaint,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8C0000),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8C0000).withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add_circle_outline_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isTamil ? 'புதிய மனு பதிவு செய்க' : 'Register Grievance',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // 📋 DISPLAY REAL RECENT GRIEVANCES (Latest 3)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _complaints.length > 3 ? 3 : _complaints.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = _complaints[index];
              return _buildRecentGrievanceCard(item, isTamil);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildRecentGrievanceCard(ComplaintModel item, bool isTamil) {
    Color stripColor;
    Color badgeBg;
    Color badgeText;
    String statusLabel;

    final normStatus = item.status.toUpperCase().replaceAll(' ', '_');

    switch (normStatus) {
      case 'RESOLVED':
        stripColor = const Color(0xFF389E0D);
        badgeBg = const Color(0xFFF6FFED);
        badgeText = const Color(0xFF389E0D);
        statusLabel = isTamil ? 'தீர்வு காணப்பட்டது' : 'RESOLVED';
        break;
      case 'IN_PROGRESS':
      case 'ACTION_TAKEN':
        stripColor = const Color(0xFF096DD9);
        badgeBg = const Color(0xFFE6F7FF);
        badgeText = const Color(0xFF096DD9);
        statusLabel = isTamil ? 'களப்பணியில்' : 'IN PROGRESS';
        break;
      case 'OFFICER_ASSIGNED':
        stripColor = const Color(0xFF4F46E5);
        badgeBg = const Color(0xFFEEF2FF);
        badgeText = const Color(0xFF4F46E5);
        statusLabel = isTamil ? 'பொறுப்பாளர் ஒதுக்கீடு' : 'OFFICER ASSIGNED';
        break;
      case 'UNDER_REVIEW':
      case 'IN_REVIEW':
        stripColor = const Color(0xFFD48800);
        badgeBg = const Color(0xFFFFF7E6);
        badgeText = const Color(0xFFD48800);
        statusLabel = isTamil ? 'பரிசீலனையில்' : 'IN REVIEW';
        break;
      case 'OTHERS':
        stripColor = const Color(0xFF7E22CE);
        badgeBg = const Color(0xFFFAF5FF);
        badgeText = const Color(0xFF7E22CE);
        statusLabel = isTamil ? 'நிர்வாகக் குறிப்பு' : 'REMARKS / NOTES';
        break;
      case 'SUBMITTED':
      default:
        stripColor = const Color(0xFFCF1322);
        badgeBg = const Color(0xFFFFF1F0);
        badgeText = const Color(0xFFCF1322);
        statusLabel = isTamil ? 'புதிய மனு' : 'SUBMITTED';
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBE5E5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Vertical Color Strip Accent
              Container(
                width: 6,
                color: stripColor,
              ),

              // Card Content Padding
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Reference ID & Status Badge Pill
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.referenceId,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF750000),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                color: badgeText,
                                fontSize: isTamil ? 10 : 10.5,
                                fontWeight: isTamil ? FontWeight.w700 : FontWeight.bold,
                                letterSpacing: isTamil ? 0.0 : 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Category & Village Location
                      Row(
                        children: [
                          const Icon(
                            Icons.category_outlined,
                            size: 13,
                            color: Color(0xFF8E7E7E),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              '${item.category} • ${item.village}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF4A3A3A),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Description Snippet
                      if (item.description.isNotEmpty) ...[
                        Text(
                          item.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF7E6E6E),
                            fontSize: 11.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

                      const Divider(height: 1, color: Color(0xFFF5EEEE)),

                      const SizedBox(height: 10),

                      // Bottom Row: Date & Compact View Action Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 13,
                                color: Color(0xFF9E8E8E),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _formatDate(item.createdAt),
                                style: const TextStyle(
                                  color: Color(0xFF8E7E7E),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          // Compact View / Track Button
                          InkWell(
                            onTap: () => _onViewComplaint(item),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF750000).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    isTamil ? 'கண்காணி' : 'Track',
                                    style: const TextStyle(
                                      color: Color(0xFF750000),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Color(0xFF750000),
                                    size: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
