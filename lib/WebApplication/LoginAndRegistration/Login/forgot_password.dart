import 'package:touristine/WebApplication/LoginAndRegistration/Login/password_reset.dart';
import 'package:touristine/WebApplication/Notifications/snack_bar.dart';
import 'package:touristine/WebApplication/components/text_field.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();

  // Validation function to check if any text field is unfilled.
  bool isEmailEmpty() {
    return emailController.text.isEmpty;
  }

  // Validation function to check if the entered email is in a valid format.
  bool isEmailValid(String email) {
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return emailRegex.hasMatch(email);
  }

  Future<void> sendResetEmail() async {
    final url = Uri.parse('https://touristine.onrender.com/send-reset-email');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'email': emailController.text,
        },
      );

      // If the provided email doesn't belong to any registered user, send a message or
      // flag in the response to indicate this for displaying a notification from my side.

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('message')) {
          if (data['message'] == 'Check your email for the new password') {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, 'Check your email for the password');
          }
          // ignore: use_build_context_synchronously
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  PasswordResetPage(email: emailController.text),
            ),
          );
        }

        // Jenan, return a success indicator, like a flag, to signal the process's success.
        // Additionally, include the email used for the password reset in the response.

        /* Israa, After that the User will be forwarded to the page that shows a 
        confirmation message following the dispatch of an email, namely the 
        PasswordResetPage, if the user wishes to request a resend. */
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> errorData = json.decode(response.body);
        if (errorData.containsKey('error')) {
          if (errorData['error'] == 'User does not exist') {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, errorData['error']);
          } else if (errorData['error'] == 'No email address was received') {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, errorData['error']);
          } else if (errorData['error'] ==
              'An error occurred sending the new password') {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, 'Error sending a new password');
          } else {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, 'Reset Password Process Failed');
          }
        }
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Failed to send the reset email');
      }
    } catch (error) {
      print('Error sending the reset email: $error');
    }
  }

  void resetPassword() {
    // Check if the email is empty.
    if (isEmailEmpty()) {
      showCustomSnackBar(context, 'Please fill in your email');
    } else if (!isEmailValid(emailController.text)) {
      showCustomSnackBar(context, 'Please enter a valid email address');
    } else {
      // The email is not empty and is in a valid format,
      // so you can proceed with the reset password logic.
      sendResetEmail();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      Image.asset(
                        'assets/Images/LoginPage/ForgotPassword/ForgotPassword.gif',
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.0),
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
                                'Forgot Your Password?',
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
                      const SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 100.0),
                        child: MyTextField(
                          controller: emailController,
                          hintText: 'Email',
                          obscureText: false,
                          fieldPrefixIcon: const FaIcon(
                            FontAwesomeIcons.envelope,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: resetPassword,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 109,
                            vertical: 20,
                          ),
                          backgroundColor: const Color(0xFF1E889E),
                          textStyle: const TextStyle(
                            fontSize: 25,
                            fontFamily: 'Zilla',
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        child: const Text('Reset Password'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
