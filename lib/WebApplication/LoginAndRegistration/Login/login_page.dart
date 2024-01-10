import 'package:touristine/WebApplication/LoginAndRegistration/Login/forgot_password.dart';
import 'package:touristine/WebApplication/LoginAndRegistration/MainPages/splash_screen.dart';
import 'package:touristine/WebApplication/Notifications/snack_bar.dart';
import 'package:touristine/WebApplication/Profiles/Admin/MainPages/admin.dart';
import 'package:touristine/WebApplication/Profiles/Tourist/MainPages/tourist.dart';
import 'package:touristine/WebApplication/UserData/user_provider.dart';
import 'package:touristine/WebApplication/components/text_field.dart';
import 'package:touristine/WebApplication/onBoarding/Admin/admin_onboarding_page.dart';
import 'package:touristine/WebApplication/onBoarding/Tourist/tourist_onboarding_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  // Text fields (username and password) controllers.
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  late ImageProvider profileImageProvider; // To uplaod the image early.
  bool isLoading = false;

  // A boolean variable for the "Remember Me" checkbox state.
  bool rememberPassword = false; // Initially unchecked.

  // A boolean variable for the "Forgot Password" state.
  bool forgetPasswordTapped = false; // Initially untapped.

  // Animation controller for the google button.
  AnimationController? _animationController;

  // Animation for the google button.
  late Animation<double> _scaleAnimation;

  // Define a function to store the login information using shared preferences.
  Future<void> storeLoginInfoLocally() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Store the login information if "Remember Me" is checked.
    if (rememberPassword) {
      await prefs.setString('email', emailController.text);
      await prefs.setString('password', passwordController.text);
      // Store other necessary user information as needed.
    } else {
      // Clear stored login information if "Remember Me" is unchecked.
      await prefs.remove('email');
      await prefs.remove('password');
    }
  }

  // Define a function to check and load stored login information.
  Future<void> loadLoginInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('email') && prefs.containsKey('password')) {
      setState(() {
        emailController.text = prefs.getString('email')!;
        passwordController.text = prefs.getString('password')!;
        rememberPassword = true; // Set the checkbox state as checked.
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadLoginInfo();

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
    final url = Uri.parse('https://touristine.onrender.com/login');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'email': emailController.text,
          'password': passwordController.text,
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

      final Map<String, dynamic> responseData = json.decode(response.body);

      // Successful response from the Node.js server.
      if (response.statusCode == 200) {
        await storeLoginInfoLocally();
        if (responseData.containsKey('status') &&
            responseData.containsKey('type')) {
          // It is a tourist user type in this case.
          if (responseData['status'] == true && responseData['type'] == 100) {
            String token = responseData['token'];
            String firstName = responseData['firstName'];
            String lastName = responseData['lastName'];
            String password = responseData['password'];
            String? imageURL = responseData['profileImage'];

            print("Email extracted from token: $token");
            print("first name: $firstName");
            print("last name: $lastName");
            print("Password: $password");
            print("Profile Image: $imageURL");

            // ignore: use_build_context_synchronously
            context.read<UserProvider>().updateData(
                  newFirstName: firstName,
                  newLastName: lastName,
                  newPassword: password,
                );

            if (imageURL != null && imageURL != "") {
              profileImageProvider = NetworkImage(imageURL);
              // ignore: use_build_context_synchronously
              precacheImage(profileImageProvider, context);
              // ignore: use_build_context_synchronously
              context.read<UserProvider>().updateImage(newImageURL: imageURL);
            } else {
              // ignore: use_build_context_synchronously
              context.read<UserProvider>().updateImage(newImageURL: null);
            }
            // ignore: use_build_context_synchronously
            Navigator.pushReplacement(
              // This will be edited based on the profile type.
              context,
              MaterialPageRoute(
                builder: (context) => SplashScreen(
                  profileType: TouristProfile(
                    token: token,
                  ),
                ),
              ),
            );
          }
          // It is an Admin user type in this case.
          else {
            String token = responseData['token'];
            String firstName = responseData['firstName'];
            String lastName = responseData['lastName'];
            String password = responseData['password'];
            String? imageURL = responseData['profileImage'];

            print("Email extracted from token: $token");
            print("first name: $firstName");
            print("last name: $lastName");
            print("Password: $password");
            print("Profile Image: $imageURL");

            // ignore: use_build_context_synchronously
            context.read<UserProvider>().updateData(
                  newFirstName: firstName,
                  newLastName: lastName,
                  newPassword: password,
                );

            if (imageURL != null && imageURL != "") {
              profileImageProvider = NetworkImage(imageURL);
              // ignore: use_build_context_synchronously
              precacheImage(profileImageProvider, context);
              // ignore: use_build_context_synchronously
              context.read<UserProvider>().updateImage(newImageURL: imageURL);
            } else {
              // ignore: use_build_context_synchronously
              context.read<UserProvider>().updateImage(newImageURL: null);
            }
            // Here I need to check whether it's the admin's first time logging in.
            // ignore: use_build_context_synchronously
            if (responseData['newAdmin'] == "true") {
              // ignore: use_build_context_synchronously
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => AdminOnBoardingPage(
                          token: token,
                        )),
              );
            } else {
              // ignore: use_build_context_synchronously
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SplashScreen(
                    profileType: AdminProfile(
                      token: token,
                    ),
                  ),
                ),
              );
            }
          }
        }

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
      } else if (response.statusCode == 500) {
        if (responseData.containsKey('error')) {
          if (responseData['error'] == 'User does not exist') {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, responseData['error']);
          } else if (responseData['error'] ==
              'Username or Password does not match') {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, 'Password doesn\'t match the email');
          } else if (responseData['error'] == 'All fields must be filled') {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, 'Please fill in all fields');
          } else {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, 'Failed to sign in, please try again');
          }
        }
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

  // A function for user sign-in with Google.
  Future<void> signInWithGoogle() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await Firebase.initializeApp();
    } catch (e) {
      print('Error initializing Firebase: $e');
    }

    try {
      // Trigger the authentication flow.
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return;
      }

      // Obtain the auth details from the request.
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential.
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential.
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Fetch the user information.
      User? user = userCredential.user;

      // Print the user information.
      if (user != null) {
        // Prepare the data to send to the backend.
        List<String> nameParts = user.displayName!.split(' ');
        String? firstName;
        String? lastName;

        if (nameParts.length >= 2) {
          firstName = nameParts[0]; // Extracting the first part.
          lastName = nameParts
              .sublist(1)
              .join(' '); // Extracting the rest as the last name.
        }

        print('User Information:');
        print('User ID: ${user.uid}');
        print('First Name: $firstName');
        print('Last Name: $lastName');
        print('Email: ${user.email}');
        print('Photo URL: ${user.photoURL}');

        bool hasPassword = false;

        //'userID': user.uid,
        var userData = {
          'firstName': firstName,
          'lastName': lastName,
          'email': user.email,
          'password': hasPassword.toString(),
          'photoURL': user.photoURL,
          // Jenan, here don't use firebase to store the image,
          // Store the url only as a field of String and I can
          // easily retrive the image from the URL.
        };

        var url = 'https://touristine.onrender.com/signInWithGoogle';

        try {
          var response = await http.post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: userData,
            // You may want to establish a distinct collection for users who log in using Google.
            // You need to check if the userID exists and is stored; if it is, there's no need to store it.
            // But if the sent ID doesn't exist, store all the user fields as mentioned above:
            // userID (Unique ID from Google), firstName, lastName, email, and the photoURL.
          );

          if (response.statusCode == 200) {
            // Jenan send me a flag to indicate whether it's the user
            // first time to sign in using google (true) or not (false),
            // in order to display the suitable interfaces accordingly.
            String isNewUser;
            final Map<String, dynamic> responseData =
                json.decode(response.body);
            if (responseData.containsKey('type') &&
                responseData['type'] == 100) {
              // It is a tourist user type in this case.
              isNewUser = responseData['newUser'];
              if (isNewUser == "true") {
                // A new user, open the tourist onboarding interfaces since it's their first time.
                final String token =
                    responseData['token']; // Contains the email.
                // ignore: use_build_context_synchronously
                context.read<UserProvider>().updateData(
                      newFirstName: firstName ?? "",
                      newLastName: lastName ?? "",
                      newPassword: "",
                    );

                // ignore: use_build_context_synchronously
                context
                    .read<UserProvider>()
                    .updateImage(newImageURL: user.photoURL);
                // ignore: use_build_context_synchronously
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TouristOnBoardingPage(
                            token: token,
                            googleAccount: true,
                          )),
                );
              } else {
                final String token =
                    responseData['token']; // Contains the email.

                // ignore: use_build_context_synchronously
                context.read<UserProvider>().updateData(
                      newFirstName: firstName ?? "",
                      newLastName: lastName ?? "",
                      newPassword: "",
                    );

                // ignore: use_build_context_synchronously
                context
                    .read<UserProvider>()
                    .updateImage(newImageURL: user.photoURL);

                // Open the tourist account.
                // ignore: use_build_context_synchronously
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SplashScreen(
                      profileType: TouristProfile(
                        token: token,
                        googleAccount: true,
                      ),
                    ),
                  ),
                );
              }
            }
          } else if (response.statusCode == 500) {
            final Map<String, dynamic> responseData =
                json.decode(response.body);
            if (responseData.containsKey('error')) {
              // ignore: use_build_context_synchronously
              showCustomSnackBar(context, responseData['error']);
            }
          } else {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, 'Log In with Google Failed');
          }
        } catch (e) {
          print('Error sending data to the server: $e');
        }
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'User information aren\'t available');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  void forgotPassword() {
    setState(() {
      forgetPasswordTapped = true;
    });

    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const ForgotPasswordPage()));
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
                fit: BoxFit.cover,
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
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                        const SizedBox(width: 90),

                        // Google BTN animation.
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30.0),
                          child: isLoading
                              ? const Padding(
                                  padding: EdgeInsets.only(left: 20.0),
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF1E889E)),
                                  ),
                                )
                              : InkWell(
                                  onTap: () async {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    // Start the button animation.
                                    _animationController!.forward();

                                    // Simulate a delay before signing-in process.
                                    await Future.delayed(
                                        const Duration(milliseconds: 500));

                                    // Stop the button animation.
                                    _animationController!.reverse();

                                    // Perform the Google sign-in action.
                                    await signInWithGoogle();

                                    setState(() {
                                      isLoading = false;
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
