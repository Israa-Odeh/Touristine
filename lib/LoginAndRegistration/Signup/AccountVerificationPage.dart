import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:touristine/LoginAndRegistration/Signup/SignupPage.dart';

// Import the http package.
import 'package:http/http.dart' as http;

class AccountVerificationPage extends StatefulWidget {
  final String email;

  const AccountVerificationPage({super.key, required this.email});
  @override
  _AccountVerificationPageState createState() =>
      _AccountVerificationPageState();
}

class _AccountVerificationPageState extends State<AccountVerificationPage> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    // Set up a timer that runs the checkVerificationStatus function every 5 seconds.
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      checkVerificationStatus();
    });
  }

  @override
  void dispose() {
    super.dispose();
    // Cancel the timer when the widget is disposed to prevent memory leaks.
    _timer.cancel();
  }

  Future<void> checkVerificationStatus() async {
    final url = Uri.parse(
        'https://touristine.onrender.com/check-verification-status'); // Replace this with your Node.js server URL.
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'email': widget.email, // Use the email provided by the widget.
        },
      );

      if (response.statusCode == 200) {
        //Email is verified and user is stored
        //You will receive a token. store it so you send it in all your next requests
      }
    } catch (e) {
      // Handle network or other exceptions here.
      print('Error: $e');
    }
  }

  Future<void> resendEmail() async {
    final url = Uri.parse('https://touristine.onrender.com/signup');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'email': widget.email,
        },
      );

      if (response.statusCode == 200) {
      } else {
        // Handle errors here.
        //showCustomSnackBar(context, 'Message');
      }
    } catch (e) {
      // Handle network or other exceptions here.
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Begin your adventure!',
              style: TextStyle(
                color: Color(0xFF455a64),
                fontSize: 45,
                fontFamily: 'Gabriola',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),
            Image.asset(
              'assets/Images/SignupPage/Launching.gif',
              width: 330,
              height: 330,
            ),

            const SizedBox(height: 10),
            const Text(
              'Please check your email to \n     verify your account',
              style: TextStyle(
                fontSize: 35,
                fontFamily: 'Gabriola',
                fontWeight: FontWeight.bold,
                color: Color(0xFF455a64),
              ),
            ),

            const SizedBox(height: 10),
            // Get Started Button.
            ElevatedButton(
              onPressed: () {
                // Navigator.of(context).pushReplacement(MaterialPageRoute(
                //     builder: (context) => SplashScreen();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 13,
                ),
                backgroundColor: const Color(0xFF1E889E),
                textStyle: const TextStyle(
                  fontSize: 30,
                  fontFamily: 'Zilla',
                  fontWeight: FontWeight.w300,
                ),
              ),
              child: const Text('Get Started'),
            ),
            // A spacer between the two BTNs.
            const SizedBox(height: 15),

            // Resend Email Button.
            ElevatedButton(
              onPressed: resendEmail,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 36,
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
                'Resend Email',
                style: TextStyle(
                  color: Color(0xFF1e889e), // Text color here
                ),
              ),
            ),
            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.only(right: 320.0),
              child: IconButton(
                icon: const FaIcon(
                  FontAwesomeIcons.arrowLeft,
                  color: Color(0xFF1E889E),
                  size: 30,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SignupPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
