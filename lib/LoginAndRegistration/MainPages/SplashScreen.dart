import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final Widget profileType;

  const SplashScreen(
      {super.key, required this.profileType}); // Updated constructor

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isVisible = true;
  late Timer _timer; // Declare a Timer variable

  @override
  void initState() {
    super.initState();

    _timer = Timer(
      const Duration(seconds: 2),
      () {
        if (mounted) {
          // Check if the widget is still in the tree before calling setState
          setState(() {
            _isVisible = false; // Hide the splash screen
          });

          // Wait for the animation to complete and navigate to the landing page.
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              // Check if the widget is still in the tree before navigating
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return widget.profileType;
                  },
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;

                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 1500),
                ),
              );
            }
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // To prevent going back, simply return false.
          return false;
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF1E889E),
          body: AnimatedOpacity(
            opacity: _isVisible ? 1.0 : 0.0,
            duration: const Duration(seconds: 2),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 110),
                  Image.asset('assets/Images/MainPages/Logo.png',
                      fit: BoxFit.contain),
                  const SizedBox(height: 0),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 103.0),
                        child: Image.asset(
                          'assets/Images/MainPages/OliveOilTree.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 369, right: 330.0),
                        child: Image.asset(
                          'assets/Images/MainPages/Camel.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
