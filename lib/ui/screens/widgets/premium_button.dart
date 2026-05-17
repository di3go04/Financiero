import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class PremiumButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isLoading;

  const PremiumButton({
    super.key, 
    required this.child, 
    this.onPressed,
    this.color,
    this.isLoading = false,
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
    final baseColor = widget.color ?? AppTheme.primaryBlue;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.isLoading ? SystemMouseCursors.wait : SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => widget.isLoading ? null : _controller.forward(),
        onTapUp: (_) => widget.isLoading ? null : _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: widget.isLoading ? null : widget.onPressed,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: widget.isLoading 
                ? baseColor.withValues(alpha: 0.6) 
                : (_isHovered ? baseColor.withValues(alpha: 0.9) : baseColor),
              boxShadow: _isHovered && !widget.isLoading
                ? [BoxShadow(color: baseColor.withValues(alpha: 0.2), blurRadius: 10, spreadRadius: 1)]
                : [],
            ),
            child: widget.isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    ),
                  ),
                )
              : widget.child,
          ),
        ),
      ),
    );
  }
}

