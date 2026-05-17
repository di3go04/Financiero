import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../logic/providers/currency_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../widgets/premium_primitives.dart';

class LandingCustomization extends StatelessWidget {
  const LandingCustomization({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Text(
                'Personalización Total',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Prosper se adapta a ti',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Desde divisas internacionales hasta el control de tu privacidad.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textDim, fontSize: 16),
              ),
              const SizedBox(height: 64),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Side: Currency Selector
                  Expanded(
                    flex: 1,
                    child: SolidCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.language_rounded, color: AppTheme.primaryBlue),
                              SizedBox(width: 12),
                              Text(
                                'Selector de Divisas',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Soporte para múltiples monedas mundiales y criptoactivos.',
                            style: TextStyle(color: AppTheme.textDim, fontSize: 14),
                          ),
                          const SizedBox(height: 32),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: Currency.values.map((c) {
                              final isSelected = currencyProvider.currency == c;
                              return GestureDetector(
                                onTap: () => currencyProvider.setCurrency(c),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppTheme.primaryBlue : (isDark ? AppTheme.borderDark : AppTheme.primaryBlue.withValues(alpha: 0.05)),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? AppTheme.primaryBlue : AppTheme.borderLight,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    c.name.toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : (isDark ? AppTheme.textSnow : AppTheme.textSlate),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                  // Right Side: More Settings Preview
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        _buildSettingItem(
                          icon: Icons.visibility_off_rounded,
                          title: 'Modo Incógnito',
                          subtitle: 'Oculta tus balances con un solo toque.',
                          color: AppTheme.primaryBlue,
                        ),
                        const SizedBox(height: 16),
                        _buildSettingItem(
                          icon: Icons.notifications_active_rounded,
                          title: 'Alertas Inteligentes',
                          subtitle: 'Notificaciones sobre gastos inusuales.',
                          color: AppTheme.accentAmber,
                        ),
                        const SizedBox(height: 16),
                        _buildSettingItem(
                          icon: Icons.fingerprint_rounded,
                          title: 'Biometría',
                          subtitle: 'Acceso seguro con FaceID o huella.',
                          color: AppTheme.successBlue,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return SolidCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppTheme.textDim, fontSize: 13),
                ),
              ],
            ),
          ),
          Switch(value: true, onChanged: (_) {}, activeColor: AppTheme.primaryBlue),
        ],
      ),
    );
  }
}
