import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  final String title;
  final String imageAsset;
  final String firstText;
  final String secondText;
  final double titleSize;

  const OnboardingScreen(
      {super.key,
      required this.title,
      required this.imageAsset,
      required this.firstText,
      required this.secondText,
      required this.titleSize});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // The page title.
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontFamily: 'Gabriola',
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF455a64),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // A spacer.
                  const SizedBox(height: 20),
                  Image.asset(
                    imageAsset,
                    fit: BoxFit.contain,
                  ),

                  // The first-line descriptive text.
                  Text(
                    firstText,
                    style: const TextStyle(
                      fontFamily: 'Gabriola',
                      fontSize: 37,
                      color: Color(0xFF455a64),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // A spacer.
                  const SizedBox(height: 0),

                  // The second-line descriptive text.
                  Text(
                    secondText,
                    style: const TextStyle(
                      fontFamily: 'Gabriola',
                      fontSize: 37,
                      color: Color(0xFF455a64),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // A spacer.
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
