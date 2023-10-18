import 'package:flutter/material.dart';
import 'package:touristine/LoginAndRegistration/Login/loginPage.dart';

// Import the http package.
import 'package:http/http.dart' as http;
import 'package:touristine/Notifications/SnackBar.dart';

class PasswordResetPage extends StatefulWidget {
  final String email;

  PasswordResetPage({Key? key, required this.email}) : super(key: key);

  @override
  _PasswordResetPageState createState() => _PasswordResetPageState(email: email);
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final String email;

  _PasswordResetPageState({required this.email});

  Future<void> resendPassword() async {
    final url = Uri.parse('http://your-backend-url/reset_password'); // Replace with your actual backend endpoint.

    try {
      final response = await http.post(
        url,
        body: {
          'email': email, // Use the email provided by the widget.
        },
      );

      if (response.statusCode == 200) {
        // Password reset request was successful.
        // You can display a success message or handle it as needed.

        //showCustomSnackBar(context, 'Check your email for the password', bottomMargin: 355.0);
        
      } else {
        // Password reset request failed.
        // You can display an error message or handle it as needed.
        showCustomSnackBar(context, 'Failed to send the reset email', bottomMargin: 355.0);
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
            Image.asset(
              'assets/Images/LoginPage/ForgotPassword/Mail.gif',
              width: 410,
              height: 410,
            ),
            const SizedBox(height: 10),
            const Text(
              'Please check your email for the',
              style: TextStyle(
                color: Color(0xFF455a64),
                fontSize: 35,
                fontFamily: 'Gabriola',
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text(
              'newly generated password',
              style: TextStyle(
                color: Color(0xFF455a64),
                fontSize: 35,
                fontFamily: 'Gabriola',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: resendPassword,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 13,
                ),
                backgroundColor: const Color(0xFF1E889E),
                textStyle: const TextStyle(
                  fontSize: 28,
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
                  horizontal: 100,
                  vertical: 13,
                ),
                backgroundColor: const Color(0xFFe6e6e6),
                textStyle: const TextStyle(
                  color: Color(0xFF455a64),
                  fontSize: 28,
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
    );
  }
}
