import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class PremiumButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final List<Color>? gradient;

  const PremiumButton({
    super.key, 
    required this.child, 
    this.onPressed,
    this.gradient,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: widget.onPressed,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: widget.gradient != null 
                ? LinearGradient(colors: widget.gradient!)
                : null,
              boxShadow: _isHovered 
                ? [BoxShadow(color: (widget.gradient?.first ?? AppTheme.primaryCyan).withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 2)]
                : [],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
