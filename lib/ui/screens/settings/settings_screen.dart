import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../logic/providers/theme_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/biometric_service.dart';
import '../widgets/premium_button.dart';
import '../widgets/premium_primitives.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _biometricService = BiometricService();
  bool _biometricEnabled = false;
  bool _canUseBiometrics = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricSettings();
  }

  Future<void> _loadBiometricSettings() async {
    final enabled = await _biometricService.isEnabled();
    final available = await _biometricService.isBiometricAvailable();
    setState(() {
      _biometricEnabled = enabled;
      _canUseBiometrics = available;
    });
  }

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
                leading: const Icon(Icons.palette_rounded, color: AppTheme.primaryIndigo),
                onTap: () => _showThemeDialog(context, themeProvider),
              ),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Text('SEGURIDAD', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
            ),
            if (_canUseBiometrics)
              SolidCard(
                padding: EdgeInsets.zero,
                child: SwitchListTile(
                  title: const Text('AutenticaciÃ³n BiomÃ©trica'),
                  subtitle: const Text('Usa FaceID o Huella para entrar'),
                  secondary: const Icon(Icons.fingerprint_rounded, color: AppTheme.primaryIndigo),
                  value: _biometricEnabled,
                  activeThumbColor: AppTheme.primaryIndigo
                  onChanged: (value) async {
                    if (value) {
                      final authenticated = await _biometricService.authenticate();
                      if (authenticated) {
                        await _biometricService.setEnabled(true);
                        setState(() => _biometricEnabled = true);
                      }
                    } else {
                      await _biometricService.setEnabled(false);
                      setState(() => _biometricEnabled = false);
                    }
                  },
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
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Cerrar sesiÃ³n', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  
                ),
              ),
            ),
          
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
        content: RadioGroup<ThemeMode>(
          groupValue: provider.themeMode,
          onChanged: (mode) {
            provider.setThemeMode(mode!);
            Navigator.pop(context);
          },
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: Text('Sistema'),
                value: ThemeMode.system,
                activeColor: AppTheme.primaryIndigo
              ),
              RadioListTile<ThemeMode>(
                title: Text('Claro'),
                value: ThemeMode.light,
                activeColor: AppTheme.primaryIndigo
              ),
              RadioListTile<ThemeMode>(
                title: Text('Oscuro'),
                value: ThemeMode.dark,
                activeColor: AppTheme.primaryIndigo
              ),
            
          ),
        ),
      ),
    );
  }
}



