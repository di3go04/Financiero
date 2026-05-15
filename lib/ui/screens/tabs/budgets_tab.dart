import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/premium_primitives.dart';

class BudgetsTab extends StatelessWidget {
  const BudgetsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Presupuestos', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                _buildBudgetCard('AlimentaciÃ³n', 450, 600, AppTheme.primaryCyan),
                const SizedBox(height: 16),
                _buildBudgetCard('Transporte', 120, 150, AppTheme.secondaryBlue),
                const SizedBox(height: 16),
                _buildBudgetCard('Ocio', 180, 200, Colors.orange),
                const SizedBox(height: 16),
                _buildBudgetCard('Suscripciones', 45, 50, Colors.purple),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetCard(String category, double spent, double limit, Color color) {
    final progress = spent / limit;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text('${spent.toStringAsFixed(0)}â‚¬ / ${limit.toStringAsFixed(0)}â‚¬', style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress.clamp(0.0, 1.0)),
            duration: const Duration(seconds: 1),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Column(
                children: [
                  LinearProgressIndicator(
                    value: value,
                    backgroundColor: color.withValues(alpha: 0.1),
                    color: color,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% consumido',
            style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
