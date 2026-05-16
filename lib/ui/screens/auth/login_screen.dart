import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/premium_primitives.dart';
import '../widgets/premium_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _supabase = Supabase.instance.client;
  bool _isLoading      = false;
  bool _showPassword   = false;
  late AnimationController _logoController;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _logoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      await _supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.expenseCoral,
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
                    // ── Logo ──────────────────────────────────────────
                    Center(
                      child: ScaleTransition(
                        scale: Tween(begin: 1.0, end: 1.06).animate(
                          CurvedAnimation(
                              parent: _logoController,
                              curve: Curves.easeInOut),
                        ),
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppTheme.primaryIndigo
                                
                              
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryIndigo
                                    .withValues(alpha: 0.35),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Title ─────────────────────────────────────────
                    Center(
                      child: Text(
                        'Prosper',
                        style: GoogleFonts.inter(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: isDark ? Colors.white : AppTheme.textSlate,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        'Inicia sesión para continuar',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : AppTheme.textSlate,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // ── Email field ───────────────────────────────────
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
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

                    // ── Password field ────────────────────────────────
                    TextField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: isDark ? Colors.white : AppTheme.textSlate,
                      ),
                      onSubmitted: (_) => _signIn(),
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

                    // ── Forgot password ───────────────────────────────
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 8),
                        ),
                        child: Text(
                          '¿Olvidaste tu contraseña?',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primaryIndigo
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Login button ──────────────────────────────────
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryIndigo),
                            ),
                          )
                        : PremiumButton(
                            onPressed: _signIn,
                            child: Container(
                              height: 52,
                              alignment: Alignment.center,
                              child: Text(
                                'Entrar',
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

                    // ── Divider ───────────────────────────────────────
                    Row(children: [
                      const Expanded(
                          child: Divider(endIndent: 12, height: 1)),
                      Text(
                        'o',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: isDark
                              ? const Color(0xFF64748B)
                              : AppTheme.textSlate,
                        ),
                      ),
                      const Expanded(
                          child: Divider(indent: 12, height: 1)),
                    ]),
                    const SizedBox(height: 16),

                    // ── Register link ─────────────────────────────────
                    Center(
                      child: TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/register'),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : AppTheme.textSlate,
                            ),
                            children: [
                              const TextSpan(text: '¿No tienes cuenta? '),
                              TextSpan(
                                text: 'Regístrate',
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


