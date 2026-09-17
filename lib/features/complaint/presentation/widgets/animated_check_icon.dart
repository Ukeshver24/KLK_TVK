import 'package:flutter/material.dart';

class AnimatedCheckIcon extends StatefulWidget {
  final double size;

  const AnimatedCheckIcon({
    super.key,
    this.size = 110,
  });

  @override
  State<AnimatedCheckIcon> createState() => _AnimatedCheckIconState();
}

class _AnimatedCheckIconState extends State<AnimatedCheckIcon>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _rippleController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _checkScaleAnimation;

  @override
  void initState() {
    super.initState();

    // Entry Spring Bounce Animation
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.65, curve: Curves.elasticOut),
    );

    _checkScaleAnimation = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.45, 1.0, curve: Curves.bounceOut),
    );

    // Continuous Expanding Ripple Waves Animation
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 1.8,
      height: widget.size * 1.8,
      child: AnimatedBuilder(
        animation: _rippleController,
        builder: (context, child) {
          final rippleValue = _rippleController.value;

          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer Expanding Ripple Ring 2
              Transform.scale(
                scale: 1.0 + (rippleValue * 0.7),
                child: Opacity(
                  opacity: (1.0 - rippleValue).clamp(0.0, 1.0) * 0.35,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2ECC71),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),

              // Inner Expanding Ripple Ring 1
              Transform.scale(
                scale: 1.0 + (((rippleValue + 0.5) % 1.0) * 0.5),
                child: Opacity(
                  opacity: (1.0 - ((rippleValue + 0.5) % 1.0)).clamp(0.0, 1.0) * 0.45,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2ECC71),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),

              // Center Main Green Checkmark Circle
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECC71),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2ECC71).withValues(alpha: 0.45),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ScaleTransition(
                    scale: _checkScaleAnimation,
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: widget.size * 0.55,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
