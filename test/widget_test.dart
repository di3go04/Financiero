// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:prosper/main.dart';
import 'package:prosper/logic/blocs/auth/auth_bloc.dart';
import 'package:prosper/logic/providers/theme_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Note: Since the app uses Supabase and Providers, we might need more setup for a real test.
    // For now, we just fix the compilation error.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          BlocProvider(create: (context) => AuthBloc()),
        ],
        child: const FinWiseApp(),
      ),
    );

    // Verify that the app starts.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
