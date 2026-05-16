import 'package:quick_actions/quick_actions.dart';
import 'package:flutter/material.dart';

class QuickActionsService {
  final QuickActions _quickActions = const QuickActions();

  void initialize(BuildContext context) {
    _quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(type: 'action_add_expense', localizedTitle: 'Nuevo Gasto', icon: 'icon_add'),
      const ShortcutItem(type: 'action_view_goals', localizedTitle: 'Ver Metas', icon: 'icon_goal'),
    ]);

    _quickActions.initialize((shortcutType) {
      if (shortcutType == 'action_add_expense') {
        // Lógica para abrir diálogo de gasto
        // Esto requeriría una referencia global o un evento de bus
      } else if (shortcutType == 'action_view_goals') {
        // Navegar a metas
      }
    });
  }
}


