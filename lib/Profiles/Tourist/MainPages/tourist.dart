import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:touristine/Profiles/Tourist/MainPages/DestinationUpload/DestUploadHome.dart';
import 'package:touristine/Profiles/Tourist/MainPages/profilePage.dart';
import 'package:touristine/Profiles/Tourist/MainPages/chatting.dart';
import 'package:touristine/Profiles/Tourist/MainPages/Home/home.dart';
import 'package:touristine/Profiles/Tourist/MainPages/PlanMaker/planMakerHome.dart';

class TouristProfile extends StatefulWidget {
  final String token;
  final bool googleAccount;
  final int stepNum;

  const TouristProfile({
    super.key,
    required this.token,
    this.googleAccount = false,
    this.stepNum = 0, // Set default value to false.
  });

  @override
  _TouristAppState createState() => _TouristAppState();
}

class _TouristAppState extends State<TouristProfile> {
  int _currentIndex = 0;
  late List<Widget> _children;

  void moveToStep(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    _children = [
      HomePage(token: widget.token),
      PlanMakerPage(token: widget.token),
      DestsUploadHomePage(token: widget.token),
      ChattingPage(token: widget.token),
      ProfilePage(token: widget.token, googleAccount: widget.googleAccount)
    ];

    moveToStep(widget.stepNum);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // To prevent going back, simply return false
          return false;
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: _children[_currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: onTabTapped,
              items: [
                _buildBottomNavigationBarItem(
                    FontAwesomeIcons.house, 'Home Page', 0),
                _buildBottomNavigationBarItem(
                    FontAwesomeIcons.clock, 'Plan Maker', 1),
                _buildBottomNavigationBarItem(
                    FontAwesomeIcons.mapLocationDot, 'Places Upload', 2),
                _buildBottomNavigationBarItem(
                    FontAwesomeIcons.comment, 'Chatting', 3),
                _buildBottomNavigationBarItem(
                    FontAwesomeIcons.user, 'Profile', 4),
              ],
              selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
              unselectedItemColor: const Color.fromARGB(255, 255, 255, 255),
              // selectedFontSize: 12,
              // unselectedFontSize: 12,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ));
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(
      IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: _currentIndex == index
          ? Padding(
              padding: const EdgeInsets.only(bottom: 8.0, top: 0),
              child: Icon(icon),
            )
          : Icon(icon),
      label: label,
      backgroundColor: const Color(0xFF1E889E),
    );
  }
}
