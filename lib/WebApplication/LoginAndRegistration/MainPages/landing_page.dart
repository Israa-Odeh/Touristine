import 'package:touristine/WebApplication/LoginAndRegistration/Login/login_page.dart';
import 'package:touristine/WebApplication/LoginAndRegistration/Signup/signup_page.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

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
                padding: const EdgeInsets.only(top: 10.0),
                child: Row(
                  children: [
                    // The Logo.
                    Padding(
                      padding: const EdgeInsets.only(top: 0.0),
                      child: Image.asset(
                        "assets/Images/LandingPage/Logo.png",
                        width: 80,
                        height: 60,
                      ),
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
                    const SizedBox(width: 650),
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
                          horizontal: 50,
                          vertical: 13,
                        ),
                        backgroundColor: const Color.fromARGB(255, 184, 208, 213),
                        textStyle: const TextStyle(
                          fontSize: 25,
                          fontFamily: 'Zilla',
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      child: const Text('Login', style: TextStyle(color: Color(0xFF455a64)),),
                    ),
                    const SizedBox(width: 10),
                    // Signup Button.
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SignupPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 13,
                        ),
                        backgroundColor: const Color.fromARGB(252, 230, 230, 230),
                        textStyle: const TextStyle(
                          color: Color(0xFF455a64),
                          fontSize: 25,
                          fontFamily: 'Zilla',
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      child: const Text(
                        'Signup',
                        style: TextStyle(
                          color: Color(0xFF1e889e), // Text color here
                        ),
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
              const Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text(
                  "Experience every moment of Palestine like it's your first!",
                  style: TextStyle(
                    fontSize: 35,
                    fontFamily: 'Gabriola',
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF455a64),
                  ),
                ),
              ),
              // The image used for the landing page.
              Image.asset(
                'assets/Images/LandingPage/Landing.png',
                height: 400,
                width: 400,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
