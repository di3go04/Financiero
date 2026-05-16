import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GlobalShortcuts extends StatelessWidget {
  final Widget child;
  final VoidCallback? onSearch;
  final VoidCallback? onNewTransaction;
  final VoidCallback? onToggleSidebar;

  const GlobalShortcuts({
    super.key,
    required this.child,
    this.onSearch,
    this.onNewTransaction,
    this.onToggleSidebar,
  });

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): onSearch ?? () {},
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): onNewTransaction ?? () {},
        const SingleActivator(LogicalKeyboardKey.keyB, control: true): onToggleSidebar ?? () {},
      },
      child: Focus(
        autofocus: true,
        child: child,
      ),
    );
  }
}


