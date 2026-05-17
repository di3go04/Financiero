import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class LandingHowItWorks extends StatelessWidget {
  const LandingHowItWorks({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 800;

    return Container(
      width: double.infinity,
      color: isDark ? AppTheme.surfaceDark : Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: 80,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              'CÓMO FUNCIONA',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryBlue,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Empieza en 3 simples pasos',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: isWide ? 40 : 28,
              fontWeight: FontWeight.w900,
              color: isDark ? AppTheme.textSnow : AppTheme.textSlate,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(height: 56),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: isWide
                ? Row(
                    children: [
                      Expanded(child: _StepCard(step: 1, title: 'Crea tu cuenta', description: 'Regístrate gratis en segundos con tu correo electrónico. No necesitas tarjeta de crédito.', icon: Icons.person_add_rounded, isDark: isDark)),
                      _StepConnector(isDark: isDark),
                      Expanded(child: _StepCard(step: 2, title: 'Registra tus movimientos', description: 'Añade tus gastos e ingresos manualmente o escanea tus recibos con la cámara.', icon: Icons.receipt_long_rounded, isDark: isDark)),
                      _StepConnector(isDark: isDark),
                      Expanded(child: _StepCard(step: 3, title: 'Recibe consejos de IA', description: 'Nuestra IA analiza tus hábitos Prospers y te da recomendaciones para ahorrar más.', icon: Icons.lightbulb_rounded, isDark: isDark)),
                    ],
                  )
                : Column(
                    children: [
                      _StepCard(step: 1, title: 'Crea tu cuenta', description: 'Regístrate gratis en segundos con tu correo electrónico. No necesitas tarjeta de crédito.', icon: Icons.person_add_rounded, isDark: isDark),
                      const SizedBox(height: 24),
                      _StepCard(step: 2, title: 'Registra tus movimientos', description: 'Añade tus gastos e ingresos manualmente o escanea tus recibos con la cámara.', icon: Icons.receipt_long_rounded, isDark: isDark),
                      const SizedBox(height: 24),
                      _StepCard(step: 3, title: 'Recibe consejos de IA', description: 'Nuestra IA analiza tus hábitos Prospers y te da recomendaciones para ahorrar más.', icon: Icons.lightbulb_rounded, isDark: isDark),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _StepConnector extends StatelessWidget {
  final bool isDark;
  const _StepConnector({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Icon(
        Icons.arrow_forward_rounded,
        color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        size: 28,
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final int step;
  final String title;
  final String description;
  final IconData icon;
  final bool isDark;

  const _StepCard({
    required this.step,
    required this.title,
    required this.description,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.bgDark : AppTheme.bgLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppTheme.primaryBlue, size: 28),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$step',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? AppTheme.textSnow : AppTheme.textSlate,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textDim,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
