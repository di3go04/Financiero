import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/dashboard_skeleton.dart';
import '../widgets/insight_card.dart';
import '../widgets/subscription_detector.dart';
import '../widgets/premium_button.dart';
import '../widgets/premium_primitives.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final _supabase = Supabase.instance.client;
  double _balance = 0;
  double _income = 0;
  double _expenses = 0;
  List<dynamic> _recentTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser!.id;
      final txData = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);

      double tempIncome = 0;
      double tempExpenses = 0;

      for (var tx in txData) {
        if (tx['type'] == 'income') {
          tempIncome += tx['amount'];
        } else {
          tempExpenses += tx['amount'];
        }
      }

      setState(() {
        _income = tempIncome;
        _expenses = tempExpenses;
        _balance = tempIncome - tempExpenses;
        _recentTransactions = txData.take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading 
      ? const DashboardSkeleton()
      : RefreshIndicator(
          onRefresh: _fetchDashboardData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceSection(),
                    const SizedBox(height: 24),
                    const HealthScoreCard(),
                    const SizedBox(height: 24),
                    const InsightCard(
                      title: 'Ahorro Potencial',
                      description: 'Si reduces tus gastos en "Ocio" un 10%, ahorrarÃ­as 45â‚¬ extra este mes.',
                      icon: Icons.lightbulb_outline_rounded,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 24),
                    SubscriptionDetector(transactions: _recentTransactions),
                    const SizedBox(height: 24),
                    const Text('DistribuciÃ³n de Gastos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    const CategoryDonutChart(),
                    const SizedBox(height: 24),
                    _buildRecentTransactionsHeader(),
                    const SizedBox(height: 16),
                    _buildTransactionsList(),
                  ],
                ),
              ),
            ),
          ),
        );
  }

  Widget _buildBalanceSection() {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    if (isDesktop) {
      return Row(
        children: [
          Expanded(child: BalanceCard(balance: _balance, income: _income, expenses: _expenses)),
          const SizedBox(width: 24),
          const Expanded(child: GlassCard(child: Center(child: Text('Resumen Semanal', style: TextStyle(fontWeight: FontWeight.bold))))),
        ],
      );
    }
    return BalanceCard(balance: _balance, income: _income, expenses: _expenses);
  }

  Widget _buildRecentTransactionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Transacciones Recientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        PremiumButton(
          onPressed: () {}, 
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Ver todas', style: TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList() {
    return _recentTransactions.isEmpty 
      ? const Center(child: Text('No hay transacciones'))
      : GlassCard(
          padding: EdgeInsets.zero,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentTransactions.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
            itemBuilder: (context, index) {
              final tx = _recentTransactions[index];
              final isExpense = tx['type'] == 'expense';
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryCyan.withValues(alpha: 0.1),
                  child: const Icon(Icons.shopping_bag_outlined, color: AppTheme.primaryCyan, size: 20),
                ),
                title: Text(tx['description'] ?? tx['category'], style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(tx['category'], style: const TextStyle(fontSize: 12)),
                trailing: Text(
                  '${isExpense ? "-" : "+"} ${tx['amount']} â‚¬',
                  style: TextStyle(
                    fontWeight: FontWeight.w600, 
                    color: isExpense ? Colors.redAccent : AppTheme.primaryCyan,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              );
            },
          ),
        );
  }
}

class BalanceCard extends StatelessWidget {
  final double balance;
  final double income;
  final double expenses;

  const BalanceCard({super.key, required this.balance, required this.income, required this.expenses});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      hasGlow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Saldo Total', style: TextStyle(color: Colors.grey, fontSize: 14)),
              Icon(Icons.account_balance_rounded, color: Colors.grey.withValues(alpha: 0.5)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${balance.toStringAsFixed(2)} â‚¬', 
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, fontFeatures: [FontFeature.tabularFigures()])
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _BalanceItem(label: 'Ingresos', amount: income, color: AppTheme.primaryCyan, icon: Icons.south_west_rounded),
              const SizedBox(width: 40),
              _BalanceItem(label: 'Gastos', amount: expenses, color: Colors.redAccent, icon: Icons.north_east_rounded),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _BalanceItem({required this.label, required this.amount, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(
              '${amount.toStringAsFixed(0)} â‚¬', 
              style: const TextStyle(fontWeight: FontWeight.w600, fontFeatures: [FontFeature.tabularFigures()])
            ),
          ],
        ),
      ],
    );
  }
}

class CategoryDonutChart extends StatelessWidget {
  const CategoryDonutChart({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: AspectRatio(
        aspectRatio: 1.3,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(seconds: 1),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.rotate(
              angle: (1 - value) * 3.14 * 2,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(color: AppTheme.primaryCyan, value: 40, title: '40%', radius: 55, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    PieChartSectionData(color: AppTheme.secondaryBlue, value: 30, title: '30%', radius: 55, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    PieChartSectionData(color: Colors.orange, value: 15, title: '15%', radius: 55, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    PieChartSectionData(color: Colors.purple, value: 15, title: '15%', radius: 55, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class HealthScoreCard extends StatelessWidget {
  const HealthScoreCard({super.key});
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          SizedBox(height: 80, width: 80, child: Stack(alignment: Alignment.center, children: [
            CircularProgressIndicator(value: 0.85, strokeWidth: 8, backgroundColor: Colors.grey.withValues(alpha: 0.1), valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryCyan)),
            const Text('85', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ])),
          const SizedBox(width: 20),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Salud Financiera: Excelente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text('Â¡Vas por buen camino! Has ahorrado un 15% mÃ¡s que el mes pasado.', style: TextStyle(color: Colors.grey, fontSize: 13)),
          ])),
        ],
      ),
    );
  }
}
