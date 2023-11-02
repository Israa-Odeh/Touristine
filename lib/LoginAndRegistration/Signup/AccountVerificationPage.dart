import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:touristine/LoginAndRegistration/Signup/SignupPage.dart';

// Import the http package.
import 'package:http/http.dart' as http;
import 'package:touristine/Notifications/SnackBar.dart';
import 'package:touristine/onBoarding/Tourist/touristOnboardingPage.dart';

class AccountVerificationPage extends StatefulWidget {
  final String token;
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  const AccountVerificationPage(
      {super.key,
      required this.firstName,
      required this.lastName,
      required this.email,
      required this.password,
      required this.token});

  @override
  _AccountVerificationPageState createState() =>
      _AccountVerificationPageState();
}

class _AccountVerificationPageState extends State<AccountVerificationPage> {
  bool hideResendBTN = false;
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
        // Email is verified and user is stored.
        // You will receive a token. store it so you send it in all your next requests.
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('message')) {
          if (data['message'] == 'true') {
            setState(() {
              hideResendBTN = true;
            });
          }
        }
      } else if (response.statusCode == 204) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('message')) {
          if (data['message'] == 'false') {
            setState(() {
              hideResendBTN = false;
            });
          }
        }
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> errorData = json.decode(response.body);
        if (errorData.containsKey('error')) {
          if (errorData['error'] == 'No email was given') {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, errorData['error'], bottomMargin: 250);
          }
        }
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, "The verification process failed",
            bottomMargin: 250);
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
          'firstName': widget.firstName,
          'lastName': widget.lastName,
          'email': widget.email,
          'password': widget.password,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('message')) {
          if (data['message'] == 'A verification email is sent to you') {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, data['message'], bottomMargin: 250);
          }
        }
      } else if (response.statusCode == 409) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('message')) {
          if (data['message'] == 'User with this email already exists') {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, data['message'], bottomMargin: 250);
          } else if (data['message'] == 'All mandatory fields must be filled') {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, 'Please fill in all the fields',
                bottomMargin: 250);
          }
        }
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('error')) {
          if (data['error'] ==
              'An error occurred sending the verification line') {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, 'Verification line sending error',
                bottomMargin: 250);
          } else {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, 'The verification process failed',
                bottomMargin: 250);
          }
        }
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Failed to sign up, please try again',
            bottomMargin: 250);
      }
    } catch (e) {
      // Handle network or other exceptions here.
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // To prevent going back, simply return false
          return false;
        },
        child: Scaffold(
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

                hideResendBTN
                    ? const SizedBox(height: 40)
                    : const SizedBox(height: 10),
                Text(
                  hideResendBTN
                      ? 'Congratulations! You have been \n         successfully verified'
                      : 'Please check your email to \n     verify your account',
                  style: const TextStyle(
                    fontSize: 35,
                    fontFamily: 'Gabriola',
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF455a64),
                  ),
                ),

                hideResendBTN
                    ? const SizedBox(height: 35)
                    : const SizedBox(height: 10),
                // Get Started Button.
                ElevatedButton(
                  onPressed: () {
                    if (hideResendBTN == true) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TouristOnBoardingPage(
                            token: widget.token,
                            )),
                      );
                    }
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
                Visibility(
                  visible: !hideResendBTN,
                  child: ElevatedButton(
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
                ),
                // hideResendBTN
                //     ? const SizedBox(height: 60)
                //     : const SizedBox(height: 15),

                // Delete the return back BTN.
                // Visibility(
                //   visible: !hideResendBTN,
                //   child: Padding(
                //     padding: const EdgeInsets.only(right: 320.0),
                //     child: IconButton(
                //       icon: const FaIcon(
                //         FontAwesomeIcons.arrowLeft,
                //         color: Color(0xFF1E889E),
                //         size: 30,
                //       ),
                //       onPressed: () {
                //         Navigator.of(context).push(
                //           MaterialPageRoute(
                //             builder: (context) => SignupPage(),
                //           ),
                //         );
                //       },
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ));
  }
}
