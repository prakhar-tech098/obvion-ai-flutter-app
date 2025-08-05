import 'dart:async';
import 'package:flutter/material.dart';
import '../authentication/loginpage.dart';
import '../core/theme/app_color.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();

    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (_, __, ___) => const LoginPage(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppGradients.darkGradient,
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              // child: Hero(
              //   tag: 'appLogo',
              //   child: Image.asset(
              //     'assets/mylog.png',
              //     width: 300,
              //     height: 300,
              //   ),
              // ),
              child: Center(
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.purpleAccent, Colors.cyanAccent],
                  ).createShader(bounds),
                  child: Hero(
                    tag: 'appLogo',
                    child: Image.asset(
                      'assets/mylog.png',
                      width: 300,
                      height: 300,
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
