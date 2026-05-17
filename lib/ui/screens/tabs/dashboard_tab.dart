import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../logic/providers/currency_provider.dart';
import '../../../logic/providers/user_settings_provider.dart';
import '../../../logic/providers/transaction_provider.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/premium_primitives.dart';
import '../widgets/prosper_empty_state.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final _supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final currency = Provider.of<CurrencyProvider>(context);
    final settings = Provider.of<UserSettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (transactionProvider.isLoading) return const DashboardSkeleton();

    // Calculate monthly metrics from provider data
    double inc = 0, exp = 0, prevInc = 0, prevExp = 0;
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;
    final lastMonth = currentMonth == 1 ? 12 : currentMonth - 1;
    final lastMonthYear = currentMonth == 1 ? currentYear - 1 : currentYear;

    for (final tx in transactionProvider.transactions) {
      final amt = (tx['amount'] as num).toDouble();
      final date = DateTime.parse(tx['date']);
      
      if (date.month == currentMonth && date.year == currentYear) {
        if (tx['type'] == 'income') { inc += amt; } else { exp += amt; }
      } else if (date.month == lastMonth && date.year == lastMonthYear) {
        if (tx['type'] == 'income') { prevInc += amt; } else { prevExp += amt; }
      }
    }

    final balance = inc - exp;
    final prevMonthBalance = prevInc - prevExp;
    final recentTransactions = transactionProvider.transactions.take(5).toList();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: transactionProvider.isLoading && transactionProvider.transactions.isEmpty
          ? const DashboardSkeleton(key: ValueKey('loading'))
          : transactionProvider.errorMessage != null
              ? _ErrorState(
                  key: const ValueKey('error'),
                  message: transactionProvider.errorMessage!,
                  onRetry: transactionProvider.refresh,
                )
              : SingleChildScrollView(
                  key: const ValueKey('content'),
                  padding: const EdgeInsets.only(top: 80, left: 24, right: 24, bottom: 40),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _GreetingSection(
                            name: Supabase.instance.client.auth.currentUser?.userMetadata?['full_name'] ?? 'Usuario',
                            isDark: isDark,
                          ),
                          const SizedBox(height: 32),
                          _MainMetrics(
                            balance: balance,
                            income: inc,
                            expenses: exp,
                            prevMonthBalance: prevMonthBalance,
                            currency: currency,
                            settings: settings,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 40),
                          _SmallMetricsRow(
                            income: inc,
                            expenses: exp,
                            currency: currency,
                            settings: settings,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 40),
                          Text(
                            'Movimientos Recientes',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.textSnow : AppTheme.textSlate,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _RecentTransactionsList(
                            transactions: recentTransactions,
                            currency: currency,
                            settings: settings,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}

// ... inside DashboardTab ...

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ProsperEmptyState(
      title: '¡Oops! Algo salió mal',
      description: message,
      buttonLabel: 'Reintentar ahora',
      icon: Icons.cloud_off_rounded,
      onAction: onRetry,
    );
  }
}


// --- Extracted const-friendly sub-widgets ---

class _GreetingSection extends StatelessWidget {
  final String name;
  final bool isDark;
  const _GreetingSection({required this.name, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen Prosper',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Hola de nuevo, $name',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.textSnow : AppTheme.textSlate,
          ),
        ),
      ],
    );
  }
}

class _MainMetrics extends StatelessWidget {
  final double balance, income, expenses, prevMonthBalance;
  final CurrencyProvider currency;
  final UserSettingsProvider settings;
  final bool isDark;

  const _MainMetrics({
    required this.balance,
    required this.income,
    required this.expenses,
    required this.prevMonthBalance,
    required this.currency,
    required this.settings,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final diff = balance - prevMonthBalance;
    final percent = prevMonthBalance == 0 ? 100.0 : (diff / prevMonthBalance.abs()) * 100;
    final isPositive = percent >= 0;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return SolidCard(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Balance Neto del Mes', style: TextStyle(color: AppTheme.textDim, fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  settings.isPrivacyMode ? '••••' : currency.format(balance),
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      color: isPositive ? AppTheme.successBlue : AppTheme.expenseRed,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${percent.toStringAsFixed(1)}% vs mes anterior',
                      style: TextStyle(
                        color: isPositive ? AppTheme.successBlue : AppTheme.expenseRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (screenWidth > 600)
            SizedBox(
              width: 120,
              height: 120,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 35,
                  sections: [
                    PieChartSectionData(value: income.abs(), color: AppTheme.successBlue, radius: 15, showTitle: false),
                    PieChartSectionData(value: expenses.abs(), color: AppTheme.expenseRed, radius: 15, showTitle: false),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SmallMetricsRow extends StatelessWidget {
  final double income, expenses;
  final CurrencyProvider currency;
  final UserSettingsProvider settings;
  final bool isDark;

  const _SmallMetricsRow({
    required this.income,
    required this.expenses,
    required this.currency,
    required this.settings,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 850;
    final cards = [
      _SmallMetricCard(title: 'Ingresos Totales', value: income, color: AppTheme.successBlue, icon: Icons.add_circle_outline_rounded, currency: currency, settings: settings),
      _SmallMetricCard(title: 'Gastos Totales', value: expenses, color: AppTheme.expenseRed, icon: Icons.remove_circle_outline_rounded, currency: currency, settings: settings),
      _SmallMetricCard(title: 'Ahorro Neto', value: income - expenses, color: AppTheme.primaryBlue, icon: Icons.savings_outlined, currency: currency, settings: settings),
    ];

    if (isMobile) {
      return Column(children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 16), child: c)).toList());
    }

    return Row(
      children: cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: c))).toList(),
    );
  }
}

class _SmallMetricCard extends StatelessWidget {
  final String title;
  final double value;
  final Color color;
  final IconData icon;
  final CurrencyProvider currency;
  final UserSettingsProvider settings;

  const _SmallMetricCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    required this.currency,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return SolidCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: AppTheme.textDim, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            settings.isPrivacyMode ? '••••' : currency.format(value),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _RecentTransactionsList extends StatelessWidget {
  final List<dynamic> transactions;
  final CurrencyProvider currency;
  final UserSettingsProvider settings;
  final bool isDark;

  const _RecentTransactionsList({
    required this.transactions,
    required this.currency,
    required this.settings,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const SolidCard(child: Center(child: Text('No hay movimientos recientes.')));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final isExpense = tx['type'] == 'expense';
        final color = AppTheme.categoryColor(tx['category'] ?? '');
        return SolidCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(isExpense ? Icons.shopping_bag_outlined : Icons.payments_outlined, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tx['description'] ?? tx['category'], style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(tx['category'] ?? 'General', style: const TextStyle(color: AppTheme.textDim, fontSize: 11)),
                  ],
                ),
              ),
              Text(
                settings.isPrivacyMode ? '••••' : '${isExpense ? "-" : "+"} ${currency.format((tx['amount'] as num).toDouble())}',
                style: TextStyle(fontWeight: FontWeight.bold, color: isExpense ? AppTheme.expenseRed : AppTheme.successBlue),
              ),
            ],
          ),
        );
      },
    );
  }
}
