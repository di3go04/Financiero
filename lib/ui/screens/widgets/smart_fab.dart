import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/theme/app_theme.dart';

class SmartFAB extends StatefulWidget {
  final VoidCallback onAddTransaction;
  final VoidCallback onAddBudget;
  final VoidCallback onAddGoal;

  const SmartFAB({
    super.key,
    required this.onAddTransaction,
    required this.onAddBudget,
    required this.onAddGoal,
  });

  @override
  State<SmartFAB> createState() => _SmartFABState();
}

class _SmartFABState extends State<SmartFAB> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    _isOpen = !_isOpen;
    if (_isOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    // No setState needed — AnimatedBuilder listens to _controller
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _SmartFABAction(
          controller: _controller,
          icon: Icons.track_changes_rounded,
          label: 'Nueva Meta',
          onTap: () { _toggle(); widget.onAddGoal(); },
          index: 2,
        ),
        const SizedBox(height: 12),
        _SmartFABAction(
          controller: _controller,
          icon: Icons.donut_large_rounded,
          label: 'Nuevo Presupuesto',
          onTap: () { _toggle(); widget.onAddBudget(); },
          index: 1,
        ),
        _SmartFABAction(
          controller: _controller,
          icon: Icons.add_shopping_cart_rounded,
          label: 'Nueva Transacción',
          onTap: () { _toggle(); widget.onAddTransaction(); },
          index: 0,
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: AppTheme.primaryBlue,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * math.pi * 0.75,
                child: child,
              );
            },
            child: const Icon(Icons.add_rounded, size: 32, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

/// Extracted action item — prevents parent rebuild on animation ticks
class _SmartFABAction extends StatelessWidget {
  final AnimationController controller;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int index;

  const _SmartFABAction({
    required this.controller,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final animValue = Curves.easeOutBack.transform(
          (controller.value - (index * 0.1)).clamp(0.0, 1.0),
        );
        return Transform.scale(
          scale: animValue,
          child: Opacity(
            opacity: animValue.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            FloatingActionButton.small(
              heroTag: 'action_$index',
              onPressed: onTap,
              backgroundColor: AppTheme.primaryBlue,
              child: Icon(icon, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
