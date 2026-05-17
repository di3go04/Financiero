import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class LandingFeatures extends StatelessWidget {
  const LandingFeatures({super.key});

  static const List<_Feature> _features = [
    _Feature(
      icon: Icons.auto_awesome_rounded,
      title: 'IA Financiera',
      description: 'Analiza tus gastos automáticamente y recibe consejos personalizados impulsados por inteligencia artificial.',
    ),
    _Feature(
      icon: Icons.account_balance_rounded,
      title: 'Conexión Bancaria',
      description: 'Vincula tus cuentas bancarias de forma segura para tener una visión 360° de tus finanzas en un solo lugar.',
    ),
    _Feature(
      icon: Icons.document_scanner_rounded,
      title: 'Escáner de Recibos',
      description: 'Toma una foto de tu recibo y la IA extrae automáticamente el comercio, monto y categoría.',
    ),
    _Feature(
      icon: Icons.donut_large_rounded,
      title: 'Presupuestos Inteligentes',
      description: 'Crea presupuestos por categoría y recibe alertas cuando estés cerca de exceder tus límites.',
    ),
    _Feature(
      icon: Icons.track_changes_rounded,
      title: 'Metas de Ahorro',
      description: 'Define metas financieras y observa tu progreso en tiempo real. Comparte metas con tu familia.',
    ),
    _Feature(
      icon: Icons.currency_exchange_rounded,
      title: 'Multi-Divisa',
      description: 'Administra billeteras en diferentes monedas con tasas de cambio en vivo actualizadas automáticamente.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 800;
    final crossAxisCount = screenWidth > 1100 ? 3 : (screenWidth > 600 ? 2 : 1);

    return Container(
      width: double.infinity,
      color: isDark ? AppTheme.bgDark : AppTheme.bgLight,
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
              'CARACTERÍSTICAS',
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
            'Todo lo que necesitas en un solo lugar',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: isWide ? 40 : 28,
              fontWeight: FontWeight.w900,
              color: isDark ? AppTheme.textSnow : AppTheme.textSlate,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              'Herramientas profesionales diseñadas para que cualquier persona pueda dominar sus finanzas.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppTheme.textDim,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 56),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: isWide ? 1.6 : 1.8,
              ),
              itemCount: _features.length,
              itemBuilder: (context, index) {
                return _FeatureCard(feature: _features[index], isDark: isDark);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String description;
  const _Feature({required this.icon, required this.title, required this.description});
}

class _FeatureCard extends StatefulWidget {
  final _Feature feature;
  final bool isDark;
  const _FeatureCard({required this.feature, required this.isDark});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(28),
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -6.0 : 0.0),
        decoration: BoxDecoration(
          color: widget.isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered
                ? AppTheme.primaryBlue.withValues(alpha: 0.4)
                : (widget.isDark ? AppTheme.borderDark : AppTheme.borderLight),
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: _isHovered ? 24 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(widget.feature.icon, color: AppTheme.primaryBlue, size: 28),
            ),
            const SizedBox(height: 20),
            Text(
              widget.feature.title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: widget.isDark ? AppTheme.textSnow : AppTheme.textSlate,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.feature.description,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textDim,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
