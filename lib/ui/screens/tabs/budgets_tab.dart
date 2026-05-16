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

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.only(top: 100, left: 24, right: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDark),
              const SizedBox(height: 32),
              Expanded(
                child: _isLoading 
                  ? _buildLoadingState() 
                  : (_budgets.isEmpty ? _buildEmptyState() : _buildList(currency, settings, isDark)),
              ),
            
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Presupuestos', 
          style: TextStyle(
            fontSize: 32, 
            fontWeight: FontWeight.bold, 
            color: isDark ? AppTheme.textSnow : AppTheme.textSlate
          )
        ),
        const SizedBox(height: 4),
        Text(
          'Límites de gasto sólidos y claros.', 
          style: TextStyle(color: Colors.grey.shade500, fontSize: 15)
        ),
      
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
    return const PremiumEmptyState(
      title: 'Sin presupuestos',
      subtitle: 'Define límites de gasto para tus categorías.',
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
        final category = b['category'] ?? 'Otra';
        final color = AppTheme.categoryColor(category);
        final spent = (b['spent'] ?? 0).toDouble();
        final limit = (b['limit_amount'] ?? 1).toDouble();
        
        return _buildBudgetCard(category, spent, limit, color, currency, settings, isDark);
      },
    );
  }

  Widget _buildBudgetCard(String category, double spent, double limit, Color color, CurrencyProvider currency, UserSettingsProvider settings, bool isDark) {
    final progress = (spent / limit).clamp(0.0, 1.0);
    final isOver = progress >= 1.0;

    return SolidCard(
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.pie_chart_outline_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(
                      isOver ? 'Límite excedido' : 'En buen camino', 
                      style: TextStyle(color: isOver ? AppTheme.expenseRose : Colors.grey, fontSize: 12)
                    ),
                  
                ),
              ),
              Text(
                settings.isPrivacyMode ? '••••' : currency.format(limit),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            
          ),
          const SizedBox(height: 20),
          // Solid Progress Bar
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04), 
              borderRadius: BorderRadius.circular(4)
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(0)}% consumido', 
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)
              ),
              Text(
                settings.isPrivacyMode ? '••••' : 'Gastado: ${currency.format(spent)}', 
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12)
              ),
            
          ),
        
      ),
    );
  }
}

