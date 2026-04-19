import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'program_list_screen.dart';
import 'forgot_password_screen.dart';
import 'athlete_join_screen.dart';
import 'athlete_signup_screen.dart';
import 'program_list_screen.dart';

class AthleteLoginScreen extends StatefulWidget {
  const AthleteLoginScreen({super.key});

  @override
  State<AthleteLoginScreen> createState() => _AthleteLoginScreenState();
}

class _AthleteLoginScreenState extends State<AthleteLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;
  bool _canUseBiometrics = false; // In real app, check if biometrics available

  @override
  void initState() {
    super.initState();
    // Check if biometrics are available and user has logged in before
    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _checkBiometricAvailability() {
    // In real app, check if device supports biometrics and if user has enabled it
    // For demo, we'll show it if email field is not empty
    setState(() {
      _canUseBiometrics = _emailController.text.isNotEmpty;
    });
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _error = 'Please enter email and password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final response = await appProvider.apiService.login(
        _emailController.text,
        _passwordController.text,
      );

      final token = response['access'];
      appProvider.setAuthenticated(true, token: token, userName: 'Athlete'); // TODO: Get from API response

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ProgramListScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Invalid email or password';
        _isLoading = false;
      });
    }
  }

  Future<void> _loginWithBiometrics() async {
    // In real app, authenticate with biometrics
    // For demo, just show a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: const Text(
          'Biometric Authentication',
          style: TextStyle(color: Colors.white),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fingerprint,
              size: 60,
              color: Color(0xFFD4A017),
            ),
            SizedBox(height: 16),
            Text(
              'Touch the fingerprint sensor',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Color(0xFFD4A017)),
            ),
          ),
        ],
      ),
    );

    // Simulate biometric authentication
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.of(context).pop(); // Close dialog
      // In real app, proceed with login if successful
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Biometric authentication not implemented in demo'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              // Logo
              const Text(
                'THE LABORATORY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 100,
                height: 2,
                color: const Color(0xFFD4A017),
              ),
              const SizedBox(height: 60),
              // Email field
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => _checkBiometricAvailability(),
                decoration: const InputDecoration(
                  labelText: 'USERNAME OR EMAIL',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD4A017)),
                  ),
                  filled: true,
                  fillColor: Color(0xFF1a1a1a),
                ),
              ),
              const SizedBox(height: 20),
              // Password field
              TextField(
                controller: _passwordController,
                style: const TextStyle(color: Colors.white),
                obscureText: _obscurePassword,
                onSubmitted: (_) => _login(),
                decoration: InputDecoration(
                  labelText: 'PASSWORD',
                  labelStyle: const TextStyle(color: Colors.white70),
                  border: const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD4A017)),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1a1a1a),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Biometric prompt
              if (_canUseBiometrics)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1a1a1a),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.fingerprint,
                        size: 40,
                        color: Color(0xFFD4A017),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Use biometrics to log in faster',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _loginWithBiometrics,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD4A017),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('USE BIOMETRICS'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _canUseBiometrics = false;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white30),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('USE PASSWORD'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              if (_error != null)
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 20),
              // Login button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4A017),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              // Forgot password
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                  );
                },
                child: const Text(
                  'FORGOT PASSWORD',
                  style: TextStyle(
                    color: Color(0xFFD4A017),
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Sign up
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AthleteSignupScreen()),
                  );
                },
                child: const Text(
                  'DON\'T HAVE AN ACCOUNT? SIGN UP',
                  style: TextStyle(
                    color: Color(0xFFD4A017),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Join with invite code
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AthleteJoinScreen()),
                  );
                },
                child: const Text(
                  'JOIN WITH INVITE CODE',
                  style: TextStyle(
                    color: Color(0xFFD4A017),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Bypass login
              TextButton(
                onPressed: () {
                  final appProvider = Provider.of<AppProvider>(context, listen: false);
                  appProvider.setAuthenticated(true, userName: 'Guest (Dev)');
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const ProgramListScreen()),
                  );
                },
                child: const Text(
                  'BYPASS LOGIN (DEV)',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
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