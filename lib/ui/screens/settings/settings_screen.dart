import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../logic/providers/theme_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/plaid_service.dart';

import '../widgets/premium_button.dart';
import '../widgets/premium_primitives.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Ajustes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ResponsiveBackground(
        child: ListView(
          padding: const EdgeInsets.only(top: 100, left: 16, right: 16, bottom: 40),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Text('APARIENCIA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
            ),
            SolidCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                title: const Text('Modo de Tema'),
                subtitle: Text(_getThemeName(themeProvider.themeMode)),
                leading: const Icon(Icons.palette_rounded, color: AppTheme.primaryBlue),
                onTap: () => _showThemeDialog(context, themeProvider),
              ),
            ),

            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Text('INTEGRACIONES', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
            ),
            SolidCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                title: const Text('Vincular Cuenta Bancaria'),
                subtitle: const Text('Conecta tu banco via Plaid'),
                leading: const Icon(Icons.account_balance_rounded, color: AppTheme.primaryBlue),
                trailing: const Icon(Icons.add_link_rounded, color: AppTheme.primaryBlue),
                onTap: _linkBankAccount,
              ),
            ),
            
            const SizedBox(height: 48),
            PremiumButton(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
              },
              child: Container(
                padding: const EdgeInsets.all(18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.expenseRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, color: AppTheme.expenseRed),
                    SizedBox(width: 12),
                    Text('Cerrar sesión', style: TextStyle(color: AppTheme.expenseRed, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system: return 'Sistema';
      case ThemeMode.light: return 'Claro';
      case ThemeMode.dark: return 'Oscuro';
    }
  }

  void _showThemeDialog(BuildContext context, ThemeProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Seleccionar Tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Sistema'),
              trailing: provider.themeMode == ThemeMode.system ? const Icon(Icons.check, color: AppTheme.primaryBlue) : null,
              onTap: () {
                provider.setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Claro'),
              trailing: provider.themeMode == ThemeMode.light ? const Icon(Icons.check, color: AppTheme.primaryBlue) : null,
              onTap: () {
                provider.setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Oscuro'),
              trailing: provider.themeMode == ThemeMode.dark ? const Icon(Icons.check, color: AppTheme.primaryBlue) : null,
              onTap: () {
                provider.setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _linkBankAccount() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abriendo pasarela de Plaid...'), backgroundColor: AppTheme.primaryBlue),
    );
    
    PlaidService.openLink(
      onSuccess: (publicToken, metadata) async {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Banco conectado. Sincronizando transacciones...'), backgroundColor: AppTheme.successBlue),
        );
        
        final supabase = Supabase.instance.client;
        final userId = supabase.auth.currentUser!.id;
        
        // Simular inyección de transacciones reales
        final mockData = PlaidService.getMockTransactions();
        for (var tx in mockData) {
          try {
            await supabase.from('transactions').insert({
              'id': tx.id,
              'user_id': userId,
              'account_id': tx.accountId,
              'amount': tx.amount,
              'category': tx.category,
              'date': tx.date.toIso8601String(),
              'type': tx.amount >= 0 ? 'income' : 'expense',
              'description': tx.name,
            });
          } catch (e) {
            // Ignorar duplicados
          }
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Sincronización completada!'), backgroundColor: AppTheme.successBlue),
          );
        }
      },
      onExit: (metadata) {
        // Cancelado por el usuario
      },
    );
  }
}
