import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/premium_primitives.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/empty_state.dart';

class AlertsTab extends StatefulWidget {
  const AlertsTab({super.key});

  @override
  State<AlertsTab> createState() => _AlertsTabState();
}

class _AlertsTabState extends State<AlertsTab> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _transactions = [];
  List<Map<String, dynamic>> _alerts = [];
  bool _isLoading = true;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscribeToTransactions();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _subscribeToTransactions() {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final userId = _supabase.auth.currentUser!.id;
    _subscription = _supabase
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('date', ascending: false)
        .listen((data) {
      if (mounted) {
        setState(() {
          _transactions = data;
          _isLoading = false;
        });
        _generateSmartAlerts(data);
      }
    }, onError: (_) {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  void _generateSmartAlerts(List<dynamic> txs) {
    List<Map<String, dynamic>> newAlerts = [];
    final seenDuplicates = <String, DateTime>{};
    final seenSubscriptions = <String, int>{};

    for (var tx in txs) {
      if (tx['type'] == 'expense') {
        final amt = (tx['amount'] as num).toDouble();
        final desc = (tx['description'] ?? '').toString();
        final date = DateTime.parse(tx['date']);
        
        // 1. Detect Duplicates (Same amount & category in 48h)
        final dupKey = "${tx['category']}_${tx['amount']}";
        if (seenDuplicates.containsKey(dupKey)) {
          final diff = seenDuplicates[dupKey]!.difference(date).inHours.abs();
          if (diff <= 48 && diff > 0) {
            newAlerts.add({
              'title': 'Posible Cobro Duplicado',
              'description': 'Detectamos dos cobros idénticos en ${tx['category']} en menos de 48h.',
              'icon': Icons.warning_amber_rounded,
              'color': AppTheme.accentAmber,
              'type': 'warning',
            });
          }
        }
        seenDuplicates[dupKey] = date;

        // 2. Detect High Spending (> 500)
        if (amt > 500) {
          newAlerts.add({
            'title': 'Gasto Elevado Detectado',
            'description': 'Has realizado un pago de ${amt.toStringAsFixed(2)} en $desc.',
            'icon': Icons.trending_up_rounded,
            'color': AppTheme.expenseRed,
            'type': 'danger',
          });
        }

        // 3. Potential Subscriptions (Simple heuristic: same name in history)
        seenSubscriptions[desc] = (seenSubscriptions[desc] ?? 0) + 1;
        if (seenSubscriptions[desc] == 2) {
          newAlerts.add({
            'title': 'Nueva Suscripción?',
            'description': 'Hemos notado pagos recurrentes a $desc. Considere presupuestarlo.',
            'icon': Icons.subscriptions_rounded,
            'color': AppTheme.primaryBlue,
            'type': 'info',
          });
        }
      }
    }
    
    if (txs.length > 10) {
      newAlerts.add({
        'title': 'Análisis de Inteligencia',
        'description': 'Tu reporte Prosper avanzado está listo para exportar. Tienes una buena salud financiera.',
        'icon': Icons.auto_awesome_rounded,
        'color': AppTheme.successBlue,
        'type': 'success',
      });
    }

    if (mounted) setState(() => _alerts = newAlerts);
  }

  Future<void> _exportToPDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('PROSPER INTELLIGENCE REPORT', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 24),
            pw.TableHelper.fromTextArray(
              headers: ['Fecha', 'Descripción', 'Categoría', 'Tipo', 'Monto'],
              data: _transactions.map((tx) => [
                tx['date'].toString().split('T')[0],
                tx['description'] ?? '',
                tx['category'] ?? '',
                tx['type'] ?? '',
                tx['amount'].toString(),
              ]).toList(),
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
            ),
          ],
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
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
                      : (_alerts.isEmpty ? _buildEmptyState() : _buildList(isDark)),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Intelligence', 
              style: TextStyle(
                fontSize: isNarrow ? 28 : 32, 
                fontWeight: FontWeight.w900, 
                color: isDark ? AppTheme.textSnow : AppTheme.textSlate
              )
            ),
            const SizedBox(height: 4),
            const Text(
              'Alertas predictivas y reportes.', 
              style: TextStyle(color: AppTheme.textDim, fontSize: 14)
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _exportToPDF,
          icon: const Icon(Icons.description_rounded, size: 18),
          label: isNarrow ? const Text('PDF') : const Text('Exportar PDF'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: SkeletonBox(height: 100, borderRadius: 16),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const PremiumEmptyState(
      title: 'Tu cuenta está protegida',
      subtitle: 'No hemos detectado anomalías o gastos inusuales en tus últimos movimientos.',
      icon: Icons.verified_user_rounded,
    );
  }

  Widget _buildList(bool isDark) {
    return ListView.separated(
      itemCount: _alerts.length,
      padding: const EdgeInsets.only(bottom: 40),
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final alert = _alerts[index];
        final color = alert['color'] as Color;

        return SolidCard(
          borderRadius: 16,
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(alert['icon'] as IconData, color: color, size: 24),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert['title'] ?? 'Alerta', 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert['description'] ?? '', 
                      style: const TextStyle(fontSize: 13, color: AppTheme.textDim, height: 1.4)
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.textDim, size: 24),
            ],
          ),
        );
      },
    );
  }
}
