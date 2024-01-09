import 'package:touristine/WebApplication/Notifications/snack_bar.dart';
import 'package:touristine/WebApplication/components/custom_field.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class AdminAddingPage extends StatefulWidget {
  final String token;

  const AdminAddingPage({super.key, required this.token});

  @override
  _AdminAddingPageState createState() => _AdminAddingPageState();
}

class _AdminAddingPageState extends State<AdminAddingPage> {
  // Textfields Controllers.
  final emailController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isInputEmpty() {
    return emailController.text.isEmpty ||
        firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        passwordController.text.isEmpty;
  }

  bool isPasswordValid(String password) {
    return password.length >= 8 && password.length <= 30;
  }

  bool isNameValid(String name) {
    final nameLengthRange = RegExp(r'^[A-Za-z]{2,20}$');
    return nameLengthRange.hasMatch(name);
  }

  bool isEmailValid(String email) {
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return emailRegex.hasMatch(email);
  }

  Future<void> validateForm() async {
    if (isInputEmpty()) {
      showCustomSnackBar(context, 'Please fill in all the fields',
          bottomMargin: 620.0);
    } else if (!isNameValid(firstNameController.text)) {
      showCustomSnackBar(context, 'Invalid first name: 2-20 characters only',
          bottomMargin: 620.0);
    } else if (!isNameValid(lastNameController.text)) {
      showCustomSnackBar(context, 'Invalid last name: 2-20 characters only',
          bottomMargin: 620.0);
    } else if (!isEmailValid(emailController.text)) {
      showCustomSnackBar(context, 'Please enter a valid email address',
          bottomMargin: 620.0);
    } else if (!isPasswordValid(passwordController.text)) {
      showCustomSnackBar(context, 'Password must contain 8-30 chars',
          bottomMargin: 620.0);
    } else {
      await addNewAdmin();
    }
  }

  Future<void> addNewAdmin() async {
    if (!mounted) return;

    final url = Uri.parse('https://touristine.onrender.com/add-new-admin');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'email': emailController.text,
          'password': passwordController.text,
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        showCustomSnackBar(context, 'The new admin has been added',
            bottomMargin: 620.0);
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, responseData['error'], bottomMargin: 620.0);
      }
    } catch (error) {
      print('Error adding a new admin: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -7.5,
          bottom: -2,
          right: -130,
          left: -130,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/Images/Profiles/Admin/ProfilePage/AdminAddingBackground.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 250),
                  CustomField(
                    controller: firstNameController,
                    hintText: 'First Name',
                    obscureText: false,
                    fieldPrefixIcon: const FaIcon(
                      FontAwesomeIcons.user,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 15),
                  CustomField(
                    controller: lastNameController,
                    hintText: 'Last Name',
                    obscureText: false,
                    fieldPrefixIcon: const FaIcon(
                      FontAwesomeIcons.user,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 15),
                  CustomField(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                    fieldPrefixIcon: const FaIcon(
                      FontAwesomeIcons.envelope,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 15),
                  CustomField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                    fieldPrefixIcon: const FaIcon(
                      FontAwesomeIcons.lock,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () async {
                      await validateForm();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 13,
                      ),
                      backgroundColor: const Color(0xFF1E889E),
                      textStyle: const TextStyle(
                        fontSize: 30,
                        fontFamily: 'Zilla',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    child: const Text('Create Admin'),
                  ),
                  const SizedBox(height: 100),
                  Padding(
                    padding: const EdgeInsets.only(right: 320.0),
                    child: IconButton(
                      icon: const FaIcon(
                        FontAwesomeIcons.arrowLeft,
                        color: Color(0xFF1E889E),
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
