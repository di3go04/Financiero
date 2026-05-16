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
        
      ),
    );
  }

  Widget _buildResult() {
    try {
      final amount = double.parse(_amountController.text);
      final interest = double.parse(_interestController.text) / 100 / 12;
      final payment = double.parse(_paymentController.text);

      if (payment <= amount * interest) {
        return const Text('El pago mensual es insuficiente para cubrir los intereses.', style: TextStyle(color: Colors.redAccent));
      }

      int months = 0;
      double currentBalance = amount;
      while (currentBalance > 0 && months < 360) {
        currentBalance = currentBalance * (1 + interest) - payment;
        months++;
      }

      return Text(
        'Terminarás de pagar en $months meses.',
        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryIndigo),
      );
    } catch (e) {
      return const Text('Ingresa valores para simular tu pago.');
    }
  }
}




