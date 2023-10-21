import 'dart:async';

import 'package:flutter/material.dart';
import 'package:touristine/LoginAndRegistration/MainPages/landingPage.dart';

class TopOuterScreen extends StatefulWidget {
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
          _isVisible = false; // Hide the splash screen.
        });

        // Wait for the animation to complete and navigate to the landing page.
        Future.delayed(const Duration(milliseconds: 2000), () {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                return LandingPage();
              },
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 1500),
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
      body: AnimatedOpacity(
        opacity: _isVisible ? 1.0 : 0.0,
        duration: const Duration(seconds: 3),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Stack(
              children: [
                Container(
                  height: 820,
                  child: Image.asset(
                    'assets/Images/Interests/Al-Aqsa.jpg',
                    fit: BoxFit.fill,
                  ),
                ),
                Container(
                  color: const Color(0xFF1E889E).withOpacity(0.1), // Partially transparent layer color
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}