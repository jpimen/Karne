import 'package:flutter/material.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/auth/athlete_join_screen.dart';
import '../screens/auth/athlete_account_creation_screen.dart';
import '../screens/auth/athlete_signup_screen.dart';
import '../screens/auth/athlete_login_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/dashboard/program_list_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';

class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String join = '/join';
  static const String createAccount = '/create-account';
  static const String signup = '/signup';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String programs = '/programs';
  static const String dashboard = '/dashboard';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      onboarding: (context) => const OnboardingScreen(),
      join: (context) => const AthleteJoinScreen(),
      createAccount: (context) => const AthleteAccountCreationScreen(inviteCode: ''),
      signup: (context) => const AthleteSignupScreen(),
      login: (context) => const AthleteLoginScreen(),
      forgotPassword: (context) => const ForgotPasswordScreen(),
      programs: (context) => const ProgramListScreen(),
      dashboard: (context) => const DashboardScreen(),
    };
  }
}
