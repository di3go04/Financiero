import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription? _subscription;
  StreamSubscription? _authSubscription;

  double _totalBalance = 0;
  double _totalIncome = 0;
  double _totalExpenses = 0;

  List<Map<String, dynamic>> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get totalBalance => _totalBalance;
  double get totalIncome => _totalIncome;
  double get totalExpenses => _totalExpenses;

  TransactionProvider() {
    _loadCacheAndInit();
    _listenToAuth();
  }

  Future<void> _loadCacheAndInit() async {
    await _loadFromCache();
    _init();
  }

  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cached_transactions');
      if (cached != null) {
        _transactions = List<Map<String, dynamic>>.from(json.decode(cached));
        _calculateMetrics();
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Cache error: $e');
    }
  }

  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_transactions', json.encode(_transactions));
    } catch (e) {
      debugPrint('Cache save error: $e');
    }
  }

  void _listenToAuth() {
    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) {
        _init();
      } else if (data.event == AuthChangeEvent.signedOut) {
        _clearData();
      }
    });
  }

  void _clearData() async {
    _transactions = [];
    _totalBalance = 0;
    _totalIncome = 0;
    _totalExpenses = 0;
    _subscription?.cancel();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_transactions');
    notifyListeners();
  }

  void _init() {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _errorMessage = null;
    _subscription?.cancel();
    
    // Optimized stream with specific order and real-time updates
    _subscription = _supabase
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .order('date', ascending: false)
        .listen((data) {
      _transactions = List<Map<String, dynamic>>.from(data);
      _calculateMetrics();
      _saveToCache();
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint('Error in TransactionProvider: $e');
      _errorMessage = 'No se pudieron cargar las transacciones. Por favor, intenta de nuevo.';
      _isLoading = false;
      notifyListeners();
    });
  }

  void _calculateMetrics() {
    double income = 0;
    double expenses = 0;

    for (final tx in _transactions) {
      final amount = (tx['amount'] as num).toDouble();
      if (tx['type'] == 'income') {
        income += amount;
      } else {
        expenses += amount;
      }
    }

    _totalIncome = income;
    _totalExpenses = expenses;
    _totalBalance = income - expenses;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }

  void refresh() {
    _isLoading = true;
    _init();
  }
}
