// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/app_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/athlete_join_screen.dart';
import 'screens/athlete_account_creation_screen.dart';
import 'screens/athlete_signup_screen.dart';
import 'screens/athlete_login_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_welcome_screen.dart';
import 'screens/program_list_screen.dart';
import 'screens/dashboard_screen.dart';

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
        routes: {
          '/onboarding': (context) => const OnboardingScreen(),
          '/join': (context) => const AthleteJoinScreen(),
          '/create-account': (context) => const AthleteAccountCreationScreen(inviteCode: ''), // TODO: Pass invite code
          '/signup': (context) => const AthleteSignupScreen(),
          '/login': (context) => const AthleteLoginScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/programs': (context) => const ProgramListScreen(),
          '/dashboard': (context) => const DashboardScreen(),
        },
      ),
    );
  }
}
