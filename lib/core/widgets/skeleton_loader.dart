import 'package:flutter/material.dart';

/// ShimmerEffect animates a subtle shimmering gradient highlight across child widgets.
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE8E2E2),
    this.highlightColor = const Color(0xFFFAF7F7),
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value.clamp(0.0, 1.0),
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}

/// Basic Skeleton Box Shape
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E2E2),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Circular Skeleton Shape
class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFE8E2E2),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Full Skeleton Layout for Cards/Dashboard
class SkeletonCardPlaceholder extends StatelessWidget {
  const SkeletonCardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEBE5E5)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(height: 16, width: 140, borderRadius: 6),
            SizedBox(height: 10),
            SkeletonBox(height: 12, width: 220, borderRadius: 6),
            SizedBox(height: 14),
            SkeletonBox(height: 48, borderRadius: 14),
          ],
        ),
      ),
    );
  }
}

/// Skeleton Header Placeholder
class SkeletonHeaderPlaceholder extends StatelessWidget {
  const SkeletonHeaderPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShimmerEffect(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SkeletonCircle(size: 48),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(height: 10, width: 80, borderRadius: 4),
                  SizedBox(height: 6),
                  SkeletonBox(height: 16, width: 120, borderRadius: 6),
                ],
              ),
            ],
          ),
          SkeletonCircle(size: 40),
        ],
      ),
    );
  }
}

/// Skeleton Banner Carousel Placeholder
class SkeletonBannerPlaceholder extends StatelessWidget {
  const SkeletonBannerPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShimmerEffect(
      child: SkeletonBox(
        height: 190,
        borderRadius: 24,
      ),
    );
  }
}
