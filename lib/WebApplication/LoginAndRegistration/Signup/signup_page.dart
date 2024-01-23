import 'package:touristine/WebApplication/LoginAndRegistration/Signup/account_verification_page.dart';
import 'package:touristine/WebApplication/Notifications/snack_bar.dart';
import 'package:touristine/WebApplication/UserData/user_provider.dart';
import 'package:touristine/WebApplication/components/text_field.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // Textfields Controllers.
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  // Functions Section.
  // Validation function to check if any text field is unfilled.
  bool isInputEmpty() {
    return firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        passwordConfirmController.text.isEmpty;
  }

  // Validation function to check if the entered email is in a valid format.
  bool isEmailValid(String email) {
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return emailRegex.hasMatch(email);
  }

  // Validation function to check if the entered password is within the desired range.
  bool isPasswordValid(String password) {
    return password.length >= 8 && password.length <= 30;
  }

  // Validation function to check if the entered password and password confirmation match.
  bool doPasswordsMatch(String password, String passwordConfirm) {
    return password == passwordConfirm;
  }

  // Validation function to check if the first and last names are within the desired range.
  bool isNameValid(String name) {
    // You can define your desired range here. For example, between 2 and 30 characters.
    final nameLengthRange = RegExp(r'^[A-Za-z]{2,20}$');
    return nameLengthRange.hasMatch(name);
  }

  Future<void> sendAndSaveData() async {
    final url = Uri.parse('https://touristineapp.onrender.com/signup');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'email': emailController.text,
          'password': passwordController.text,
          'deviceToken': '0',
        },
      );

      final Map<String, dynamic> responseData = json.decode(response.body);
      // Successful response from the Node.js server.
      if (response.statusCode == 200) {
        //-------------------Jenan--Successful Response
        //The Response: A verification email is sent to you
        //The user is sent a verification email
        //The user has a period of one hour to click the email
        //If they did not click it through that period, it is depricated
        //If they click within the valid period the user is registered
        //Any further clicks on the verification email will be handeled
        //from the back-end side to prevent duplications in registration
        //-----------------------------------------------------------------

        // Convert a JSON string into a Dart object.

        if (responseData.containsKey('message')) {
          if (responseData['message'] ==
              'A verification email is sent to you') {
            final String token = responseData['token']; // Contains the email.
            // ignore: use_build_context_synchronously
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => AccountVerificationPage(
                        email: emailController.text,
                        token: token,
                      )),
            );
            // ignore: use_build_context_synchronously
            context.read<UserProvider>().updateData(
                  newFirstName: firstNameController.text,
                  newLastName: lastNameController.text,
                  newPassword: passwordController.text,
                );

            // ignore: use_build_context_synchronously
            context.read<UserProvider>().updateImage(newImageURL: "");
          }
        }

        // Jenan, I need to check the response to see if the user
        // is registered and can proceed to the next sign-up step
        // (Interests Filling) or not:(Different Scenarios: The user
        // is already registered with this email...etc, in these cases
        // a notification must be displayed from my side), so provide me
        // with flag values for each case or any other suitable indicators.

        // After obtainig the response from Jenan.....

        // Israa, after user registration, direct them to the interest filling pages.
        // Israa, if registration fails due to the email's previous existence
        // or similar issues, display a notification accordingly.
      } else if (response.statusCode == 409) {
        if (responseData.containsKey('message')) {
          if (responseData['message'] ==
              'User with this email already exists') {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, responseData['message']);
          } else if (responseData['message'] ==
              'All mandatory fields must be filled') {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, 'Please fill in all the fields');
          }
        }
      } else if (response.statusCode == 500) {
        if (responseData.containsKey('error')) {
          if (responseData['error'] ==
              'An error occurred sending the verification line') {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, 'Verification line sending error');
          } else {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, 'The verification process failed');
          }
        }
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Failed to sign up, please try again');
      }
    } catch (e) {
      // Handle network or other exceptions here.
      print('Error: $e');
    }
  }

  // A Function for user registration.
  void signUserUp() {
    if (isInputEmpty()) {
      showCustomSnackBar(context, 'Please fill in all the fields');
    } else if (!isNameValid(firstNameController.text)) {
      showCustomSnackBar(context, 'Invalid first name: 2-20 characters only');
    } else if (!isNameValid(lastNameController.text)) {
      showCustomSnackBar(context, 'Invalid last name: 2-20 characters only');
    } else if (!isEmailValid(emailController.text)) {
      showCustomSnackBar(context, 'Please enter a valid email address');
    } else if (!isPasswordValid(passwordController.text)) {
      showCustomSnackBar(context, 'Password must contain 8-30 characters only');
    } else if (!isPasswordValid(passwordConfirmController.text)) {
      showCustomSnackBar(context, 'Password must contain 8-30 characters only');
    } else if (!doPasswordsMatch(
        passwordController.text, passwordConfirmController.text)) {
      showCustomSnackBar(context, 'Passwords do not match');
    } else {
      // Proceed with user registration logic here.
      sendAndSaveData(); // Send data to the server.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset:
          true, // Disable resizing when the keyboard appears.
      body: SingleChildScrollView(
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
                      'assets/Images/SignupPage/SignUp.gif',
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
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
                              'Register now and live the experience',
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
                        controller: firstNameController,
                        hintText: 'First Name',
                        obscureText: false,
                        fieldPrefixIcon: const FaIcon(
                          FontAwesomeIcons.user,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 100.0),
                      child: MyTextField(
                        controller: lastNameController,
                        hintText: 'Last Name',
                        obscureText: false,
                        fieldPrefixIcon: const FaIcon(
                          FontAwesomeIcons.user,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 100.0),
                      child: MyTextField(
                        controller: passwordController,
                        hintText: 'Password',
                        obscureText: true,
                        fieldPrefixIcon: const FaIcon(
                          FontAwesomeIcons.lock,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 100.0),
                      child: MyTextField(
                        controller: passwordConfirmController,
                        hintText: 'Confirm Password',
                        obscureText: true,
                        fieldPrefixIcon: const FaIcon(
                          FontAwesomeIcons.lock,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),
                    ElevatedButton(
                      onPressed: signUserUp,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 158,
                          vertical: 20,
                        ),
                        backgroundColor: const Color(0xFF1E889E),
                        textStyle: const TextStyle(
                          fontSize: 22,
                          fontFamily: 'Zilla',
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
