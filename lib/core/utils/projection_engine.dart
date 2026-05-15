import '../../models/transaction.dart';

class ProjectionEngine {
  static List<double> projectBalance({
    required double currentBalance,
    required List<Transaction> history,
    int days = 30,
  }) {
    if (history.isEmpty) return List.filled(days, currentBalance);

    // Calcular promedio diario de ingresos y gastos
    double totalIncome = 0;
    double totalExpenses = 0;
    
    // Asumimos que el historial es de los últimos 90 días
    const int historyDays = 90;

    for (var tx in history) {
      if (tx.amount > 0) {
        totalIncome += tx.amount;
      } else {
        totalExpenses += tx.amount.abs();
      }
    }

    double dailyIncome = totalIncome / historyDays;
    double dailyExpenses = totalExpenses / historyDays;
    double dailyNet = dailyIncome - dailyExpenses;

    List<double> projection = [];
    double runningBalance = currentBalance;

    for (int i = 0; i < days; i++) {
      runningBalance += dailyNet;
      projection.add(runningBalance);
    }

    return projection;
  }
}
