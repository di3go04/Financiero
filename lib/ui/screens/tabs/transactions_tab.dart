import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:csv/csv.dart';
import '../../../core/theme/app_theme.dart';
import '../../../logic/providers/currency_provider.dart';
import '../../../logic/providers/user_settings_provider.dart';
import '../widgets/premium_primitives.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/empty_state.dart';
import '../widgets/transaction_form.dart';

class TransactionsTab extends StatefulWidget {
  const TransactionsTab({super.key});

  @override
  State<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<TransactionsTab> with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  List<dynamic> _transactions = [];
  bool _isLoading = true;
  StreamSubscription? _subscription;
  String _searchQuery = '';
  String _selectedFilter = 'Todas';
  final List<String> _filters = ['Todas', 'Ingresos', 'Gastos'];

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
      }
    }, onError: (error) {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  List<dynamic> get _filteredTransactions {
    return _transactions.where((tx) {
      final matchesSearch = (tx['description'] ?? tx['category']).toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final isExpense = tx['type'] == 'expense';
      final matchesFilter = _selectedFilter == 'Todas' || 
                           (_selectedFilter == 'Ingresos' && !isExpense) || 
                           (_selectedFilter == 'Gastos' && isExpense);
      return matchesSearch && matchesFilter;
    }).toList();
  }

  void _exportToCSV() {
    List<List<dynamic>> rows = [
      ['Fecha', 'Descripción', 'Categoría', 'Tipo', 'Monto']
    ];
    for (var tx in _transactions) {
      rows.add([
        tx['date'],
        tx['description'] ?? '',
        tx['category'],
        tx['type'],
        tx['amount']
      ]);
    }
    String csv = const ListToCsvConverter().convert(rows);
    // In a real app we'd save this, but for now we just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reporte CSV generado exitosamente (Simulado)')),
    );
  }

  void _editTransaction(Map<String, dynamic> tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionForm(initialData: tx),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = _filteredTransactions;
    final currency = Provider.of<CurrencyProvider>(context);
    final settings = Provider.of<UserSettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Padding(
          padding: const EdgeInsets.only(top: 80, left: 24, right: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDark),
              const SizedBox(height: 24),
              _buildSearchAndFilters(isDark),
              const SizedBox(height: 24),
              Expanded(
                child: _isLoading 
                  ? _buildLoadingState() 
                  : (filteredData.isEmpty ? _buildEmptyState() : _buildList(filteredData, currency, settings, isDark)),
              ),
            ],
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
              'Historial', 
              style: TextStyle(
                fontSize: 32, 
                fontWeight: FontWeight.bold, 
                color: isDark ? AppTheme.textSnow : AppTheme.textSlate
              )
            ),
            const SizedBox(height: 4),
            Text(
              'Transacciones sólidas y detalladas.', 
              style: TextStyle(color: Colors.grey.shade500, fontSize: 15)
            ),
          ],
        ),
        IconButton.filledTonal(
          onPressed: _exportToCSV,
          icon: const Icon(Icons.download_rounded),
          tooltip: 'Exportar CSV',
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.primaryIndigo.withValues(alpha: 0.1),
            foregroundColor: AppTheme.primaryIndigo,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(bool isDark) {
    return Column(
      children: [
        TextField(
          onChanged: (val) => setState(() => _searchQuery = val),
          decoration: InputDecoration(
            hintText: 'Buscar movimientos...',
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: isDark ? AppTheme.surfaceDark : Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _filters.map((filter) {
              final isSelected = _selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (val) => setState(() => _selectedFilter = filter),
                  selectedColor: AppTheme.primaryIndigo,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87)),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: SkeletonBox(height: 80, borderRadius: 16),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const PremiumEmptyState(
      title: 'Sin resultados',
      subtitle: 'No hay transacciones que coincidan.',
      icon: Icons.search_off_rounded,
    );
  }

  Widget _buildList(List<dynamic> data, CurrencyProvider currency, UserSettingsProvider settings, bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 40),
      itemCount: data.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final tx = data[index];
        final isExpense = tx['type'] == 'expense';
        final color = AppTheme.categoryColor(tx['category']);
        
        return SolidCard(
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                child: Icon(isExpense ? Icons.shopping_bag_outlined : Icons.payments_outlined, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx['description'] ?? tx['category'], 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                    Text(
                      tx['category'], 
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500)
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    settings.isPrivacyMode ? '••••' : '${isExpense ? "-" : "+"} ${currency.format((tx['amount'] as num).toDouble())}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 16,
                      color: isExpense ? AppTheme.expenseRose : AppTheme.incomeTeal,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        tx['date'].toString().split('T')[0], 
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500)
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _editTransaction(tx),
                        child: Icon(Icons.edit_note_rounded, size: 18, color: AppTheme.primaryIndigo.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
