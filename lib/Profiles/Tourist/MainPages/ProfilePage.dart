import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:touristine/LoginAndRegistration/MainPages/landingPage.dart';
import 'package:touristine/Notifications/SnackBar.dart';
import 'package:touristine/Profiles/Tourist/Profile/Sections/MyAccount.dart';
import 'package:touristine/Profiles/Tourist/Profile/Sections/interestsFilling.dart';
import 'package:touristine/Profiles/Tourist/Profile/Sections/locationAccquisition.dart';
import 'package:touristine/components/profilePicture.dart';

class ProfilePage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String token;
  final String password;
  final String? profileImage;
  final bool googleAccount;

  const ProfilePage({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.token,
    required this.password,
    this.profileImage,
    this.googleAccount = false, // Set default value to false.
  });

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // A Function to build a profile tile with a title, image, and onTap action.
  Widget buildProfileTile(
      String title, String imagePath, VoidCallback onTapAction) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        tileColor: const Color.fromARGB(255, 237, 238, 240),
        contentPadding: EdgeInsets.zero, // Remove default ListTile padding.
        onTap: onTapAction,
        title: Container(
          padding:
              const EdgeInsets.only(top: 13, bottom: 13, right: 18, left: 18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.only(right: 15),
                child: Image.asset(
                  imagePath,
                  width: 35,
                ),
              ),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),
              Image.asset(
                'assets/Images/Profiles/Tourist/right-arrow.png',
                width: 22,
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image
        Positioned(
          top: -120,
          bottom: 0,
          right: 0,
          left: 0,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/Images/Profiles/Tourist/ProfileBackground.jpg'),
                fit: BoxFit.cover,
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
                  const SizedBox(height: 80),
                  ProfilePicture(
                    firstName: widget.firstName,
                    lastName: widget.lastName,
                    token: widget.token,
                    imagePath: widget.profileImage,
                  ),
                  const SizedBox(height: 40),

                  buildProfileTile(
                      "My Account", "assets/Images/Profiles/Tourist/user.png",
                      () {
                    !widget.googleAccount
                        ? Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AccountPage(
                                firstName: widget.firstName,
                                lastName: widget.lastName,
                                token: widget.token,
                                password: widget.password,
                                profileImageURL: widget.profileImage,
                              ),
                            ),
                          )
                        : showCustomSnackBar(
                            context, 'You\'re logged in with Google', bottomMargin: 450);
                  }),

                  const SizedBox(height: 15),

                  buildProfileTile("Interests Filling",
                      "assets/Images/Profiles/Tourist/form.png", () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            InterestsFillingPage(token: widget.token),
                      ),
                    );
                  }),

                  const SizedBox(height: 15),

                  buildProfileTile("Location Acquisiton",
                      "assets/Images/Profiles/Tourist/location.png", () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => LocationPage(token: widget.token),
                      ),
                    );
                  }),

                  const SizedBox(height: 15),

                  buildProfileTile("Notifications",
                      "assets/Images/Profiles/Tourist/notification.png", () {
                    // Define the action for this tile.
                  }),

                  const SizedBox(height: 15),

                  buildProfileTile(
                      "Log Out", "assets/Images/Profiles/Tourist/logOut.png",
                      () {
                    GoogleSignIn googleSignIn = GoogleSignIn();
                    googleSignIn.disconnect();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => LandingPage()));
                  }),
                  // Add more tiles as needed...
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
