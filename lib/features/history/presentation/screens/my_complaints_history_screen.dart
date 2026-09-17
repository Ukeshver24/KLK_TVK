import 'package:flutter/material.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/utils/app_date_formatter.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../complaint/data/complaint_api_service.dart';
import '../widgets/complaint_history_card.dart';
import '../widgets/history_filter_sheet.dart';
import 'complaint_details_screen.dart';

class MyComplaintsHistoryScreen extends StatefulWidget {
  final String selectedLanguage;
  final bool isNestedInShell;

  const MyComplaintsHistoryScreen({
    super.key,
    required this.selectedLanguage,
    this.isNestedInShell = false,
  });

  @override
  State<MyComplaintsHistoryScreen> createState() =>
      _MyComplaintsHistoryScreenState();
}

class _MyComplaintsHistoryScreenState
    extends State<MyComplaintsHistoryScreen> {
  final int _currentBottomIndex = 2; // Active on History tab
  String _selectedFilter = 'ALL';

  final ComplaintApiService _complaintApiService = ComplaintApiService();
  List<ComplaintModel> _complaints = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    final user = SessionService.instance.currentUser;
    if (user != null && user.id.isNotEmpty) {
      final list = await _complaintApiService.getMyComplaints(user.id);
      if (mounted) {
        setState(() {
          _complaints = list;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(String isoString) {
    return AppDateFormatter.formatDateTime(isoString);
  }

  Future<void> _onViewComplaintDetails(ComplaintModel item) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ComplaintDetailsScreen(
          selectedLanguage: widget.selectedLanguage,
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
    );
    if (mounted) {
      _loadComplaints();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTamil = widget.selectedLanguage == 'ta';
    final isTablet = Responsive.isTablet(context);
    final size = MediaQuery.of(context).size;

    final filteredComplaints = _selectedFilter == 'ALL'
        ? _complaints
        : _complaints.where((item) {
            final st = item.status.toUpperCase();
            if (_selectedFilter == 'PENDING' || _selectedFilter == 'SUBMITTED') {
              return st == 'SUBMITTED' || st == 'UNDER_REVIEW' || st == 'IN_REVIEW';
            } else if (_selectedFilter == 'ACTION TAKEN' || _selectedFilter == 'IN_PROGRESS') {
              return st == 'IN_PROGRESS' || st == 'ACTION_TAKEN';
            } else if (_selectedFilter == 'RESOLVED') {
              return st == 'RESOLVED';
            }
            return st == _selectedFilter;
          }).toList();

    return Scaffold(
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isTamil ? 'எனது புகார்கள்' : 'My Complaints',
                    style: const TextStyle(
                      color: Color(0xFF1E1E1E),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
                  ),

                  // Filter Funnel Action Button
                  InkWell(
                    onTap: () {
                      HistoryFilterSheet.show(
                        context,
                        isTamil: isTamil,
                        selectedFilter: _selectedFilter,
                        onFilterSelected: (newFilter) {
                          setState(() {
                            _selectedFilter = newFilter;
                          });
                        },
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F0F0),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5DCDC), width: 0.8),
                      ),
                      child: const Icon(
                        Icons.filter_list_rounded,
                        color: Color(0xFF2C0000),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable List Body
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadComplaints,
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

                  // Complaint Cards List / Skeleton Loader
                  if (_isLoading) ...[
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 3,
                      separatorBuilder: (context, index) => const SizedBox(height: 14),
                      itemBuilder: (context, index) => const SkeletonBox(
                        width: double.infinity,
                        height: 100,
                        borderRadius: 18,
                      ),
                    ),
                  ] else if (filteredComplaints.isEmpty) ...[
                    const SizedBox(height: 60),
                    Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.inbox_outlined,
                            size: 48,
                            color: Color(0xFFA09090),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isTamil
                                ? 'புகார்கள் எதுவும் இல்லை'
                                : 'No complaints found',
                            style: const TextStyle(
                              color: Color(0xFF8E7E7E),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredComplaints.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final item = filteredComplaints[index];

                        return ComplaintHistoryCard(
                          isTamil: isTamil,
                          referenceId: item.referenceId,
                          status: item.status,
                          date: _formatDate(item.createdAt),
                          onViewPressed: () => _onViewComplaintDetails(item),
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  ),

  // Bottom Navigation Bar
  bottomNavigationBar: widget.isNestedInShell
      ? null
      : CustomBottomNavBar(
          currentIndex: _currentBottomIndex,
          selectedLanguage: widget.selectedLanguage,
        ),
);
  }
}
