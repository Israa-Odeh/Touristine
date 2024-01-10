import 'package:touristine/WebApplication/LoginAndRegistration/MainPages/landing_page.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class TopOuterScreen extends StatefulWidget {
  const TopOuterScreen({super.key});

  @override
  _TopOuterScreenState createState() => _TopOuterScreenState();
}

class _TopOuterScreenState extends State<TopOuterScreen> {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();

    Timer(
      const Duration(seconds: 3),
      () {
        setState(() {
          _isVisible = false; // Hide the splash screen
        });

        // Wait for the animation to complete and navigate to the landing page.
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                return FadeTransition(
                  opacity: animation,
                  child: const LandingPage(),
                );
              },
              transitionDuration: const Duration(seconds: 1),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // LandingPage (visible before fading effect)
          if (!_isVisible) const LandingPage(),

          // SplashScreen with fading effect
          AnimatedOpacity(
            opacity: _isVisible ? 1.0 : 0.0,
            duration: const Duration(seconds: 3),
            child: Center(
              child: SizedBox(
                child: Image.asset(
                  'assets/Images/MainPages/Al-Aqsa.jpg',
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
