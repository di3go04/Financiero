import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/gemini_service.dart';
import '../widgets/premium_primitives.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class IntelligenceTab extends StatefulWidget {
  const IntelligenceTab({super.key});

  @override
  State<IntelligenceTab> createState() => _IntelligenceTabState();
}

class _IntelligenceTabState extends State<IntelligenceTab> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  String _analysis = '';

  @override
  void initState() {
    super.initState();
    _loadAnalysis();
  }

  Future<void> _loadAnalysis() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final userId = _supabase.auth.currentUser!.id;
      final data = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false)
          .limit(30);

      final result = await GeminiService.analyzeFinances(data);
      if (mounted) {
        setState(() {
          _analysis = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _analysis = 'Hubo un error al generar tu análisis: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Padding(
          padding: const EdgeInsets.only(top: 80, left: 24, right: 24, bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prosper AI',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppTheme.textSnow : AppTheme.textSlate,
                        ),
                      ),
                      const Text(
                        'Tu asesor Prosper personal impulsado por IA.',
                        style: TextStyle(color: AppTheme.textDim, fontSize: 14),
                      ),
                    ],
                  ),
                  IconButton.filledTonal(
                    onPressed: _isLoading ? null : _loadAnalysis,
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Actualizar Análisis',
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      foregroundColor: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SolidCard(
                  child: _isLoading
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: AppTheme.primaryBlue),
                              SizedBox(height: 16),
                              Text('La IA está analizando tus movimientos...', style: TextStyle(color: AppTheme.textDim)),
                            ],
                          ),
                        )
                      : Markdown(
                          data: _analysis,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(color: isDark ? AppTheme.textSnow : AppTheme.textSlate, fontSize: 16),
                            h1: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
                            h2: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
                            listBullet: const TextStyle(color: AppTheme.primaryBlue),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
