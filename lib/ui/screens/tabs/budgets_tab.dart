import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../logic/providers/currency_provider.dart';
import '../../../logic/providers/user_settings_provider.dart';
import '../widgets/premium_primitives.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/empty_state.dart';

class BudgetsTab extends StatefulWidget {
  final VoidCallback? onAddBudget;
  const BudgetsTab({super.key, this.onAddBudget});

  @override
  State<BudgetsTab> createState() => _BudgetsTabState();
}

class _BudgetsTabState extends State<BudgetsTab> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _budgets = [];
  bool _isLoading = true;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscribeToBudgets();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _subscribeToBudgets() {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final userId = _supabase.auth.currentUser!.id;
    _subscription = _supabase
        .from('budgets')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .listen((data) {
      if (mounted) {
        setState(() {
          _budgets = data;
          _isLoading = false;
        });
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Padding(
              padding: EdgeInsets.only(top: 80, left: isNarrow ? 16 : 24, right: isNarrow ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isDark, isNarrow),
                  const SizedBox(height: 32),
                  Expanded(
                    child: _isLoading 
                      ? _buildLoadingState() 
                      : (_budgets.isEmpty ? _buildEmptyState() : _buildList(currency, settings, isDark)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark, bool isNarrow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Presupuestos', 
          style: TextStyle(
            fontSize: isNarrow ? 28 : 32, 
            fontWeight: FontWeight.w900, 
            color: isDark ? AppTheme.textSnow : AppTheme.textSlate
          )
        ),
        const SizedBox(height: 4),
        const Text(
          'Establece límites sólidos para tus gastos.', 
          style: TextStyle(color: AppTheme.textDim, fontSize: 15)
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: SkeletonBox(height: 140, borderRadius: 16),
      ),
    );
  }

  Widget _buildEmptyState() {
    return PremiumEmptyState(
      title: 'Sin presupuestos',
      subtitle: 'Define límites de gasto para tus categorías principales.',
      icon: Icons.donut_large_rounded,
      actionLabel: 'Crear Presupuesto',
      onAction: widget.onAddBudget,
    );
  }

  Widget _buildList(CurrencyProvider currency, UserSettingsProvider settings, bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 40),
      itemCount: _budgets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final b = _budgets[index];
        final category = b['category'] ?? 'Otros';
        final color = AppTheme.categoryColor(category);
        final spent = (b['spent'] ?? 0).toDouble();
        final limit = (b['amount'] ?? 1).toDouble();
        
        return _buildBudgetCard(category, spent, limit, color, currency, settings, isDark);
      },
    );
  }

  Widget _buildBudgetCard(String category, double spent, double limit, Color color, CurrencyProvider currency, UserSettingsProvider settings, bool isDark) {
    final progress = (spent / limit).clamp(0.0, 1.0);
    final isOver = progress >= 0.8;

    return SolidCard(
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1), 
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Icon(Icons.pie_chart_outline_rounded, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(
                      isOver ? (progress >= 1.0 ? 'Límite excedido' : 'Cerca del límite') : 'En buen camino', 
                      style: TextStyle(
                        color: progress >= 1.0 ? AppTheme.expenseRed : (isOver ? AppTheme.accentAmber : AppTheme.successBlue), 
                        fontSize: 12,
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ],
                ),
              ),
              Text(
                settings.isPrivacyMode ? '••••' : currency.format(limit),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Animated Progress Bar
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(seconds: 1),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              return Column(
                children: [
                  LinearProgressIndicator(
                    value: val,
                    backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                    valueColor: AlwaysStoppedAnimation<Color>(val >= 1.0 ? AppTheme.expenseRed : color),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(0)}% consumido', 
                style: TextStyle(
                  color: progress >= 1.0 ? AppTheme.expenseRed : color, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 12
                )
              ),
              Text(
                settings.isPrivacyMode ? '••••' : 'Gastado: ${currency.format(spent)}', 
                style: const TextStyle(color: AppTheme.textDim, fontSize: 12)
              ),
            ],
          ),
        ],
      ),
    );
  }
}
