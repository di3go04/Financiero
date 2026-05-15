import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/premium_primitives.dart';
import '../widgets/premium_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Bienvenido a Prosper',
      description: 'Tu plataforma integral para el control financiero total con inteligencia artificial.',
      icon: Icons.auto_awesome_rounded,
    ),
    OnboardingData(
      title: 'ConexiÃ³n Bancaria Segura',
      description: 'Vincula tus cuentas bancarias de forma segura para tener una visiÃ³n clara de tus finanzas.',
      icon: Icons.account_balance_rounded,
    ),
    OnboardingData(
      title: 'Presupuestos Inteligentes',
      description: 'Analizamos tus gastos y te sugerimos presupuestos personalizados para ayudarte a ahorrar.',
      icon: Icons.insights_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveBackground(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) => OnboardingContent(data: _pages[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? AppTheme.primaryCyan : Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  PremiumButton(
                    gradient: const [AppTheme.primaryCyan, AppTheme.secondaryBlue],
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
                      } else {
                        Navigator.pushNamed(context, '/login');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      alignment: Alignment.center,
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Comenzar ahora' : 'Siguiente',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  OnboardingData({required this.title, required this.description, required this.icon});
}

class OnboardingContent extends StatelessWidget {
  final OnboardingData data;
  const OnboardingContent({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryCyan.withValues(alpha: 0.1), AppTheme.secondaryBlue.withValues(alpha: 0.1)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 100, color: AppTheme.primaryCyan),
          ),
          const SizedBox(height: 48),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1),
          ),
          const SizedBox(height: 24),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.6),
          ),
        ],
      ),
    );
  }
}
