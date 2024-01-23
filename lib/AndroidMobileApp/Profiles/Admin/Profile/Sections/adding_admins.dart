import 'package:touristine/AndroidMobileApp/Profiles/Tourist/MainPages/planMaker/custom_bottom_sheet.dart';
import 'package:touristine/AndroidMobileApp/Notifications/snack_bar.dart';
import 'package:touristine/AndroidMobileApp/components/custom_field.dart';
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
        passwordController.text.isEmpty ||
        selectedCity.isEmpty;
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
          bottomMargin: 655.0);
    } else if (!isNameValid(firstNameController.text)) {
      showCustomSnackBar(context, 'Invalid first name: 2-20 characters only',
          bottomMargin: 655.0);
    } else if (!isNameValid(lastNameController.text)) {
      showCustomSnackBar(context, 'Invalid last name: 2-20 characters only',
          bottomMargin: 655.0);
    } else if (!isEmailValid(emailController.text)) {
      showCustomSnackBar(context, 'Please enter a valid email address',
          bottomMargin: 655.0);
    } else if (!isPasswordValid(passwordController.text)) {
      showCustomSnackBar(context, 'Password must contain 8-30 chars',
          bottomMargin: 655.0);
    } else {
      await addNewAdmin();
    }
  }

  List<String> citiesList = ['Jerusalem', 'Nablus', 'Ramallah', 'Bethlehem'];
  String selectedCity = '';
  void showCityBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return CustomBottomSheet(itemsList: citiesList, height: 300);
      },
    ).then((value) {
      // Handle the selected item from the bottom sheet.
      if (value != null) {
        setState(() {
          selectedCity = value;
        });
      }
    });
  }

  Future<void> addNewAdmin() async {
    if (!mounted) return;

    final url = Uri.parse('https://touristineapp.onrender.com/add-new-admin');

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
          'city': selectedCity,
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        showCustomSnackBar(context, 'The new admin has been added',
            bottomMargin: 655.0);
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, responseData['error'], bottomMargin: 655.0);
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
                  const SizedBox(height: 200),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: ElevatedButton(
                      onPressed: showCityBottomSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 231, 231, 231),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: SizedBox(
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Text(
                                selectedCity.isEmpty
                                    ? 'Select City'
                                    : selectedCity,
                                style: const TextStyle(
                                    color: Color.fromARGB(163, 0, 0, 0),
                                    fontSize: 22),
                              ),
                            ),
                            const FaIcon(
                              FontAwesomeIcons.city,
                              color: Color.fromARGB(100, 0, 0, 0),
                              size: 25,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 70),
                  Padding(
                    padding: const EdgeInsets.only(right: 325.0),
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
