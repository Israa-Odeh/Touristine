import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:touristine/LoginAndRegistration/Login/ForgotPassword.dart';
import 'package:touristine/LoginAndRegistration/landingPage.dart';
import 'package:touristine/Notifications/SnackBar.dart';
import 'package:touristine/components/textField.dart';

// Import the http package.
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  // Constructor.
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  // Text fields (username and password) controllers.
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // A boolean variable for the "Remember Me" checkbox state.
  bool rememberPassword = false; // Initially unchecked.

  // A boolean variable for the "Forgot Password" state.
  bool forgetPasswordTapped = false; // Initially untapped.

  // Animation controller for the google button.
  AnimationController? _animationController;

  // Animation for the google button.
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller.
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Create a scale animation for the button, transition the scale of
    // the button from an initial scale of 1.0 to a final scale of 0.95.
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(_animationController!);

    // Add a listener to the animation to rebuild the widget when it changes.
    _scaleAnimation.addListener(() {
      setState(() {});
    });
  }

  // Functions Section.
  // Validation function to check if any text field is unfilled.
  bool isInputEmpty() {
    return emailController.text.isEmpty || passwordController.text.isEmpty;
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

  Future<void> sendData() async {
    final url = Uri.parse(
        'http://your-nodejs-server-url/signin'); // Replace this with your Node.js server URL.
    try {
      final response = await http.post(
        url,
        body: {
          'email': emailController.text,
          'password': passwordController.text,
          'remember_me': rememberPassword.toString(), // Convert to string
          // "Flag 'rememberPassword' stores the user's choice to remember
          // their email and Password (True or False)."

          // Include any additional information here.
        },
      );

      // _____________________________________________________________________________________________
      // In the response......
      /* Jenan, return additional data that confirms the user's existence (maybe a flag).
      If the provided email exists but the password is incorrect,
      return an appropriate error message. If the entered credentials,
      including the email, do not exist in the system, return an appropriate
      error message in the response, which I'll display as notifications to the user */
      
      // Note: After ensuring from user existence, check the "remember_me" flag, if it's true
      // then users login information should be stored locally, and they won't have to sign in
      // on subsequent visits. Their info will be automatically retrieved when they enter the 
      // login page. We'll use shared_preferences to implement this feature or use whatever
      // you need.

      // Successful response from the Node.js server.
      if (response.statusCode == 200) {
        /* Here you can handle the response as needed.
        Jenan, the code's behavior depends on whether the user is signing in for the first time.
        To achieve this, we need to retrieve a flag that indicates if it's the user's initial sign-in.
        This flag is crucial in determining whether to display the user's profile or the pages showcasing
        the services available to our app users during their first sign-in. Additionally, it's important
        to specify the user type, whether they are an admin, staff member, or tourist. This information
        will guide us in deciding which interfaces to present to the user. */

        // After completing this step, please stop. I will open the relevant interfaces based on the
        // provided response values. It will be something like the following two lines, then I'll use 
        // userType and isFirstSignIn as required. Change the variable types as you need and add what
        // is needed, it's just a dummy example.
        // final String userType = responseJson['userType'];
        // final bool isFirstSignIn = responseJson['isFirstSignIn'];
      } else {
        // Handle errors here.
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Failed to sign in, please try again');
      }
    } catch (e) {
      // Handle network or other exceptions here.
      print('Error: $e');
    }
  }

// A function for user sign-in.
  void signUserIn() {
    // Check if the textFields are filled.
    if (isInputEmpty()) {
      showCustomSnackBar(context, 'Please fill in all fields');
    } else if (!isEmailValid(emailController.text)) {
      showCustomSnackBar(context, 'Please enter a valid email address');
    } else if (!isPasswordValid(passwordController.text)) {
      showCustomSnackBar(context, 'Password must contain 8-30 chars');
    } else {
      sendData();
    }
  }

  // A function to handle Google sign-in.
  void handleGoogleSignIn() {
    // Implement Google sign-in logic here.
    // Search about some mechansim to implement this
    // If you don't find tell me, there is a specific
    // package in dart to do it with firebase.
  }

  void forgotPassword() {
    setState(() {
      forgetPasswordTapped = true;
    });

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => ForgotPasswordPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, // Enable resizing when keyboard appears.
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // A spacer.
              const SizedBox(height: 70),

              // SignIn Image.
              Image.asset(
                'assets/Images/LoginPage/SignIn/SignIn.gif',
                width: 300,
                height: 210,
              ),

              //A spacer
              const SizedBox(height: 10),

              // A descriptive text.
              const Text(
                'Let\'s explore Palestine together!',
                style: TextStyle(
                  color: Color(0xFF455a64),
                  fontSize: 30,
                  fontFamily: 'Gabriola',
                  fontWeight: FontWeight.bold,
                ),
              ),

              //A spacer.
              const SizedBox(height: 25),

              //Email Textfield.
              MyTextField(
                controller: emailController,
                hintText: 'Email',
                obscureText: false,
                fieldPrefixIcon: const FaIcon(
                  FontAwesomeIcons.envelope,
                  size: 30,
                ),
              ),

              //Password Textfield.
              const SizedBox(height: 10),
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
                fieldPrefixIcon: const FaIcon(
                  FontAwesomeIcons.lock,
                  size: 30,
                ),
              ),

              // A spacer.
              const SizedBox(height: 10),

              // A row containing options for "Remember Me" and "Forgot Password."
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: rememberPassword,
                      onChanged: (value) {
                        setState(() {
                          rememberPassword = value!;
                        });
                      },
                      activeColor: const Color(0xFF1E889E),
                    ),
                    const Text(
                      'Remember Me',
                      style: TextStyle(
                        color: Color(0xFF455a64),
                        fontSize: 25,
                        fontFamily: 'Gabriola',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 80),
                    InkWell(
                      onTap: forgotPassword,
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: forgetPasswordTapped
                              ? const Color(0xFF1E889E)
                              : const Color(0xFF455a64),
                          fontSize: 25,
                          fontFamily: 'Gabriola',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // A spacer.
              const SizedBox(height: 25),

              // Log in BTN.
              ElevatedButton(
                onPressed: signUserIn,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 70,
                    vertical: 13,
                  ),
                  backgroundColor: const Color(0xFF1E889E),
                  textStyle: const TextStyle(
                    fontSize: 30,
                    fontFamily: 'Zilla',
                    fontWeight: FontWeight.w300,
                  ),
                ),
                child: const Text('Sign In'),
              ),

              // A spacer.
              const SizedBox(height: 20),

              // A row containing dividers and text.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    const Row(
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
                            'Or continue with',
                            style: TextStyle(
                              color: Color(0xFF455a64),
                              fontSize: 30,
                              fontFamily: 'Gabriola',
                              fontWeight: FontWeight.w500,
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

                    // A spacer.
                    const SizedBox(height: 10),

                    // A row containing return back and google buttons.
                    Row(
                      mainAxisAlignment: MainAxisAlignment
                          .start, // Align buttons in the center.
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 40.0),
                          child: IconButton(
                            icon: const FaIcon(
                              FontAwesomeIcons.arrowLeft,
                              color: Color(0xFF1e889e),
                              size: 30,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => LandingPage(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(
                            width:
                                90), // Add horizontal spacing between the icons.

                        // Google BTN animation.
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30.0),
                          child: InkWell(
                            onTap: () {
                              // Start the button animation.
                              _animationController!.forward();

                              // Simulate a delay before signing-in process.
                              Future.delayed(const Duration(milliseconds: 500),
                                  () {
                                // Stop the button animation
                                _animationController!.reverse();

                                // Perform the Google sign-in action.
                                handleGoogleSignIn();
                              });
                            },
                            child: Transform.scale(
                              scale: _scaleAnimation
                                  .value, // Apply the animation scale
                              // Create a circular shape around the Google icon.
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFa5cfd8),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/Images/LoginPage/SignIn/google.png',
                                    width: 50,
                                    height: 50,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
