import 'package:flutter/material.dart';
import 'package:prosper/core/theme/app_theme.dart';
import 'package:prosper/ui/screens/widgets/premium_primitives.dart';

class FinancialCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;

  const FinancialCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SolidCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: (color ?? AppTheme.primaryBlue)),
            ),
            child: Icon(icon, color: color ?? AppTheme.primaryBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppTheme.textDim, fontSize: 14)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
