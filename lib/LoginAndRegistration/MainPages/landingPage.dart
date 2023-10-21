import 'package:flutter/material.dart';
import 'package:touristine/LoginAndRegistration/Login/loginPage.dart';
import 'package:touristine/LoginAndRegistration/Signup/SignupPage.dart';

class LandingPage extends StatelessWidget {
  // Constructor.
  LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // Create an app bar with both logo and title.
        appBar: PreferredSize(
          preferredSize:
              const Size.fromHeight(70), // To increase the AppBar height.
          child: AppBar(
              title: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  children: [
                    // The Logo.
                    Image.asset(
                      "assets/Images/LandingPage/Logo.png",
                      width: 80,
                      height: 70,
                    ),
                    // The title.
                    const Text(
                      'Touristine',
                      style: TextStyle(
                        fontFamily: 'Edwardian',
                        fontSize: 55,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 2, 63, 74),
                      ),
                    ),
                  ],
                ),
              ),
              centerTitle: false,
              backgroundColor: const Color(0xFF1E889E)),
        ),

        // The body section, which contains descriptive text, an image, and buttons.
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // First part of the descriptive text.
              const Text(
                'Experience every moment of',
                style: TextStyle(
                  fontSize: 35,
                  fontFamily: 'Gabriola',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF455a64),
                ),
              ),

              // Second part of the descriptive text.
              const Text(
                "Palestine like it's your first!",
                style: TextStyle(
                  fontSize: 35,
                  fontFamily: 'Gabriola',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF455a64),
                ),
              ),

              // The image used for the landing page.
              Image.asset(
                'assets/Images/LandingPage/Landing.png',
                width: 420,
                height: 430,
              ),

              // Login Button.
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 100,
                    vertical: 13,
                  ),
                  backgroundColor: const Color(0xFF1E889E),
                  textStyle: const TextStyle(
                    fontSize: 30,
                    fontFamily: 'Zilla',
                    fontWeight: FontWeight.w300,
                  ),
                ),
                child: const Text('Login'),
              ),
              // A spacer between the two BTNs.
              const SizedBox(height: 15),

              // Signup Button.
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SignupPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 100,
                    vertical: 13,
                  ),
                  backgroundColor: const Color(0xFFe6e6e6),
                  textStyle: const TextStyle(
                    color: Color(0xFF455a64),
                    fontSize: 30,
                    fontFamily: 'Zilla',
                    fontWeight: FontWeight.w300,
                  ),
                ),
                child: const Text(
                  'Sigup',
                  style: TextStyle(
                    color: Color(0xFF1e889e), // Text color here
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
