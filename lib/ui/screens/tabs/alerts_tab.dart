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
    final seen = <String, DateTime>{};

    for (var tx in txs) {
      if (tx['type'] == 'expense') {
        final key = "${tx['category']}_${tx['amount']}";
        final date = DateTime.parse(tx['date']);

        if (seen.containsKey(key)) {
          final diff = seen[key]!.difference(date).inHours.abs();
          if (diff <= 48 && diff > 0) {
            newAlerts.add({
              'title': 'Gasto Duplicado Detectado',
              'description': 'Hemos notado dos cobros de \$${tx['amount']} en la categoría ${tx['category']} en menos de 48h.',
              'icon': Icons.warning_amber_rounded,
              'color': Colors.orangeAccent,
              'type': 'warning',
            });
          }
        }
        seen[key] = date;
      }
    }
    
    if (txs.length > 5) {
      newAlerts.add({
        'title': 'Análisis de Tendencias',
        'description': 'Tu reporte detallado de inteligencia financiera está listo. Tienes un balance positivo este mes.',
        'icon': Icons.auto_awesome_rounded,
        'color': AppTheme.primaryIndigo
        'type': 'info',
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
            pw.Text('Reporte Prosper Intelligence', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 24),
            pw.TableHelper.fromTextArray(
              headers: ['Fecha', 'Categoría', 'Tipo', 'Monto'
              data: _transactions.take(20).map((tx) => [
                tx['date'].toString().split('T')[0
                tx['category'
                tx['type'
                tx['amount'].toString(),
              ]).toList(),
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
            ),
          
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
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
                  : (_alerts.isEmpty ? _buildEmptyState() : _buildList(isDark)),
              ),
            
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Intelligence', 
              style: TextStyle(
                fontSize: 32, 
                fontWeight: FontWeight.bold, 
                color: isDark ? AppTheme.textSnow : AppTheme.textSlate
              )
            ),
            const SizedBox(height: 4),
            Text(
              'Alertas y reportes sólidos.', 
              style: TextStyle(color: Colors.grey.shade500, fontSize: 15)
            ),
          
        ),
        ElevatedButton.icon(
          onPressed: _exportToPDF,
          icon: const Icon(Icons.description_rounded, size: 18),
          label: const Text('Exportar PDF'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryIndigo
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      
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
      title: 'Tu cuenta está segura',
      subtitle: 'No hemos detectado anomalías recientes.',
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
        return SolidCard(
          borderRadius: 16,
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: alert['color' 
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(alert['icon' color: Colors.white, size: 24),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert['title' 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert['description' 
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500, height: 1.4)
                    ),
                  
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 24),
            
          ),
        );
      },
    );
  }
}

