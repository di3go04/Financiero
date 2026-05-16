import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../logic/providers/currency_provider.dart';
import '../../../logic/providers/user_settings_provider.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/insight_card.dart';
import '../widgets/premium_primitives.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  double _balance = 0;
  double _income = 0;
  double _expenses = 0;
  List<dynamic> _recentTransactions = [];
  bool _isLoading = true;
  StreamSubscription? _subscription;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _subscribeToDashboardData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  void _subscribeToDashboardData() {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final userId = _supabase.auth.currentUser!.id;
    _subscription = _supabase
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .listen((data) {
      if (mounted) {
        double inc = 0;
        double exp = 0;
        for (var tx in data) {
          final amt = (tx['amount'] as num).toDouble();
          if (tx['type'] == 'income') {
            inc += amt;
          } else {
            exp += amt;
          }
        }
        setState(() {
          _income = inc;
          _expenses = exp;
          _balance = inc - exp;
          _recentTransactions = data.take(5).toList();
          _isLoading = false;
        });
        _fadeController.forward();
      }
    }, onError: (_) {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<CurrencyProvider>(context);
    final settings = Provider.of<UserSettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 80, left: 24, right: 24, bottom: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: FadeTransition(
            opacity: _fadeController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreeting(isDark),
                const SizedBox(height: 32),
                _buildSummaryCards(currency, settings, isDesktop, isDark),
                const SizedBox(height: 40),
                _buildSectionHeader('Análisis Inteligente', isDark),
                const SizedBox(height: 16),
                _buildInsights(isDesktop),
                const SizedBox(height: 40),
                _buildSectionHeader('Movimientos Recientes', isDark),
                const SizedBox(height: 16),
                _buildRecentTransactions(currency, settings, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(bool isDark) {
    final name = _supabase.auth.currentUser?.userMetadata?['full_name'] ?? 'Usuario';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hola, $name',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.textSnow : AppTheme.textSlate,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Aquí tienes tu resumen financiero de hoy.',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(CurrencyProvider currency, UserSettingsProvider settings, bool isDesktop, bool isDark) {
    final cards = [
      _buildValueCard('Balance Total', _balance, AppTheme.primaryIndigo, Icons.account_balance_wallet_rounded, currency, settings, isDark),
      _buildValueCard('Ingresos', _income, AppTheme.incomeTeal, Icons.arrow_upward_rounded, currency, settings, isDark),
      _buildValueCard('Gastos', _expenses, AppTheme.expenseRose, Icons.arrow_downward_rounded, currency, settings, isDark),
    ];

    if (isDesktop) {
      return SizedBox(
        height: 160,
        child: Row(
          children: cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: c))).toList(),
        ),
      );
    } else {
      return SizedBox(
        height: 140,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: cards.map((c) => SizedBox(width: 280, child: Padding(padding: const EdgeInsets.only(right: 16), child: c))).toList(),
        ),
      );
    }
  }

  Widget _buildValueCard(String title, double value, Color color, IconData icon, CurrencyProvider currency, UserSettingsProvider settings, bool isDark) {
    return SolidCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
            ],
          ),
          const Spacer(),
          Text(
            settings.isPrivacyMode ? '••••' : currency.format(value),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDark ? AppTheme.textSnow : AppTheme.textSlate,
      ),
    );
  }

  Widget _buildInsights(bool isDesktop) {
    final insights = [
      const InsightCard(
        title: 'Ahorro Positivo',
        description: 'Has ahorrado un 15% más que el mes pasado.',
        icon: Icons.trending_up_rounded,
        color: AppTheme.incomeTeal,
      ),
      const InsightCard(
        title: 'Meta en Camino',
        description: 'Estás cerca de lograr tu meta de ahorro.',
        icon: Icons.auto_awesome_rounded,
        color: AppTheme.primaryIndigo,
      ),
    ];

    return isDesktop
        ? Row(children: insights.map((i) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 16), child: i))).toList())
        : Column(children: insights.map((i) => Padding(padding: const EdgeInsets.only(bottom: 12), child: i)).toList());
  }

  Widget _buildRecentTransactions(CurrencyProvider currency, UserSettingsProvider settings, bool isDark) {
    if (_isLoading) {
      return Column(children: List.generate(3, (index) => const Padding(padding: EdgeInsets.only(bottom: 12), child: SkeletonBox(height: 70, borderRadius: 12))));
    }

    if (_recentTransactions.isEmpty) {
      return const SolidCard(child: Center(child: Text('No hay movimientos recientes.')));
    }

    return Column(
      children: _recentTransactions.map((tx) {
        final isExpense = tx['type'] == 'expense';
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SolidCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppTheme.categoryColor(tx['category']).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(isExpense ? Icons.shopping_bag_outlined : Icons.payments_outlined, color: AppTheme.categoryColor(tx['category']), size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(child: Text(tx['description'] ?? tx['category'], style: const TextStyle(fontWeight: FontWeight.w600))),
                Text(
                  settings.isPrivacyMode ? '••••' : '${isExpense ? "-" : "+"} ${currency.format((tx['amount'] as num).toDouble())}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: isExpense ? AppTheme.expenseRose : AppTheme.incomeTeal),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
