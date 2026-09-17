import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/app_date_formatter.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../../../complaint/data/complaint_api_service.dart';
import '../../../history/presentation/widgets/tracking_timeline_widget.dart';
import '../../../shell/presentation/screens/main_shell_screen.dart';

class TrackStatusDetailsScreen extends StatefulWidget {
  final String selectedLanguage;
  final String referenceId;
  final String? citizenId;
  final String status;
  final String? date;
  final String? statusReason;
  final String? adminRemarks;
  final List<Map<String, dynamic>>? timelineEvents;

  const TrackStatusDetailsScreen({
    super.key,
    required this.selectedLanguage,
    required this.referenceId,
    this.citizenId,
    this.status = 'SUBMITTED',
    this.date,
    this.statusReason,
    this.adminRemarks,
    this.timelineEvents,
  });

  @override
  State<TrackStatusDetailsScreen> createState() => _TrackStatusDetailsScreenState();
}

class _TrackStatusDetailsScreenState extends State<TrackStatusDetailsScreen> {
  late String _currentStatus;
  late String _currentDate;
  String? _citizenId;
  String? _statusReason;
  String? _adminRemarks;
  List<Map<String, dynamic>>? _timelineEvents;
  bool _isFetchingLive = false;
  final ComplaintApiService _apiService = ComplaintApiService();

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.status;
    _currentDate = widget.date != null ? AppDateFormatter.formatDateTime(widget.date!) : AppDateFormatter.formatDateTime(DateTime.now().toString());
    _citizenId = widget.citizenId;
    _statusReason = widget.statusReason;
    _adminRemarks = widget.adminRemarks;
    _timelineEvents = widget.timelineEvents;
    _fetchLiveDetails();
  }

  Future<void> _fetchLiveDetails() async {
    if (_isFetchingLive) return;
    setState(() => _isFetchingLive = true);
    try {
      final results = await _apiService.trackComplaints(widget.referenceId);
      if (results.isNotEmpty && mounted) {
        final live = results.first;
        setState(() {
          _currentStatus = live.status;
          if (live.createdAt.isNotEmpty) {
            _currentDate = AppDateFormatter.formatDateTime(live.createdAt);
          }
          _citizenId = live.citizenId ?? _citizenId;
          _statusReason = live.statusReason;
          _adminRemarks = live.adminRemarks;
          if (live.timelineEvents != null && live.timelineEvents!.isNotEmpty) {
            _timelineEvents = live.timelineEvents;
          }
        });
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isFetchingLive = false);
      }
    }
  }

  int _getStepLevel(String st) {
    if (_timelineEvents != null && _timelineEvents!.isNotEmpty) {
      int maxStep = 1;
      for (final e in _timelineEvents!) {
        final s = (e['status'] as String? ?? '').toUpperCase().replaceAll(' ', '_');
        if (s == 'RESOLVED') {
          maxStep = 5;
        } else if ((s == 'IN_PROGRESS' || s == 'ACTION_TAKEN') && maxStep < 4) {
          maxStep = 4;
        } else if (s == 'OFFICER_ASSIGNED' && maxStep < 3) {
          maxStep = 3;
        } else if ((s == 'UNDER_REVIEW' || s == 'IN_REVIEW') && maxStep < 2) {
          maxStep = 2;
        }
      }
      return maxStep;
    }

    final clean = st.toUpperCase().replaceAll(' ', '_');
    switch (clean) {
      case 'RESOLVED':
        return 5;
      case 'IN_PROGRESS':
      case 'ACTION_TAKEN':
        return 4;
      case 'OFFICER_ASSIGNED':
        return 3;
      case 'UNDER_REVIEW':
      case 'IN_REVIEW':
        return 2;
      case 'OTHERS':
        return 2;
      case 'SUBMITTED':
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTamil = widget.selectedLanguage == 'ta';
    final isTablet = Responsive.isTablet(context);
    final size = MediaQuery.of(context).size;
    const int currentBottomIndex = 3; // Active on Track tab

    Color badgeBg;
    Color badgeText;
    String statusLabel;

    final normStatus = _currentStatus.toUpperCase().replaceAll(' ', '_');
    final int level = _getStepLevel(normStatus);
    final bool isOthers = normStatus == 'OTHERS';

    if (level == 5 || normStatus == 'RESOLVED') {
      badgeBg = const Color(0xFFF6FFED);
      badgeText = const Color(0xFF389E0D);
      statusLabel = isTamil ? 'தீர்வு காணப்பட்டது' : 'RESOLVED';
    } else if (normStatus == 'ACTION_TAKEN' || normStatus == 'IN_PROGRESS' || (level == 4 && isOthers)) {
      badgeBg = const Color(0xFFE6F7FF);
      badgeText = const Color(0xFF096DD9);
      statusLabel = isTamil ? 'களப்பணியில்' : 'IN PROGRESS';
    } else if (normStatus == 'OFFICER_ASSIGNED' || (level == 3 && isOthers)) {
      badgeBg = const Color(0xFFEEF2FF);
      badgeText = const Color(0xFF4F46E5);
      statusLabel = isTamil ? 'பொறுப்பாளர் ஒதுக்கீடு' : 'OFFICER ASSIGNED';
    } else if (normStatus == 'UNDER_REVIEW' || normStatus == 'IN_REVIEW' || (level == 2 && isOthers)) {
      badgeBg = const Color(0xFFFFF7E6);
      badgeText = const Color(0xFFD48800);
      statusLabel = isTamil ? 'பரிசீலனையில்' : 'IN REVIEW';
    } else if (isOthers) {
      badgeBg = const Color(0xFFFAF5FF);
      badgeText = const Color(0xFF7E22CE);
      statusLabel = isTamil ? 'நிர்வாகக் குறிப்பு' : 'REMARKS / NOTES';
    } else {
      badgeBg = const Color(0xFFFFF1F0);
      badgeText = const Color(0xFFCF1322);
      statusLabel = isTamil ? 'புதிய மனு' : 'SUBMITTED';
    }

    // Build Step-by-Step Timeline with in-line notices exactly where they occurred
    List<Map<String, dynamic>> timelineSteps = [];

    if (_timelineEvents != null && _timelineEvents!.isNotEmpty) {
      timelineSteps = _timelineEvents!.map((e) {
        final s = (e['status'] as String? ?? '').toUpperCase().replaceAll(' ', '_');
        final bool isNotice = e['isNotice'] == true || s == 'OTHERS';
        return {
          'titleEn': e['titleEn'] ?? e['title'] ?? '',
          'titleTa': e['titleTa'] ?? e['title'] ?? '',
          'date': e['date'] ?? _currentDate,
          'isCompleted': true,
          'isCurrent': !isNotice && (s == normStatus),
          'isNotice': isNotice,
          'notes': e['notes'] ?? _statusReason,
        };
      }).toList();
    } else {
      // Progressive 5 Steps
      timelineSteps = [
        {
          'titleEn': '1. Grievance Registered by Citizen',
          'titleTa': '1. மனுதாரரால் புகார் பதிவு செய்யப்பட்டது',
          'date': _currentDate,
          'isCompleted': level >= 1,
          'isCurrent': level == 1 && !isOthers,
          'isNotice': false,
        },
        {
          'titleEn': '2. Grievance Under Review',
          'titleTa': '2. சட்டமன்ற உறுப்பினர் அலுவலகத்தில் பரிசீலனை',
          'date': level >= 2 ? _currentDate : null,
          'isCompleted': level >= 2,
          'isCurrent': level == 2 && !isOthers,
          'isNotice': false,
        },
        {
          'titleEn': '3. Officer Assigned for Action',
          'titleTa': '3. களப் பொறுப்பாளர் ஆய்வு பணி ஒதுக்கீடு',
          'date': level >= 3 ? _currentDate : null,
          'isCompleted': level >= 3,
          'isCurrent': level == 3 && !isOthers,
          'isNotice': false,
        },
        {
          'titleEn': '4. Action in Progress',
          'titleTa': '4. களப்பணிகள் நடைபெற்று வருகின்றன',
          'date': level >= 4 ? _currentDate : null,
          'isCompleted': level >= 4,
          'isCurrent': level == 4 && !isOthers,
          'isNotice': false,
        },
        {
          'titleEn': '5. Grievance Successfully Resolved',
          'titleTa': '5. புகார் வெற்றிகரமாக தீர்க்கப்பட்டது',
          'date': level >= 5 ? _currentDate : null,
          'isCompleted': level >= 5,
          'isCurrent': level == 5,
          'isNotice': false,
        },
      ];

      // If custom notice/reason was provided, insert it directly after the active level
      if ((_statusReason != null && _statusReason!.trim().isNotEmpty) ||
          (isOthers && _adminRemarks != null && _adminRemarks!.trim().isNotEmpty)) {
        final noticeText = (_statusReason != null && _statusReason!.trim().isNotEmpty)
            ? _statusReason!.trim()
            : _adminRemarks!.trim();
        final insertIndex = (level <= timelineSteps.length) ? level : timelineSteps.length;
        timelineSteps.insert(insertIndex, {
          'titleEn': 'Official Notice / Reason for Delay',
          'titleTa': 'நிர்வாக அறிவிப்பு / தாமத விளக்கம்',
          'date': _currentDate,
          'isCompleted': true,
          'isCurrent': false,
          'isNotice': true,
          'notes': noticeText,
        });
      }
    }

    void handleBack() {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainShellScreen(
              initialIndex: 3,
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
                  horizontal: isTablet ? size.width * 0.15 : 16,
                  vertical: 10,
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
                          color: const Color(0xFFEBE5E5),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFD4C5C5)),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFF2C0000),
                          size: 19,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isTamil ? 'புகார் நிலை விவரங்கள்' : 'Track Status Details',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF1E1E1E),
                          fontSize: isTamil ? 17 : 19,
                          fontWeight: isTamil ? FontWeight.w700 : FontWeight.w800,
                          letterSpacing: isTamil ? 0.0 : 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Refresh Button
                    GestureDetector(
                      onTap: _isFetchingLive ? null : _fetchLiveDetails,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE0D5D5)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _isFetchingLive
                                ? const SizedBox(
                                    width: 13,
                                    height: 13,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8C0000)),
                                    ),
                                  )
                                : const Icon(
                                    Icons.refresh_rounded,
                                    color: Color(0xFF8C0000),
                                    size: 15,
                                  ),
                            const SizedBox(width: 4),
                            Text(
                              isTamil ? 'புதுப்பி' : 'Refresh',
                              style: TextStyle(
                                color: const Color(0xFF8C0000),
                                fontSize: 11,
                                fontWeight: isTamil ? FontWeight.w700 : FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable Body
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchLiveDetails,
                  color: const Color(0xFF8C0000),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? size.width * 0.15 : 20,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                  // Complaint Meta Summary Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEBE5E5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Reference ID and Status Badge
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isTamil ? 'மனு எண்' : 'REFERENCE ID',
                                    style: const TextStyle(
                                      color: Color(0xFF8E7E7E),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.referenceId,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF750000),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Status Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4.5,
                              ),
                              decoration: BoxDecoration(
                                color: badgeBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                statusLabel,
                                style: TextStyle(
                                  color: badgeText,
                                  fontSize: isTamil ? 10.5 : 11,
                                  fontWeight: isTamil ? FontWeight.w700 : FontWeight.bold,
                                  letterSpacing: isTamil ? 0.0 : 0.4,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Color(0xFFF5EEEE)),
                        const SizedBox(height: 12),

                        // Citizen ID & Submission Date
                        Row(
                          children: [
                            // Citizen ID
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.badge_outlined,
                                    color: Color(0xFF8E7E7E),
                                    size: 15,
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isTamil ? 'மனுதாரர் எண்' : 'CITIZEN ID',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFF8E7E7E),
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        Text(
                                          _citizenId != null && _citizenId!.isNotEmpty
                                              ? _citizenId!
                                              : 'TVK-C-0001',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFF1E1E1E),
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Submission Date
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  color: Color(0xFF8E7E7E),
                                  size: 13,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _currentDate,
                                  style: TextStyle(
                                    color: const Color(0xFF5A4A4A),
                                    fontSize: isTamil ? 11 : 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Live Tracking Timeline
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFEBE5E5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TrackingTimelineWidget(
                      isTamil: isTamil,
                      timelineSteps: timelineSteps,
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  ),

  // Bottom Navigation Bar - Active on Track tab (Index 3)
  bottomNavigationBar: CustomBottomNavBar(
    currentIndex: currentBottomIndex,
    selectedLanguage: widget.selectedLanguage,
  ),
),
);
}
}
