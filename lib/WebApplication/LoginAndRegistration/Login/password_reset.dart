import 'package:touristine/WebApplication/LoginAndRegistration/Login/login_page.dart';
import 'package:touristine/WebApplication/Notifications/snack_bar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class PasswordResetPage extends StatefulWidget {
  final String email;

  const PasswordResetPage({super.key, required this.email});

  @override
  _PasswordResetPageState createState() =>
      _PasswordResetPageState(email: email);
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final String email;

  _PasswordResetPageState({required this.email});

  Future<void> resendPassword() async {
    final url = Uri.parse('https://touristineapp.onrender.com/send-reset-email');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'email': email, // Use the email provided by the widget.
        },
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Password reset request was successful.
        if (responseData.containsKey('message')) {
          if (responseData['message'] ==
              'Check your email for the new password') {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, 'Check your email for the password');
          }
        }
      } else if (response.statusCode == 500) {
        if (responseData.containsKey('error')) {
          if (responseData['error'] == 'User does not exist') {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, responseData['error']);
          } else if (responseData['error'] == 'No email address was received') {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, responseData['error']);
          } else if (responseData['error'] ==
              'An error occurred sending the new password') {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, 'Error sending a new password');
          } else {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, 'Reset Password Process Failed');
          }
        }
      } else {
        // Password reset request failed.
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Failed to send the reset email');
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  Image.asset('assets/Images/LoginPage/ForgotPassword/Mail.gif',
                      fit: BoxFit.cover),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 95),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Color(0xFF1E889E),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'Password Reset',
                            style: TextStyle(
                              color: Color(0xFF455a64),
                              fontSize: 30,
                              fontFamily: 'Gabriola',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Color(0xFF1E889E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                  const Text(
                    'Please check your email for the newly\ngenerated password',
                    style: TextStyle(
                      color: Color(0xFF455a64),
                      fontSize: 28,
                      fontFamily: 'Gabriola',
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: resendPassword,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 133,
                        vertical: 20,
                      ),
                      backgroundColor: const Color(0xFF1E889E),
                      textStyle: const TextStyle(
                        fontSize: 22,
                        fontFamily: 'Zilla',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    child: const Text('Resend Password'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate back to the login page.
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 188,
                        vertical: 20,
                      ),
                      backgroundColor: const Color(0xFFe6e6e6),
                      textStyle: const TextStyle(
                        color: Color(0xFF455a64),
                        fontSize: 22,
                        fontFamily: 'Zilla',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        color: Color(0xFF1e889e), // Text color here
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
