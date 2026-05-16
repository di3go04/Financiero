import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _shimmerBox(height: 180, width: double.infinity, radius: 24),
          const SizedBox(height: 24),
          _shimmerBox(height: 100, width: double.infinity, radius: 24),
          const SizedBox(height: 24),
          _shimmerBox(height: 40, width: 200, radius: 8),
          const SizedBox(height: 16),
          _shimmerBox(height: 200, width: double.infinity, radius: 24),
        
      ),
    );
  }

  Widget _shimmerBox({required double height, required double width, required double radius}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.withValues(alpha: 0.1),
      highlightColor: Colors.grey.withValues(alpha: 0.05),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}


