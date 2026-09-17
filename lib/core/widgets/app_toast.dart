import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Clean, standard Toast / Alert component for the entire application.
/// Strictly non-blocking, lightweight, polite, and user-friendly.
class AppToast {
  static OverlayEntry? _activeEntry;

  /// Sanitizes technical error messages so users never see raw SQL or stack traces
  static String _sanitizeMessage(String rawMessage) {
    final lower = rawMessage.toLowerCase();

    // 1. User Deleted / Not Found
    if (lower.contains('user not found') ||
        lower.contains('user account not found') ||
        lower.contains('userid_fkey') ||
        lower.contains('user_fkey')) {
      return 'User not found. Please log in again.';
    }

    // 2. Technical Prisma / SQL / Stack Trace Leaks
    if (lower.contains('prisma') ||
        lower.contains('foreign key') ||
        lower.contains('constraint') ||
        lower.contains('invocation') ||
        lower.contains('wwwroot') ||
        lower.contains('syntaxerror') ||
        lower.contains('fkey')) {
      return 'Server error. Please try again.';
    }

    // 3. Genuine Network / Offline errors ONLY
    if (lower.contains('socketexception') ||
        lower.contains('failed host lookup') ||
        lower.contains('net::err_internet_disconnected')) {
      return 'Please check your internet connection';
    }

    return rawMessage;
  }

  /// Show Success Toast (Green themed)
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 2400),
  }) {
    _showToast(
      context,
      message: _sanitizeMessage(message),
      icon: Icons.check_circle_rounded,
      backgroundColor: const Color(0xFF1B5E20),
      borderColor: const Color(0xFFA5D6A7),
      textColor: Colors.white,
      duration: duration,
    );
  }

  /// Show Error Toast (Normal, clean alert style)
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 2800),
  }) {
    _showToast(
      context,
      message: _sanitizeMessage(message),
      icon: Icons.wifi_off_rounded,
      backgroundColor: const Color(0xFF8C0000),
      borderColor: AppColors.goldAccent,
      textColor: Colors.white,
      duration: duration,
    );
  }

  /// Show Info / Warning Toast
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 2400),
  }) {
    _showToast(
      context,
      message: _sanitizeMessage(message),
      icon: Icons.info_outline_rounded,
      backgroundColor: const Color(0xFF212121),
      borderColor: const Color(0xFF757575),
      textColor: Colors.white,
      duration: duration,
    );
  }

  static void _showToast(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color borderColor,
    required Color textColor,
    required Duration duration,
  }) {
    _activeEntry?.remove();
    _activeEntry = null;

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _ToastStandardContainer(
        message: message,
        icon: icon,
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        textColor: textColor,
        duration: duration,
        onDismissed: () {
          if (_activeEntry == entry) {
            entry.remove();
            _activeEntry = null;
          }
        },
      ),
    );

    _activeEntry = entry;
    overlay.insert(entry);
  }
}

/// Normal, clean, non-over-animated alert container
class _ToastStandardContainer extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Duration duration;
  final VoidCallback onDismissed;

  const _ToastStandardContainer({
    required this.message,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_ToastStandardContainer> createState() => _ToastStandardContainerState();
}

class _ToastStandardContainerState extends State<_ToastStandardContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Simple 180ms smooth fade (zero bounce, completely normal alert)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _dismiss,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: widget.borderColor.withValues(alpha: 0.6), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(widget.icon, color: widget.textColor, size: 19),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          color: widget.textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.close_rounded,
                      color: widget.textColor.withValues(alpha: 0.7),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
