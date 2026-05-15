import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../logic/providers/theme_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../tabs/dashboard_tab.dart';
import '../tabs/transactions_tab.dart';
import '../tabs/budgets_tab.dart';
import '../tabs/goals_tab.dart';
import '../tabs/alerts_tab.dart';
import '../widgets/premium_primitives.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  
  final List<Widget> _tabs = [
    const DashboardTab(),
    const TransactionsTab(),
    const BudgetsTab(),
    const GoalsTab(),
    const AlertsTab(),
  ];

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.grid_view_rounded, 'label': 'Inicio'},
    {'icon': Icons.swap_horiz_rounded, 'label': 'Transacciones'},
    {'icon': Icons.donut_large_rounded, 'label': 'Presupuestos'},
    {'icon': Icons.track_changes_rounded, 'label': 'Metas'},
    {'icon': Icons.auto_awesome_rounded, 'label': 'Inteligencia'},
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildGlassAppBar(themeProvider),
      body: ResponsiveBackground(
        child: Row(
          children: [
            if (isDesktop) _buildNavigationRail(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _tabs[_selectedIndex],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: !isDesktop ? _buildBottomNav() : null,
    );
  }

  PreferredSizeWidget _buildGlassAppBar(ThemeProvider themeProvider) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AppBar(
            backgroundColor: Theme.of(context).cardColor.withValues(alpha: 0.5),
            elevation: 0,
            leadingWidth: 120,
            leading: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppTheme.primaryCyan, AppTheme.secondaryBlue]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text('Prosper', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                ],
              ),
            ),
            actions: [
              PopupMenuButton(
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                icon: const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.primaryCyan,
                  child: Icon(Icons.person_rounded, color: Colors.white, size: 20),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: () => themeProvider.setThemeMode(
                      themeProvider.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark
                    ),
                    child: Row(
                      children: [
                        Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                        const SizedBox(width: 10),
                        const Text('Cambiar Tema'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () => Navigator.pushNamed(context, '/settings'),
                    child: const Row(
                      children: [
                        Icon(Icons.settings_rounded),
                        SizedBox(width: 10),
                        Text('Ajustes'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () => Supabase.instance.client.auth.signOut(),
                    child: const Row(
                      children: [
                        Icon(Icons.logout_rounded, color: Colors.red),
                        SizedBox(width: 10),
                        Text('Cerrar SesiÃ³n', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationRail() {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.3),
        border: Border(right: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Column(
        children: [
          const SizedBox(height: 100),
          Expanded(
            child: ListView.builder(
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = _selectedIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = index),
                  child: SizedBox(
                    height: 80,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryCyan.withValues(alpha: 0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            item['icon'],
                            color: isSelected ? AppTheme.primaryCyan : Colors.grey,
                            size: isSelected ? 28 : 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['label'],
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected ? AppTheme.primaryCyan : Colors.grey,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_navItems.length, (index) {
          final item = _navItems[index];
          final isSelected = _selectedIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryCyan.withValues(alpha: 0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(item['icon'], color: isSelected ? AppTheme.primaryCyan : Colors.grey),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
