import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';

class BannerSliderWidget extends StatelessWidget {
  final PageController controller;
  final int currentBannerIndex;
  final List<String> bannerAssets;
  final bool isTamil;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final Function(int) onPageChanged;
  final bool isTablet;

  const BannerSliderWidget({
    super.key,
    required this.controller,
    required this.currentBannerIndex,
    required this.bannerAssets,
    required this.isTamil,
    required this.onPrev,
    required this.onNext,
    required this.onPageChanged,
    required this.isTablet,
  });

  Widget _buildSingleImage(String imagePath, int index) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        memCacheWidth: 800,
        memCacheHeight: 450,
        fadeInDuration: const Duration(milliseconds: 250),
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: const Color(0xFF4A0000),
          highlightColor: const Color(0xFF6B0000),
          child: Container(
            color: const Color(0xFF380000),
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        errorWidget: (context, url, error) {
          return _buildFallbackBanner(index, isTamil);
        },
      );
    }

    // Support Base64 Data URL (e.g. data:image/png;base64,...)
    if (imagePath.startsWith('data:image')) {
      try {
        final commaIdx = imagePath.indexOf(',');
        final base64String = commaIdx != -1 ? imagePath.substring(commaIdx + 1) : imagePath;
        final bytes = base64Decode(base64String.trim());
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          cacheWidth: 800,
          cacheHeight: 450,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackBanner(index, isTamil);
          },
        );
      } catch (_) {
        return _buildFallbackBanner(index, isTamil);
      }
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      cacheWidth: 800,
      cacheHeight: 450,
      errorBuilder: (context, error, stackTrace) {
        return _buildFallbackBanner(index, isTamil);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMultiple = bannerAssets.length > 1;

    return Stack(
      alignment: Alignment.center,
      children: [
        // PageView Banner Slider / Single Static Banner Box
        Container(
          height: isTablet ? 260 : 190,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: isMultiple
                ? PageView.builder(
                    physics: const ClampingScrollPhysics(),
                    controller: controller,
                    onPageChanged: onPageChanged,
                    itemBuilder: (context, index) {
                      final actualIndex = index % bannerAssets.length;
                      final imagePath = bannerAssets[actualIndex];
                      return _buildSingleImage(imagePath, actualIndex);
                    },
                  )
                : _buildSingleImage(bannerAssets.first, 0),
          ),
        ),

        // Left Arrow Control Button (ONLY shown when 2 or 3 banners exist)
        if (isMultiple)
          Positioned(
            left: 12,
            child: GestureDetector(
              onTap: onPrev,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.chevron_left_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),

        // Right Arrow Control Button (ONLY shown when 2 or 3 banners exist)
        if (isMultiple)
          Positioned(
            right: 12,
            child: GestureDetector(
              onTap: onNext,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),

        // Page Dots Indicator (ONLY shown when 2 or 3 banners exist)
        if (isMultiple)
          Positioned(
            bottom: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(bannerAssets.length, (i) {
                final isSelected =
                    (currentBannerIndex % bannerAssets.length) == i;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isSelected ? 20 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.goldAccent
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildFallbackBanner(int index, bool isTamil) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: index == 0
              ? [const Color(0xFF6B0000), const Color(0xFF380000)]
              : index == 1
                  ? [const Color(0xFF8C0000), const Color(0xFF4A0000)]
                  : [const Color(0xFF500000), const Color(0xFF260000)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.goldAccent.withValues(alpha: 0.15),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.goldAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'TVK BANNER ${index + 1}',
                      style: const TextStyle(
                        color: Color(0xFF500000),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isTamil
                        ? 'தமிழக வெற்றிக் கழகம் • மக்கள் சேவை'
                        : 'Tamizhaga Vettri Kazhagam • Public Service',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
