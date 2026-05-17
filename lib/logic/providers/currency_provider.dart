import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Currency { usd, cop, eur, gbp, jpy, mxn, btc, eth }

class CurrencyProvider with ChangeNotifier {
  Currency _currency = Currency.usd;
  static const String _key = 'currency';

  CurrencyProvider() {
    _loadAndDetect();
  }

  Future<void> _loadAndDetect() async {
    final prefs = await SharedPreferences.getInstance();
    final idx = prefs.getInt(_key);
    
    if (idx != null && idx < Currency.values.length) {
      _currency = Currency.values[idx];
    } else {
      // Auto-detect based on locale
      try {
        final locale = WidgetsBinding.instance.platformDispatcher.locale.countryCode?.toUpperCase();
        if (locale == 'CO') {
          _currency = Currency.cop;
        } else if (locale == 'MX') {
          _currency = Currency.mxn;
        } else if (['ES', 'FR', 'DE', 'IT', 'PT'].contains(locale)) {
          _currency = Currency.eur;
        } else if (locale == 'GB') {
          _currency = Currency.gbp;
        } else if (locale == 'JP') {
          _currency = Currency.jpy;
        } else {
          _currency = Currency.usd;
        }
      } catch (_) {
        _currency = Currency.usd;
      }
    }
    notifyListeners();
  }

  Currency get currency => _currency;

  String get symbol {
    switch (_currency) {
      case Currency.usd: return '\$';
      case Currency.cop: return 'COP';
      case Currency.eur: return '€';
      case Currency.gbp: return '£';
      case Currency.jpy: return '¥';
      case Currency.mxn: return 'MXN';
      case Currency.btc: return '₿';
      case Currency.eth: return 'Ξ';
    }
  }

  String get label {
    return _currency.name.toUpperCase();
  }

  String format(double amount) {
    switch (_currency) {
      case Currency.usd:
        return '$symbol${amount.toStringAsFixed(2)}';
      case Currency.cop:
      case Currency.mxn:
        final s = amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.',
        );
        return '$symbol $s';
      case Currency.eur:
      case Currency.gbp:
      case Currency.jpy:
        return '$symbol${amount.toStringAsFixed(2)}';
      case Currency.btc:
        return '₿${(amount / 35000).toStringAsFixed(6)}';
      case Currency.eth:
        return 'Ξ${(amount / 2500).toStringAsFixed(6)}';
    }
  }

  Future<void> setCurrency(Currency c) async {
    _currency = c;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, c.index);
  }


}
