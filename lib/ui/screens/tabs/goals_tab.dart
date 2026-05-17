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
                      : (_goals.isEmpty ? _buildEmptyState() : _buildList(currency, settings, isDark)),
                  ),
                  _buildSimulator(currency, isDark, isNarrow),
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
          'Metas de Ahorro', 
          style: TextStyle(
            fontSize: isNarrow ? 28 : 32, 
            fontWeight: FontWeight.w900, 
            color: isDark ? AppTheme.textSnow : AppTheme.textSlate
          )
        ),
        const SizedBox(height: 4),
        const Text(
          'Visualiza y simula tu progreso Prosper.', 
          style: TextStyle(color: AppTheme.textDim, fontSize: 15)
        ),
      ],
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
    return PremiumEmptyState(
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
        
        final remaining = target - current;
        final monthsToGoal = _simulationMonthly > 0 ? (remaining / _simulationMonthly).ceil() : 999;

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
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.rocket_launch_rounded, color: AppTheme.primaryBlue, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(g['name'] ?? 'Meta', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(
                          'Objetivo: ${currency.format(target)}', 
                          style: const TextStyle(color: AppTheme.textDim, fontSize: 12)
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: AppTheme.primaryBlue),
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
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
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
                    'Ahorrado: ${currency.format(current)}', 
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)
                  ),
                  Text(
                    'Meta en: $monthsToGoal meses', 
                    style: const TextStyle(color: AppTheme.successBlue, fontSize: 13, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSimulator(CurrencyProvider currency, bool isDark, bool isNarrow) {
    return SolidCard(
      padding: const EdgeInsets.all(24),
      color: isDark ? AppTheme.surfaceDark.withValues(alpha: 0.5) : AppTheme.primaryBlue.withValues(alpha: 0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.speed_rounded, color: AppTheme.primaryBlue),
              SizedBox(width: 12),
              Text(
                'Simulador de Aceleración', 
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Ajusta tu ahorro mensual para ver cómo se acortan los plazos.',
            style: TextStyle(color: AppTheme.textDim, fontSize: 13),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppTheme.primaryBlue,
                    inactiveTrackColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    thumbColor: AppTheme.primaryBlue,
                    overlayColor: AppTheme.primaryBlue.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: _simulationMonthly,
                    min: 0,
                    max: 5000,
                    divisions: 100,
                    onChanged: (val) => setState(() => _simulationMonthly = val),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  currency.format(_simulationMonthly),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
