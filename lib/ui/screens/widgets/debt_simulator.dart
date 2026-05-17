import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'premium_primitives.dart';

class DebtSimulator extends StatefulWidget {
  const DebtSimulator({super.key});

  @override
  State<DebtSimulator> createState() => _DebtSimulatorState();
}

class _DebtSimulatorState extends State<DebtSimulator> {
  final _amountController = TextEditingController();
  final _interestController = TextEditingController();
  final _paymentController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _interestController.dispose();
    _paymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SolidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Simulador de Deuda', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: 'Monto total', prefixText: '\$ '),
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _interestController,
            decoration: const InputDecoration(labelText: 'Interés anual', suffixText: '%'),
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _paymentController,
            decoration: const InputDecoration(labelText: 'Pago mensual', prefixText: '\$ '),
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          _buildResult(),
        ],
      ),
    );
  }

  Widget _buildResult() {
    try {
      final amount = double.tryParse(_amountController.text) ?? 0;
      final interestPercent = double.tryParse(_interestController.text) ?? 0;
      final payment = double.tryParse(_paymentController.text) ?? 0;

      if (amount <= 0 || payment <= 0) return const Text('Ingresa valores para simular tu pago.', style: TextStyle(color: AppTheme.textDim));

      final interestPerMonth = interestPercent / 100 / 12;

      if (payment <= amount * interestPerMonth) {
        return const Text('El pago mensual es insuficiente para cubrir los intereses.', style: TextStyle(color: AppTheme.expenseRed, fontWeight: FontWeight.bold));
      }

      int months = 0;
      double currentBalance = amount;
      while (currentBalance > 0 && months < 360) {
        currentBalance = currentBalance * (1 + interestPerMonth) - payment;
        months++;
      }

      return Text(
        'Terminarás de pagar en $months meses.',
        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
      );
    } catch (e) {
      return const Text('Ingresa valores para simular tu pago.');
    }
  }
}
