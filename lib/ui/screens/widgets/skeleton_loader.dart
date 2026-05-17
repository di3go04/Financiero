import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_theme.dart';

class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Shimmer.fromColors(
      baseColor: isDark ? AppTheme.surfaceDark : Colors.grey[300]!,
      highlightColor: isDark ? AppTheme.borderDark : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 80, left: 24, right: 24, bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: 200, height: 32),
          const SizedBox(height: 32),
          const SkeletonBox(width: double.infinity, height: 160),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: const SkeletonBox(width: double.infinity, height: 100)),
              const SizedBox(width: 16),
              Expanded(child: const SkeletonBox(width: double.infinity, height: 100)),
            ],
          ),
          const SizedBox(height: 32),
          const SkeletonBox(width: 150, height: 24),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (_, __) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: const SkeletonBox(width: double.infinity, height: 72),
            ),
          ),
        ],
      ),
    );
  }
}

class ListSkeleton extends StatelessWidget {
  const ListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 80, left: 24, right: 24, bottom: 40),
      itemCount: 8,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: const SkeletonBox(width: double.infinity, height: 80),
      ),
    );
  }
}

