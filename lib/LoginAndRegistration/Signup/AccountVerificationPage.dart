import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Import the http package.
import 'package:http/http.dart' as http;
import 'package:touristine/LoginAndRegistration/Signup/SignupPage.dart';

class AccountVerificationPage extends StatefulWidget {
  @override
  _AccountVerificationPageState createState() =>
      _AccountVerificationPageState();
}

class _AccountVerificationPageState extends State<AccountVerificationPage> {
  Future<void> resendEmail() async {
    final url = Uri.parse('http://your-nodejs-server-url/signin'); // Replace this with your Node.js server URL.
   
    try {
      final response = await http.post(
        url,
        body: {

        },
      );


      if (response.statusCode == 200) {

      } else {
        // Handle errors here.
        //showCustomSnackBar(context, 'Message');
      }
    } 
    catch (e) {
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
              'assets/Images/Interests/Launching.gif',
              width: 410,
              height: 410,
            ),
            const SizedBox(height: 40),

            // Get Started Button.
            ElevatedButton(
              onPressed: () {
                // Navigator.of(context).push(MaterialPageRoute(
                //     builder: (context) => ForgotPasswordPage()));
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
            const SizedBox(height: 20),

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
