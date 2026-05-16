import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Currency { usd, cop, btc }

class CurrencyProvider with ChangeNotifier {
  Currency _currency = Currency.usd;
  static const String _key = 'currency';

  CurrencyProvider() {
    _load();
  }

  Currency get currency => _currency;

  String get symbol {
    switch (_currency) {
      case Currency.usd: return '\$';
      case Currency.cop: return 'COP';
      case Currency.btc: return '₿';
    }
  }

  String get label {
    switch (_currency) {
      case Currency.usd: return 'USD';
      case Currency.cop: return 'COP';
      case Currency.btc: return 'BTC';
    }
  }

  String format(double amount) {
    switch (_currency) {
      case Currency.usd:
        return '\$${amount.toStringAsFixed(2)}';
      case Currency.cop:
        final s = amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.',
        );
        return 'COP $s';
      case Currency.btc:
        return '₿${(amount / 35000).toStringAsFixed(6)}';
    }
  }

  Future<void> setCurrency(Currency c) async {
    _currency = c;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, c.index);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final idx = prefs.getInt(_key);
    if (idx != null && idx < Currency.values.length) {
      _currency = Currency.values[idx];
      notifyListeners();
    }
  }
}


