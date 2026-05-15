import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'ui/screens/onboarding/onboarding_screen.dart';
import 'logic/blocs/auth/auth_bloc.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/auth/register_screen.dart';
import 'logic/providers/theme_provider.dart';
import 'ui/screens/main/main_shell.dart';
import 'ui/screens/settings/settings_screen.dart';
import 'core/utils/page_transitions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://fkachqhhpbijqerhubzi.supabase.co',
    anonKey: 'sb_publishable_s40vEmNa7goOqWzFX6MFMQ_1uhnuG1E',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        BlocProvider(create: (context) => AuthBloc()),
      ],
      child: const FinWiseApp(),
    ),
  );
}

class FinWiseApp extends StatelessWidget {
  const FinWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return AnimatedTheme(
      data: themeProvider.themeMode == ThemeMode.dark ? AppTheme.darkTheme : AppTheme.lightTheme,
      duration: const Duration(milliseconds: 500),
      child: MaterialApp(
        title: 'Prosper',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeProvider.themeMode,
        onGenerateRoute: (settings) {
          Widget page;
          switch (settings.name) {
            case '/':
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
              page = const OnboardingScreen();
          }
          return FadeSlidePageRoute(child: page);
        },
      ),
    );
  }
}
