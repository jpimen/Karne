// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/index.dart';
import 'screens/index.dart';
import 'routes/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hasCompletedOnboarding = prefs.getBool('hasCompletedOnboarding') ?? false;

  runApp(LaboratoryApp(hasCompletedOnboarding: hasCompletedOnboarding));
}

class LaboratoryApp extends StatelessWidget {
  final bool hasCompletedOnboarding;

  const LaboratoryApp({super.key, this.hasCompletedOnboarding = false});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppProvider())],
      child: MaterialApp(
        title: 'The Laboratory',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF111111),
          colorScheme: ColorScheme.dark(primary: const Color(0xFFD4A017)),
          cardTheme: const CardThemeData(
            color: Color(0xFF1a1a1a),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF111111),
            elevation: 0,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4A017),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
        home: Consumer<AppProvider>(
          builder: (context, appProvider, child) {
            if (appProvider.isAuthenticated) {
              return const HomeWelcomeScreen();
            } else if (!hasCompletedOnboarding) {
              return const SplashScreen();
            } else {
              return const AthleteLoginScreen();
            }
          },
        ),
        routes: AppRoutes.getRoutes(),
      ),
    );
  }
}
