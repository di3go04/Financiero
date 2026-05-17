import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:csv/csv.dart';
import '../../../core/theme/app_theme.dart';
import '../../../logic/providers/currency_provider.dart';
import '../../../logic/providers/user_settings_provider.dart';
import '../../../logic/providers/transaction_provider.dart';
import '../widgets/premium_primitives.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/prosper_empty_state.dart';
import '../widgets/transaction_form.dart';

class TransactionsTab extends StatefulWidget {
  const TransactionsTab({super.key});

  @override
  State<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<TransactionsTab> with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  String _searchQuery = '';
  String _selectedFilter = 'Todas';
  final List<String> _filters = ['Todas', 'Ingresos', 'Gastos'];

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final transactions = transactionProvider.transactions;
    
    // Filter logic
    final filteredData = transactions.where((tx) {
      final desc = (tx['description'] ?? '').toString().toLowerCase();
      final cat = (tx['category'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      final matchesSearch = desc.contains(query) || cat.contains(query);
      
      final isExpense = tx['type'] == 'expense';
      final matchesFilter = _selectedFilter == 'Todas' || 
                           (_selectedFilter == 'Ingresos' && !isExpense) || 
                           (_selectedFilter == 'Gastos' && isExpense);
      return matchesSearch && matchesFilter;
    }).toList();

    final currency = Provider.of<CurrencyProvider>(context);
    final settings = Provider.of<UserSettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: transactionProvider.isLoading && transactions.isEmpty
        ? const ListSkeleton(key: ValueKey('loading'))
        : LayoutBuilder(
            key: const ValueKey('content'),
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
                        _buildHeader(isDark, isNarrow, transactions),
                        const SizedBox(height: 24),
                        _buildSearchAndFilters(isDark, isNarrow),
                        const SizedBox(height: 24),
                        Expanded(
                          child: filteredData.isEmpty 
                            ? _buildEmptyState() 
                            : _buildList(filteredData, currency, settings, isDark),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }

  Widget _buildEmptyState() {
    return ProsperEmptyState(
      title: 'Sin movimientos aún',
      description: 'Tu historial está vacío. Comienza registrando un ingreso o un gasto para ver el análisis de tus finanzas.',
      buttonLabel: 'Añadir mi primera transacción',
      lottieAsset: 'https://assets10.lottiefiles.com/packages/lf20_0s6tfbuc.json',
      icon: Icons.receipt_long_rounded,
      onAction: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const TransactionForm(),
      ),
    );
  }


  Widget _buildHeader(bool isDark, bool isNarrow, List<dynamic> transactions) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Historial', 
              style: TextStyle(
                fontSize: isNarrow ? 28 : 32, 
                fontWeight: FontWeight.w900, 
                color: isDark ? AppTheme.textSnow : AppTheme.textSlate
              )
            ),
            const SizedBox(height: 4),
            const Text(
              'Gestión sólida de tus movimientos.', 
              style: TextStyle(color: AppTheme.textDim, fontSize: 14)
            ),
          ],
        ),
        IconButton.filledTonal(
          onPressed: () => _exportToCSV(transactions),
          icon: const Icon(Icons.download_rounded),
          tooltip: 'Exportar CSV',
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
            foregroundColor: AppTheme.primaryBlue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  void _exportToCSV(List<dynamic> transactions) {
    List<List<dynamic>> rows = [
      ['Fecha', 'Descripción', 'Categoría', 'Tipo', 'Monto']
    ];
    for (var tx in transactions) {
      rows.add([
        tx['date'],
        tx['description'] ?? '',
        tx['category'],
        tx['type'],
        tx['amount']
      ]);
    }
    String csv = const ListToCsvConverter().convert(rows);
    debugPrint(csv);
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

  Widget _buildSearchAndFilters(bool isDark, bool isNarrow) {
    return Column(
      children: [
        TextField(
          onChanged: (val) => setState(() => _searchQuery = val),
          decoration: InputDecoration(
            hintText: 'Buscar por descripción o categoría...',
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
                  selectedColor: AppTheme.primaryBlue,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      itemCount: 6,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: SkeletonBox(height: 80, borderRadius: 16),
      ),
    );
  }

  Widget _buildEmptyState() {
    return PremiumEmptyState(
      title: 'No hay resultados',
      subtitle: 'Intenta con otra búsqueda o filtro.',
      icon: Icons.search_off_rounded,
      actionLabel: 'Ver todo',
      onAction: () => setState(() {
        _searchQuery = '';
        _selectedFilter = 'Todas';
      }),
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
        final color = AppTheme.categoryColor(tx['category'] ?? '');
        
        return SolidCard(
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(
                  isExpense ? Icons.shopping_bag_outlined : Icons.payments_outlined, 
                  color: color, 
                  size: 22
                ),
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
                      tx['category'] ?? 'General', 
                      style: const TextStyle(fontSize: 12, color: AppTheme.textDim)
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
                      fontWeight: FontWeight.w900, 
                      fontSize: 16,
                      color: isExpense ? AppTheme.expenseRed : AppTheme.successBlue,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        tx['date'].toString().split('T')[0], 
                        style: const TextStyle(fontSize: 11, color: AppTheme.textDim)
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _editTransaction(tx),
                        icon: const Icon(Icons.edit_note_rounded, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: AppTheme.primaryBlue,
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
