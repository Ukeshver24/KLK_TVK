import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../shell/presentation/screens/main_shell_screen.dart';
import '../widgets/animated_check_icon.dart';

import '../../domain/pdf_receipt_service.dart';

class ComplaintSuccessScreen extends StatefulWidget {
  final String selectedLanguage;
  final String referenceId;
  final String? applicantName;
  final String? mobileNumber;
  final String? constituency;
  final String? submissionDate;
  final String? complaintDescription;

  const ComplaintSuccessScreen({
    super.key,
    required this.selectedLanguage,
    required this.referenceId,
    this.applicantName,
    this.mobileNumber,
    this.constituency,
    this.submissionDate,
    this.complaintDescription,
  });

  @override
  State<ComplaintSuccessScreen> createState() => _ComplaintSuccessScreenState();
}

class _ComplaintSuccessScreenState extends State<ComplaintSuccessScreen> {
  bool _isDownloading = false;
  String? _savedPath;

  void _downloadReceipt() async {
    final isTamil = widget.selectedLanguage == 'ta';

    setState(() {
      _isDownloading = true;
    });

    try {
      // Real Dynamic PDF Generation & Device File Storage
      final path = await PdfReceiptService.generateAndSaveReceipt(
        referenceId: widget.referenceId,
        name: widget.applicantName ?? 'Gowtham J',
        phone: widget.mobileNumber ?? '+91 9876543210',
        constituency: widget.constituency ?? (isTamil ? 'கள்ளக்குறிச்சி' : 'Kallakurichi'),
        submissionDate: widget.submissionDate,
        complaintDescription: widget.complaintDescription,
      );

      if (!mounted) return;

      setState(() {
        _isDownloading = false;
        _savedPath = path;
      });

      if (path != null && path.isNotEmpty) {
        _showDownloadSuccessDialog(isTamil);
      } else {
        AppToast.showError(
          context,
          isTamil
              ? 'ரசீது உருவாக்குவதில் பிழை ஏற்பட்டது. மீண்டும் முயற்சிக்கவும்.'
              : 'Failed to generate PDF receipt. Please try again.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
        AppToast.showError(
          context,
          isTamil
              ? 'ரசீது உருவாக்குவதில் பிழை ஏற்பட்டது. மீண்டும் முயற்சிக்கவும்.'
              : 'Failed to generate PDF receipt. Please try again.',
        );
      }
    }
  }

  void _showDownloadSuccessDialog(bool isTamil) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'DownloadSuccess',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curvedValue = Curves.easeOutBack.transform(anim1.value);
        return Transform.scale(
          scale: curvedValue,
          child: Opacity(
            opacity: anim1.value,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 20,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF8C0000),
                      Color(0xFF500000),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.goldAccent, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Gold Icon Badge
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.goldAccent.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.goldAccent, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.file_download_done_rounded,
                        color: AppColors.goldAccent,
                        size: 34,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Gold Title Text
                    Text(
                      isTamil
                          ? 'புகார் ரசீது பதிவிறக்கம் செய்யப்பட்டது!'
                          : 'Receipt Downloaded!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppColors.goldAccent,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Subtitle
                    Text(
                      isTamil
                          ? 'உங்கள் புகார் ரசீது (PDF) உங்கள் மொபைல் Downloads கோப்புறையில் சேமிக்கப்பட்டது.'
                          : 'Your complaint PDF receipt has been saved to your Downloads folder.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // File Name Badge Pill
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.goldAccent.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '📄 ${_savedPath != null ? _savedPath!.split('/').last : 'TVK_Grievance_ACK.pdf'}',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.goldAccent,
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.folder_open_rounded,
                                color: AppColors.goldLight,
                                size: 14,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                isTamil
                                    ? 'பதிவிறக்கம் (Downloads) கோப்புறையில் உள்ளது'
                                    : 'Saved in Downloads Folder',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Action Buttons Row: Open PDF & OK
                    Row(
                      children: [
                        // Open PDF button
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                if (_savedPath != null) {
                                  try {
                                    await OpenFilex.open(_savedPath!);
                                  } catch (e) {
                                    debugPrint('Error opening PDF: $e');
                                  }
                                }
                              },
                              icon: const Icon(Icons.visibility_rounded, size: 17),
                              label: Text(
                                isTamil ? 'ரசீதை திறக்க' : 'Open PDF',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.goldAccent,
                                foregroundColor: const Color(0xFF500000),
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // OK Button
                        SizedBox(
                          height: 46,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              isTamil ? 'சரி' : 'OK',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _goBackToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => MainShellScreen(
          initialIndex: 0,
          selectedLanguage: widget.selectedLanguage,
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTamil = widget.selectedLanguage == 'ta';
    final isTablet = Responsive.isTablet(context);
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _goBackToHome();
      },
      child: Scaffold(
      backgroundColor: const Color(0xFFFDF9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? size.width * 0.15 : 24,
              vertical: 24,
            ),
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Animated Green Spring Checkmark Icon with Ripple Rings
                const AnimatedCheckIcon(size: 105),

                const SizedBox(height: 36),

                // Complaint Registered Title in Deep Maroon
                Text(
                  isTamil ? 'புகார் பதிவானது!' : 'Complaint\nRegistered!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF2C0000),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: 12),

                // Subtitle in Maroon Accent
                Text(
                  isTamil
                      ? 'உங்கள் பிரச்சனை விரைவில் தீர்க்கப்படும்.'
                      : 'Your problem will be solved quickly.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF8C0000),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 36),

                // Reference ID Card Container in TVK Theme
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFE5DCDC),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        isTamil ? 'குறிப்பு எண்' : 'REFERENCE ID',
                        style: const TextStyle(
                          color: Color(0xFF8E7E7E),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Reference ID Number
                      Text(
                        widget.referenceId,
                        style: const TextStyle(
                          color: Color(0xFF500000),
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Download Receipt Button (TVK Theme Button)
                      InkWell(
                        onTap: _isDownloading ? null : _downloadReceipt,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF800000),
                                Color(0xFF500000),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF800000)
                                    .withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: _isDownloading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.goldAccent,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.file_download_outlined,
                                      color: AppColors.goldAccent,
                                      size: 19,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isTamil
                                          ? 'ரசீது பதிவிறக்குக'
                                          : 'DOWNLOAD RECEIPT',
                                      style: const TextStyle(
                                        color: AppColors.goldAccent,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                // TVK App Theme "Back to Home" Primary Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _goBackToHome,
                    style: ElevatedButton.styleFrom(
                      elevation: 4,
                      backgroundColor: const Color(0xFF750000),
                      foregroundColor: AppColors.goldAccent,
                      shadowColor: const Color(0xFF750000).withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.home_rounded,
                          color: AppColors.goldAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isTamil ? 'முகப்புக்குத் திரும்புக' : 'Back to Home',
                          style: const TextStyle(
                            color: AppColors.goldAccent,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}
