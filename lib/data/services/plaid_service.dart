import 'package:flutter/foundation.dart';
import 'package:plaid_flutter/plaid_flutter.dart';
import '../../models/transaction.dart';

class PlaidService {
  // Configuraci�n de Plaid (usando modo sandbox para el MVP)
  static const String clientId = 'YOUR_PLAID_CLIENT_ID';
  static const String secret = 'YOUR_PLAID_SECRET';
  
  static void openLink({
    required Function(String publicToken, LinkSuccessMetadata metadata) onSuccess,
    required Function(LinkExitMetadata metadata) onExit,
  }) {
    // Esto es una simulación del flujo de Plaid Link
    // En una implementación real, se usaría LinkConfiguration
    
    debugPrint('Abriendo Plaid Link...');
    // Simular éxito después de un delay
    Future.delayed(const Duration(seconds: 2), () {
      // onSuccess('public-sandbox-123', ...);
    });
  }

  static List<Transaction> getMockTransactions() {
    return [
      Transaction(
        id: '1',
        userId: 'user123',
        accountId: 'acc1',
        amount: -45.60,
        category: 'Comida',
        date: DateTime.now().subtract(const Duration(days: 1)),
        name: 'Mercadona Supermercado',
      ),
      Transaction(
        id: '2',
        userId: 'user123',
        accountId: 'acc1',
        amount: -12.99,
        category: 'Ocio',
        date: DateTime.now().subtract(const Duration(days: 2)),
        name: 'Netflix',
      ),
      Transaction(
        id: '3',
        userId: 'user123',
        accountId: 'acc1',
        amount: 2500.00,
        category: 'Ingresos',
        date: DateTime.now().subtract(const Duration(days: 15)),
        name: 'Nómina Mayo',
      ),
      Transaction(
        id: '4',
        userId: 'user123',
        accountId: 'acc1',
        amount: -850.00,
        category: 'Vivienda',
        date: DateTime.now().subtract(const Duration(days: 10)),
        name: 'Alquiler Piso',
      ),
    ];
  }
}



