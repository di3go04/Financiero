import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class LandingFooter extends StatelessWidget {
  const LandingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 800;

    return Container(
      width: double.infinity,
      color: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      child: Column(
        children: [
          // Final CTA
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 80 : 24,
              vertical: 80,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.rocket_launch_rounded, color: AppTheme.primaryBlue, size: 36),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      '¿Listo para prosperar?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: isWide ? 36 : 28,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppTheme.textSnow : AppTheme.textSlate,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Crea tu cuenta gratuita hoy y empieza a tomar decisiones financieras más inteligentes.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppTheme.textDim,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Crear Mi Cuenta Gratis', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sin tarjeta de crédito • Sin costo • Cancelar cuando quieras',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppTheme.textDim),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Footer bar
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 80 : 24,
              vertical: 32,
            ),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
              ),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 24,
              runSpacing: 16,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.account_balance_wallet_rounded, color: AppTheme.primaryBlue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Prosper',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 16, color: isDark ? AppTheme.textSnow : AppTheme.textSlate),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '© 2026',
                      style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textDim),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('Privacidad', style: TextStyle(color: AppTheme.textDim, fontSize: 13)),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Términos', style: TextStyle(color: AppTheme.textDim, fontSize: 13)),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Contacto', style: TextStyle(color: AppTheme.textDim, fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
