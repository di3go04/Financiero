import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Solid Card with professional flat design
class SolidCard extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  final bool hasGlow;
  final Color? color;

  const SolidCard({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(20),
    this.hasGlow = false,
    this.color,
  });

  @override
  State<SolidCard> createState() => _SolidCardState();
}

class _SolidCardState extends State<SolidCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final bgColor = widget.color ?? (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: _hovered ? AppTheme.primaryIndigo : borderColor,
            width: 1.5,
          ),
          boxShadow: [
            if (_hovered)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          
        ),
        child: Padding(
          padding: widget.padding,
          child: widget.child,
        ),
      ),
    );
  }
}

class ResponsiveBackground extends StatelessWidget {
  final Widget child;
  const ResponsiveBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }
}
