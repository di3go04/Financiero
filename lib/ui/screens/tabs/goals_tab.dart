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

class GoalsTab extends StatefulWidget {
  final VoidCallback? onAddGoal;
  const GoalsTab({super.key, this.onAddGoal});

  @override
  State<GoalsTab> createState() => _GoalsTabState();
}

class _GoalsTabState extends State<GoalsTab> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _goals = [];
  bool _isLoading = true;
  StreamSubscription? _subscription;
  double _simulationMonthly = 500;

  @override
  void initState() {
    super.initState();
    _subscribeToGoals();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _subscribeToGoals() {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final userId = _supabase.auth.currentUser!.id;
    _subscription = _supabase
        .from('savings_goals')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .listen((data) {
      if (mounted) {
        setState(() {
          _goals = data;
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
        constraints: const BoxConstraints(maxWidth: 850),
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
                  : (_goals.isEmpty ? _buildEmptyState() : _buildList(currency, settings, isDark)),
              ),
              _buildSimulator(currency, isDark),
            
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
          'Metas de Ahorro', 
          style: TextStyle(
            fontSize: 32, 
            fontWeight: FontWeight.bold, 
            color: isDark ? AppTheme.textSnow : AppTheme.textSlate
          )
        ),
        const SizedBox(height: 4),
        Text(
          'Visualiza tu progreso financiero sólido.', 
          style: TextStyle(color: Colors.grey.shade500, fontSize: 15)
        ),
      
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: SkeletonBox(height: 160, borderRadius: 16),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const PremiumEmptyState(
      title: 'Sin metas activas',
      subtitle: 'Comienza a ahorrar para tus sueños.',
      icon: Icons.track_changes_rounded,
      actionLabel: 'Nueva Meta',
      onAction: widget.onAddGoal,
    );
  }

  Widget _buildList(CurrencyProvider currency, UserSettingsProvider settings, bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: _goals.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final g = _goals[index];
        final current = (g['current_amount'] ?? 0).toDouble();
        final target = (g['target_amount'] ?? 1).toDouble();
        final progress = (current / target).clamp(0.0, 1.0);
        
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
                      color: AppTheme.primaryIndigo
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(g['name' style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(
                          'Objetivo: ${currency.format(target)}', 
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12)
                        ),
                      
                    ),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.primaryIndigo),
                  ),
                
              ),
              const SizedBox(height: 24),
              // Solid Progress Bar
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04), 
                  borderRadius: BorderRadius.circular(6)
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryIndigo
                            borderRadius: BorderRadius.circular(6),
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
                    'Ahorrado: ${currency.format(current)}', 
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)
                  ),
                  Text(
                    'Faltan: ${currency.format(target - current)}', 
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13)
                  ),
                
              ),
            
          ),
        );
      },
    );
  }

  Widget _buildSimulator(CurrencyProvider currency, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 40),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Simulador de Ahorro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _simulationMonthly,
                  min: 0,
                  max: 5000,
                  divisions: 50,
                  activeColor: AppTheme.primaryIndigo
                  onChanged: (val) => setState(() => _simulationMonthly = val),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                currency.format(_simulationMonthly),
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryIndigo),
              ),
            
          ),
          Text(
            'Si ahorras ${currency.format(_simulationMonthly)} al mes, llegarás a tus metas más rápido.',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        
      ),
    );
  }
}

