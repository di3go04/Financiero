import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class LandingStats extends StatelessWidget {
  const LandingStats({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 800;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: 80,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue,
            const Color(0xFF0284C7),
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            'Números que hablan por sí solos',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: isWide ? 36 : 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Únete a miles de personas que ya transformaron su relación con el dinero.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 56),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: isWide ? 80 : 40,
              runSpacing: 40,
              children: const [
                _StatItem(value: '10K+', label: 'Usuarios activos'),
                _StatItem(value: '\$2.4M', label: 'Ahorros generados'),
                _StatItem(value: '99.9%', label: 'Uptime garantizado'),
                _StatItem(value: '4.9★', label: 'Calificación promedio'),
              ],
            ),
          ),
          const SizedBox(height: 56),
          // Testimonials row
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 24,
              runSpacing: 24,
              children: const [
                _TestimonialChip(
                  quote: '"Prosper cambió mi manera de ver mis gastos. ¡Ahora ahorro sin esfuerzo!"',
                  author: 'María G.',
                ),
                _TestimonialChip(
                  quote: '"La IA me avisó que gastaba demasiado en suscripciones. Me ahorré \$80 al mes."',
                  author: 'Carlos R.',
                ),
                _TestimonialChip(
                  quote: '"Finalmente pude cumplir mi meta de ahorrar para mi viaje. ¡100% recomendado!"',
                  author: 'Ana P.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _TestimonialChip extends StatelessWidget {
  final String quote;
  final String author;
  const _TestimonialChip({required this.quote, required this.author});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            quote,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '— $author',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
