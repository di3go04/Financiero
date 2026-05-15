import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/debt_simulator.dart';
import '../widgets/premium_primitives.dart';

class GoalsTab extends StatefulWidget {
  const GoalsTab({super.key});

  @override
  State<GoalsTab> createState() => _GoalsTabState();
}

class _GoalsTabState extends State<GoalsTab> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<dynamic> _goals = [];
  double _reductionFactor = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchGoals();
  }

  Future<void> _fetchGoals() async {
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser!.id;
      final data = await _supabase.from('savings_goals').select().eq('user_id', userId);
      setState(() {
        _goals = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.only(top: 100, left: 20, right: 20, bottom: 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Metas de Ahorro', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Simulador de Ahorro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text('Si reduces tus gastos hormiga en:', style: TextStyle(color: Colors.grey)),
                          Slider(
                            value: _reductionFactor,
                            onChanged: (v) => setState(() => _reductionFactor = v),
                            activeColor: AppTheme.primaryCyan,
                            label: '${(_reductionFactor * 100).toInt()}%',
                            divisions: 10,
                          ),
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: _reductionFactor),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              final monthsEarlier = value > 0 ? (1 + value * 5).toInt() : 0;
                              return Column(
                                children: [
                                  Text(
                                    'Â¡LlegarÃ¡s a tus metas $monthsEarlier meses antes!',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryCyan),
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: (0.6 + value * 0.4).clamp(0.0, 1.0),
                                    backgroundColor: Colors.grey.withValues(alpha: 0.1),
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryCyan),
                                    minHeight: 12,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const DebtSimulator(),
                    const SizedBox(height: 32),
                    const Text('Tus Metas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _goals.isEmpty
                      ? const GlassCard(child: Center(child: Text('No hay metas activas.')))
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _goals.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final g = _goals[index];
                            return GoalCard(name: g['name'], target: g['target_amount'], current: g['current_amount']);
                          },
                        ),
                  ],
                ),
              ),
            ),
          );
  }
}

class GoalCard extends StatelessWidget {
  final String name;
  final double target;
  final double current;

  const GoalCard({super.key, required this.name, required this.target, required this.current});

  @override
  Widget build(BuildContext context) {
    final progress = (current / target).clamp(0.0, 1.0);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            borderRadius: BorderRadius.circular(6),
            backgroundColor: Colors.grey.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryCyan),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${current.toStringAsFixed(0)} â‚¬ ahorrados', style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('Meta: ${target.toStringAsFixed(0)} â‚¬', style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
