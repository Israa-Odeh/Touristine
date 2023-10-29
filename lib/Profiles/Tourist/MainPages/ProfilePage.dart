import 'package:flutter/material.dart';
import 'package:touristine/LoginAndRegistration/Login/loginPage.dart';
import 'package:touristine/Profiles/Tourist/Profile/Sections/MyAccount.dart';
import 'package:touristine/Profiles/Tourist/Profile/Sections/interestsFilling.dart';
import 'package:touristine/Profiles/Tourist/Profile/Sections/locationAccquisition.dart';


class ProfilePage extends StatefulWidget {
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
                image: AssetImage('assets/Images/Profiles/Tourist/ProfileBackground.jpg'),
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
                  const ProfilePicture(),
                  const SizedBox(height: 40),

                  buildProfileTile(
                      "My Account", "assets/Images/Profiles/Tourist/user.png", () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AccountPage(firstName: '', lastName: '', password: '', profileImage: null),
                      ),
                    );
                  }),

                  const SizedBox(height: 15),

                  buildProfileTile("Interests Filling",
                      "assets/Images/Profiles/Tourist/form.png", () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MainPage(),
                      ),
                    );
                  }),

                  const SizedBox(height: 15),

                  buildProfileTile("Location Acquisiton",
                      "assets/Images/Profiles/Tourist/location.png", () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => LocationPage(),
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
                      "Log Out", "assets/Images/Profiles/Tourist/logOut.png", () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const LoginPage()));
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

class ProfilePicture extends StatelessWidget {
  const ProfilePicture({
    super.key,
  });

  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(
          height: 150,
          width: 150,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: AssetImage("assets/Images/Profiles/Tourist/DefaultProfileImage.png"),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 50),
            Text(
              "First Name",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "  Last Name",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 10),
        Text(
          "user@email.com",
          style: TextStyle(fontSize: 17),
        ),
      ],
    );
  }
}
