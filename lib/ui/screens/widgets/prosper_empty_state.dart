import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../core/theme/app_theme.dart';
import 'premium_button.dart';

class ProsperEmptyState extends StatelessWidget {
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onAction;
  final String? lottieAsset;
  final IconData? icon;

  const ProsperEmptyState({
    super.key,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onAction,
    this.lottieAsset,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (lottieAsset != null)
              Lottie.network(
                lottieAsset!,
                height: 200,
                repeat: true,
                errorBuilder: (context, error, stackTrace) => Icon(icon ?? Icons.inbox_rounded, size: 80, color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
              )
            else
              Icon(icon ?? Icons.inbox_rounded, size: 80, color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
            const SizedBox(height: 32),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isDark ? AppTheme.textSnow : AppTheme.textSlate,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textDim,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            PremiumButton(
              onPressed: onAction,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: Text(
                  buttonLabel,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
