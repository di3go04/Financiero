import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'ui/screens/splash/splash_screen.dart';
import 'ui/screens/landing/landing_page.dart';
import 'ui/screens/onboarding/onboarding_screen.dart';
import 'logic/blocs/auth/auth_bloc.dart' hide AuthState;
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/auth/register_screen.dart';
import 'logic/providers/theme_provider.dart';
import 'logic/providers/currency_provider.dart';
import 'logic/providers/user_settings_provider.dart';
import 'logic/providers/transaction_provider.dart';
import 'ui/screens/main/main_shell.dart';
import 'ui/screens/settings/settings_screen.dart';
import 'core/utils/page_transitions.dart';

import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('offline_transactions');

  await Supabase.initialize(
    url: 'https://fkachqhhpbijqerhubzi.supabase.co',
    anonKey: 'sb_publishable_s40vEmNa7goOqWzFX6MFMQ_1uhnuG1E',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
        ChangeNotifierProvider(create: (_) => UserSettingsProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        BlocProvider(create: (context) => AuthBloc()),
      ],
      child: const ProsperApp(),
    ),
  );
}

class ProsperApp extends StatefulWidget {
  const ProsperApp({super.key});

  @override
  State<ProsperApp> createState() => _ProsperAppState();
}

class _ProsperAppState extends State<ProsperApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    // Persistencia y Navegación automática basada en Supabase Auth Listener
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      
      if (!mounted) return;
      
      if (event == AuthChangeEvent.signedIn && session != null) {
        _navigatorKey.currentState?.pushReplacementNamed('/dashboard');
      } else if (event == AuthChangeEvent.signedOut) {
        _navigatorKey.currentState?.pushReplacementNamed('/login');
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return AnimatedTheme(
      data: themeProvider.themeMode == ThemeMode.dark ? AppTheme.darkTheme : AppTheme.lightTheme,
      duration: const Duration(milliseconds: 500),
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'Prosper',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeProvider.themeMode,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          Widget page;
          switch (settings.name) {
            case '/':
              page = const SplashScreen();
              break;
            case '/landing':
              page = const LandingPage();
              break;
            case '/onboarding':
              page = const OnboardingScreen();
              break;
            case '/login':
              page = const LoginScreen();
              break;
            case '/register':
              page = const RegisterScreen();
              break;
            case '/dashboard':
              page = const MainShell();
              break;
            case '/settings':
              page = const SettingsScreen();
              break;
            default:
              page = const LandingPage();
          }
          return FadeSlidePageRoute(child: page);
        },
      ),
    );
  }
}


