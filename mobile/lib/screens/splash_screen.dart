import 'package:flutter/material.dart';
import 'dart:async';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _lineController;
  late AnimationController _subtitleController;
  late Animation<double> _logoAnimation;
  late Animation<double> _lineAnimation;
  late Animation<double> _subtitleAnimation;

  @override
  void initState() {
    super.initState();

    // Logo animation - letters drop in with stagger
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    // Line animation - extends left and right
    _lineController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _lineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _lineController, curve: Curves.easeOut),
    );

    // Subtitle animation - fades in
    _subtitleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _subtitleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _subtitleController, curve: Curves.easeIn),
    );

    // Start animations
    _logoController.forward().then((_) {
      _lineController.forward().then((_) {
        _subtitleController.forward();
      });
    });

    // Navigate after 2 seconds
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const OnboardingScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;

              var tween = Tween(begin: begin, end: end)
                  .chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _lineController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animation
            AnimatedBuilder(
              animation: _logoAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _logoAnimation.value,
                  child: const Text(
                    'THE LABORATORY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            // Gold line animation
            AnimatedBuilder(
              animation: _lineAnimation,
              builder: (context, child) {
                return Container(
                  width: MediaQuery.of(context).size.width * _lineAnimation.value,
                  height: 2,
                  color: const Color(0xFFD4A017),
                );
              },
            ),
            const SizedBox(height: 20),
            // Subtitle animation
            AnimatedBuilder(
              animation: _subtitleAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _subtitleAnimation.value,
                  child: const Text(
                    'ELITE STATUS',
                    style: TextStyle(
                      color: Color(0xFFD4A017),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}