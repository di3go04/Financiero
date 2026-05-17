import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../logic/providers/currency_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../widgets/premium_primitives.dart';

class LandingPricing extends StatelessWidget {
  const LandingPricing({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    
    // Calculate converted price for display
    // Base is 9.99 USD
    double premiumPrice = 9.99;
    if (currencyProvider.currency == Currency.cop) premiumPrice = 40000;
    if (currencyProvider.currency == Currency.eur) premiumPrice = 9.49;
    if (currencyProvider.currency == Currency.mxn) premiumPrice = 179;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.02),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              const Text(
                'PLANES SENCILLOS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Elige el plan que mejor se adapte a ti',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 64),
              Wrap(
                spacing: 32,
                runSpacing: 32,
                alignment: WrapAlignment.center,
                children: [
                  PricingCard(
                    title: 'Plan Gratuito',
                    price: 'Gratis',
                    description: 'Ideal para quienes empiezan a organizar sus finanzas.',
                    features: [
                      'Conexión a 1 banco',
                      '2 presupuestos activos',
                      'Proyección financiera básica',
                      'Registro manual ilimitado',
                    ],
                    isPopular: false,
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                  ),
                  PricingCard(
                    title: 'Plan Premium',
                    price: currencyProvider.format(premiumPrice),
                    description: 'Para quienes buscan libertad financiera absoluta.',
                    features: [
                      'Bancos ilimitados',
                      'Presupuestos ilimitados',
                      'Simulación avanzada de metas',
                      'Informes exportables (PDF/Excel)',
                      'Alertas inteligentes completas',
                      'Soporte prioritario',
                    ],
                    isPopular: true,
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PricingCard extends StatelessWidget {
  final String title;
  final String price;
  final String description;
  final List<String> features;
  final bool isPopular;
  final VoidCallback onPressed;

  const PricingCard({
    super.key,
    required this.title,
    required this.price,
    required this.description,
    required this.features,
    required this.isPopular,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 380,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isPopular ? AppTheme.primaryBlue : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
          width: isPopular ? 2 : 1.5,
        ),
        boxShadow: isPopular ? [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: isDark ? 0.2 : 0.1),
            blurRadius: 40,
            offset: const Offset(0, 15),
          ),
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'RECOMENDADO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (price != 'Gratis')
                const Text(
                  '/mes',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppTheme.textDim,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            description,
            style: const TextStyle(
              color: AppTheme.textDim,
              fontSize: 15,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 32),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.successBlue,
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    f,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isPopular ? AppTheme.primaryBlue : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black),
              foregroundColor: isPopular ? Colors.white : (isDark ? Colors.white : Colors.white),
              minimumSize: const Size(double.infinity, 64),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: Text(
              isPopular ? 'Empieza con Premium' : 'Comienza Gratis',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
