import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../logic/providers/theme_provider.dart';
import '../../../logic/providers/currency_provider.dart';
import '../../../logic/providers/user_settings_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/shortcuts.dart';
import '../tabs/dashboard_tab.dart';
import '../tabs/transactions_tab.dart';
import '../tabs/budgets_tab.dart';
import '../tabs/goals_tab.dart';
import '../tabs/alerts_tab.dart';
import '../widgets/premium_primitives.dart';
import '../widgets/smart_fab.dart';
import '../widgets/transaction_form.dart';
import '../widgets/budget_form.dart';
import '../widgets/goal_form.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _sidebarExpanded = true;
  late AnimationController _sidebarController;
  late Animation<double> _sidebarAnim;

  late final List<Widget> _tabs;

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.grid_view_rounded, 'label': 'Inicio'},
    {'icon': Icons.swap_horiz_rounded, 'label': 'Transacciones'},
    {'icon': Icons.donut_large_rounded, 'label': 'Presupuestos'},
    {'icon': Icons.track_changes_rounded, 'label': 'Metas'},
    {'icon': Icons.auto_awesome_rounded, 'label': 'Intelligence'},
  ];

  @override
  void initState() {
    super.initState();
    _tabs = [
      const DashboardTab(),
      const TransactionsTab(),
      BudgetsTab(onAddBudget: () => _openBudgetForm()),
      GoalsTab(onAddGoal: () => _openGoalForm()),
      const AlertsTab(),
    ];
    _sidebarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: 1.0,
    );
    _sidebarAnim = CurvedAnimation(
      parent: _sidebarController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _sidebarController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() => _sidebarExpanded = !_sidebarExpanded);
    if (_sidebarExpanded) {
      _sidebarController.forward();
    } else {
      _sidebarController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final userSettings = Provider.of<UserSettingsProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width > 768;
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return GlobalShortcuts(
      onToggleSidebar: isDesktop ? _toggleSidebar : null,
      onSearch: () => setState(() => _selectedIndex = 1),
      child: Scaffold(
        extendBodyBehindAppBar: false,
        appBar: _buildAppBar(themeProvider, currencyProvider, userSettings),
        body: ResponsiveBackground(
          child: Row(
            children: [
              if (isDesktop) _buildDesktopSidebar(isDark),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _tabs[_selectedIndex
                ),
              ),
            
          ),
        ),
        floatingActionButton: _selectedIndex == 0 ? SmartFAB(
          onAddTransaction: () => _openTransactionForm(),
          onAddBudget: () => _openBudgetForm(),
          onAddGoal: () => _openGoalForm(),
        ) : null,
        bottomNavigationBar: !isDesktop ? _buildBottomNav(isDark) : null,
      ),
    );
  }

  void _openTransactionForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TransactionForm(),
    );
  }

  void _openBudgetForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BudgetForm(),
    );
  }

  void _openGoalForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const GoalForm(),
    );
  }

  PreferredSizeWidget _buildAppBar(
    ThemeProvider themeProvider,
    CurrencyProvider currencyProvider,
    UserSettingsProvider userSettings,
  ) {
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final bg = isDark ? AppTheme.surfaceDark : Colors.white;
    final borderColor = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    
    return AppBar(
      backgroundColor: bg,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 70,
      shape: Border(bottom: BorderSide(color: borderColor)),
      title: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Row(
          children: [
            if (MediaQuery.of(context).size.width > 768)
              IconButton(
                icon: AnimatedIcon(
                  icon: AnimatedIcons.menu_close,
                  progress: _sidebarAnim,
                  color: AppTheme.primaryIndigo
                ),
                onPressed: _toggleSidebar,
              ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryIndigo
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Prosper',
              style: TextStyle(
                fontWeight: FontWeight.w800, 
                fontSize: 22, 
                color: isDark ? AppTheme.textSnow : AppTheme.textSlate,
              ),
            ),
          
        ),
      ),
      actions: [
        _CurrencySwitcher(provider: currencyProvider),
        const SizedBox(width: 12),
        _ProfileMenu(themeProvider: themeProvider, userSettings: userSettings),
        const SizedBox(width: 16),
      
    );
  }

  Widget _buildDesktopSidebar(bool isDark) {
    return AnimatedBuilder(
      animation: _sidebarAnim,
      builder: (context, _) {
        final width = 80 + (180 * _sidebarAnim.value);
        return Container(
          width: width,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : Colors.white,
            border: Border(right: BorderSide(color: isDark ? AppTheme.borderDark : AppTheme.borderLight)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _navItems.length,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemBuilder: (context, index) {
                    final item = _navItems[index];
                    return _SidebarItem(
                      icon: item['icon'] as IconData,
                      label: item['label'] as String,
                      isSelected: _selectedIndex == index,
                      isExpanded: _sidebarAnim.value > 0.5,
                      onTap: () => setState(() => _selectedIndex = index),
                    );
                  },
                ),
              ),
            
          ),
        );
      },
    );
  }

  Widget _buildBottomNav(bool isDark) {
    final bg = isDark ? AppTheme.surfaceDark : Colors.white;
    final borderColor = isDark ? AppTheme.borderDark : AppTheme.borderLight;

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_navItems.length, (index) {
          final item = _navItems[index];
          final isSelected = _selectedIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = index),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item['icon'] as IconData,
                  color: isSelected ? AppTheme.primaryIndigo : Colors.grey,
                  size: 24,
                ),
                const SizedBox(height: 4),
                if (isSelected)
                  Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppTheme.primaryIndigo shape: BoxShape.circle)),
              
            ),
          );
        }),
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isSelected || _hovered;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected 
                ? AppTheme.primaryIndigo 
                : (_hovered ? (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)) : Colors.transparent),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon, 
                color: widget.isSelected ? Colors.white : (active ? AppTheme.primaryIndigo : Colors.grey), 
                size: 22
              ),
              if (widget.isExpanded) ...[
                const SizedBox(width: 12),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: active 
                        ? (isDark ? AppTheme.textSnow : AppTheme.textSlate) 
                        : Colors.grey,
                    fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              
            
          ),
        ),
      ),
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  final ThemeProvider themeProvider;
  final UserSettingsProvider userSettings;
  
  const _ProfileMenu({required this.themeProvider, required this.userSettings});

  @override
  Widget build(BuildContext context) {
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    
    return PopupMenuButton(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isDark ? AppTheme.borderDark : AppTheme.borderLight)),
      color: isDark ? AppTheme.surfaceDark : Colors.white,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.primaryIndigo width: 1.5),
        ),
        child: const CircleAvatar(
          radius: 16,
          backgroundColor: Colors.transparent,
          child: Icon(Icons.person_rounded, color: AppTheme.primaryIndigo size: 20),
        ),
      ),
      itemBuilder: (context) => <PopupMenuEntry>[
        PopupMenuItem(
          onTap: () => userSettings.togglePrivacyMode(),
          child: const Row(children: [
            SizedBox(width: 12),
            Text('Modo Incógnito'),
          ]),
        ),
        PopupMenuItem(
          onTap: () => themeProvider.toggleTheme(),
          child: Row(children: [
            Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, size: 18),
            const SizedBox(width: 12),
            const Text('Cambiar Tema'),
          ]),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          onTap: () => Supabase.instance.client.auth.signOut(),
          child: const Row(children: [
            Icon(Icons.logout_rounded, color: AppTheme.expenseRose, size: 18),
            SizedBox(width: 12),
            Text('Cerrar Sesión', style: TextStyle(color: AppTheme.expenseRose, fontWeight: FontWeight.bold)),
          ]),
        ),
      
    );
  }
}

class _CurrencySwitcher extends StatelessWidget {
  final CurrencyProvider provider;
  const _CurrencySwitcher({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopupMenuButton<Currency>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isDark ? AppTheme.borderDark : AppTheme.borderLight)),
      color: isDark ? AppTheme.surfaceDark : Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? Colors.white : Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              provider.label, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 18),
          
        ),
      ),
      onSelected: (c) => provider.setCurrency(c),
      itemBuilder: (_) => Currency.values.map((c) => PopupMenuItem(
        value: c, 
        child: Text(c.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold))
      )).toList(),
    );
  }
}

