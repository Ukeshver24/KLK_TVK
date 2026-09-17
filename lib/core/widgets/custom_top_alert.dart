import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomTopAlert {
  static OverlayEntry? _currentEntry;

  static void show(
    BuildContext context, {
    required String message,
    bool isError = true,
  }) {
    _currentEntry?.remove();

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _TopAlertWidget(
        message: message,
        isError: isError,
        onDismiss: () {
          entry.remove();
          if (_currentEntry == entry) {
            _currentEntry = null;
          }
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }
}

class _TopAlertWidget extends StatefulWidget {
  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  const _TopAlertWidget({
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  @override
  State<_TopAlertWidget> createState() => _TopAlertWidgetState();
}

class _TopAlertWidgetState extends State<_TopAlertWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    // Auto dismiss after 2.8 seconds
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        _reverseAndDismiss();
      }
    });
  }

  void _reverseAndDismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isError = widget.isError;

    final List<Color> gradientColors = isError
        ? const [Color(0xFF8C0000), Color(0xFF500000)]
        : const [Color(0xFF1B5E20), Color(0xFF2E7D32)];

    final Color borderColor =
        isError ? AppColors.goldAccent : const Color(0xFF81C784);
    final Color iconColor = isError ? AppColors.goldAccent : Colors.white;
    final Color textColor = isError ? AppColors.goldAccent : Colors.white;

    return Positioned(
      top: mediaQuery.padding.top + 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: borderColor,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Status Icon (Check Circle for success, Warning for error)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: (isError ? AppColors.goldAccent : Colors.white)
                          .withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isError
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_rounded,
                      color: iconColor,
                      size: 22,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Message Text
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        height: 1.35,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Close Icon
                  GestureDetector(
                    onTap: _reverseAndDismiss,
                    child: Icon(
                      Icons.close_rounded,
                      color: iconColor.withValues(alpha: 0.8),
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
