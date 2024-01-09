import 'package:touristine/WebApplication/Profiles/Tourist/Profile/Sections/location_accquisition.dart';
import 'package:touristine/WebApplication/Profiles/Tourist/Profile/Sections/interests_filling.dart';
import 'package:touristine/WebApplication/Profiles/Tourist/Profile/Sections/my_account.dart';
import 'package:touristine/WebApplication/LoginAndRegistration/MainPages/landing_page.dart';
import 'package:touristine/WebApplication/Profiles/Tourist/ActiveStatus/active_status.dart';
import 'package:touristine/WebApplication/components/profile_picture.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String token;
  final bool googleAccount;

  const ProfilePage({
    super.key,
    required this.token,
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
                    token: widget.token,
                  ),
                  const SizedBox(height: 40),
                  buildProfileTile(
                      "My Account", "assets/Images/Profiles/Tourist/user.png",
                      () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AccountPage(
                          token: widget.token,
                          googleAccount: widget.googleAccount,
                        ),
                      ),
                    );
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
                  buildProfileTile(
                      "Log Out", "assets/Images/Profiles/Tourist/logOut.png",
                      () {
                    // Extract the tourist email from the token.
                    Map<String, dynamic> decodedToken =
                        Jwt.parseJwt(widget.token);
                    String touristEmail = decodedToken['email'];
                    // Set the tourist active status to false.
                    setTouristActiveStatus(touristEmail, false);
                    if (widget.googleAccount) {
                      GoogleSignIn googleSignIn = GoogleSignIn();
                      googleSignIn.signOut();
                      googleSignIn.disconnect();
                      // FirebaseAuth.instance.signOut();
                    }
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const LandingPage()));
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
