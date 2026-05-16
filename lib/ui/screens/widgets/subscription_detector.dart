import 'package:flutter/material.dart';
import 'premium_primitives.dart';
import '../../../core/theme/app_theme.dart';

class SubscriptionDetector extends StatelessWidget {
  final List<dynamic> transactions;

  const SubscriptionDetector({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return SolidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.subscriptions_rounded, color: AppTheme.expenseCoral, size: 20),
              SizedBox(width: 10),
              Text('Posibles Suscripciones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            
          ),
          const SizedBox(height: 16),
          if (transactions.isEmpty)
            const Text('No se detectaron suscripciones este mes.', style: TextStyle(color: Colors.grey, fontSize: 13))
          else
            Column(
              children: transactions.where((tx) => tx['amount'] > 5 && tx['amount'] < 50).map((tx) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(tx['description'] ?? tx['category' style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text('\$${tx['amount']} / mes', style: const TextStyle(color: AppTheme.expenseCoral, fontWeight: FontWeight.bold)),
                    
                  ),
                );
              }).toList(),
            ),
        
      ),
    );
  }
}




