import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/premium_button.dart';
import '../widgets/premium_primitives.dart';

class TransactionsTab extends StatefulWidget {
  const TransactionsTab({super.key});

  @override
  State<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<TransactionsTab> with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  List<dynamic> _transactions = [];
  bool _isLoading = true;
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fetchTransactions();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  Future<void> _fetchTransactions() async {
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser!.id;
      final data = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);

      setState(() {
        _transactions = data;
        _isLoading = false;
      });
      _listController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Padding(
                  padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      Expanded(
                        child: _transactions.isEmpty
                            ? const Center(child: Text('No hay transacciones aÃºn.'))
                            : ListView.separated(
                                itemCount: _transactions.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final tx = _transactions[index];
                                  final isExpense = tx['type'] == 'expense';
                                  
                                  return AnimatedBuilder(
                                    animation: _listController,
                                    builder: (context, child) {
                                      final delay = index * 0.05;
                                      final animValue = Curves.easeOutCubic.transform(
                                        (_listController.value - delay).clamp(0.0, 1.0),
                                      );
                                      return Transform.translate(
                                        offset: Offset(0, 50 * (1 - animValue)),
                                        child: Opacity(
                                          opacity: animValue,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: GlassCard(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryCyan.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(Icons.shopping_bag_outlined, color: AppTheme.primaryCyan),
                                        ),
                                        title: Text(tx['description'] ?? tx['category'], style: const TextStyle(fontWeight: FontWeight.w600)),
                                        subtitle: Text(tx['category']),
                                        trailing: Text(
                                          '${isExpense ? "-" : "+"} ${tx['amount']} â‚¬',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold, 
                                            color: isExpense ? Colors.redAccent : AppTheme.primaryCyan,
                                            fontFeatures: const [FontFeature.tabularFigures()],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.primaryCyan,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Historial', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        PremiumButton(
          onPressed: () {},
          child: Container(
            padding: const EdgeInsets.all(12),
            child: const Icon(Icons.download_rounded, color: AppTheme.primaryCyan),
          ),
        ),
      ],
    );
  }
}
