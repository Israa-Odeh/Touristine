import 'package:touristine/AndroidMobileApp/Profiles/Admin/Profile/Sections/adding_admins.dart';
import 'package:touristine/AndroidMobileApp/LoginAndRegistration/MainPages/landing_page.dart';
import 'package:touristine/AndroidMobileApp/Profiles/Coordinator/Profile/Sections/my_account.dart';
import 'package:touristine/AndroidMobileApp/Profiles/Coordinator/ActiveStatus/active_status.dart';
import 'package:touristine/AndroidMobileApp/components/profile_picture.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String token;

  const ProfilePage({
    super.key,
    required this.token,
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
                'assets/Images/Profiles/Admin/ProfilePage/right-arrow.png',
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
                    'assets/Images/Profiles/Admin/ProfilePage/ProfileBackground.jpg'),
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
                  buildProfileTile("My Account",
                      "assets/Images/Profiles/Admin/ProfilePage/user.png", () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AccountPage(
                          token: widget.token,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 15),
                  buildProfileTile("New Admin",
                      "assets/Images/Profiles/Admin/ProfilePage/add.png", () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AdminAddingPage(
                          token: widget.token,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 15),
                  buildProfileTile("Log Out",
                      "assets/Images/Profiles/Admin/ProfilePage/logOut.png",
                      () {
                    // Extract the admin email from the token.
                    Map<String, dynamic> decodedToken =
                        Jwt.parseJwt(widget.token);
                    String adminEmail = decodedToken['email'];
                    // Set the admin active status to false.
                    setAdminActiveStatus(adminEmail, false);

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
