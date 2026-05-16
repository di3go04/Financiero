import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/premium_primitives.dart';
import '../widgets/premium_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _supabase = Supabase.instance.client;
  bool _isLoading    = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      await _supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {
          'full_name': _nameController.text.trim(),
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registro exitoso. Revisa tu email para confirmar.',
              style: GoogleFonts.inter(),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.primaryIndigo
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString(), style: GoogleFonts.inter()),
            backgroundColor: AppTheme.expenseCoral,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      extendBodyBehindAppBar: true,
      body: ResponsiveBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: SolidCard(
                borderRadius: 24,
                padding: const EdgeInsets.all(36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Header ────────────────────────────────────────
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.primaryIndigo
                              
                            
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppTheme.primaryIndigo.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          
                        ),
                        child: const Icon(Icons.person_add_rounded,
                            size: 30, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'Únete a Prosper',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: isDark ? Colors.white : AppTheme.textSlate,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        'Comienza tu camino a la libertad financiera',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : AppTheme.textSlate,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // ── Full Name ─────────────────────────────────────
                    TextField(
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: isDark ? Colors.white : AppTheme.textSlate,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Nombre completo',
                        labelStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : AppTheme.textSlate,
                        ),
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Email ─────────────────────────────────────────
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: isDark ? Colors.white : AppTheme.textSlate,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        labelStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : AppTheme.textSlate,
                        ),
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Password ──────────────────────────────────────
                    TextField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: isDark ? Colors.white : AppTheme.textSlate,
                      ),
                      onSubmitted: (_) => _signUp(),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        labelStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : AppTheme.textSlate,
                        ),
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _showPassword = !_showPassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Submit ────────────────────────────────────────
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryIndigo),
                            ),
                          )
                        : PremiumButton(
                            onPressed: _signUp,
                            child: Container(
                              height: 52,
                              alignment: Alignment.center,
                              child: Text(
                                'Crear cuenta',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(height: 20),

                    // ── Back to login ─────────────────────────────────
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : AppTheme.textSlate,
                            ),
                            children: [
                              const TextSpan(text: '¿Ya tienes cuenta? '),
                              TextSpan(
                                text: 'Inicia sesión',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryIndigo
                                ),
                              ),
                            
                          ),
                        ),
                      ),
                    ),
                  
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


