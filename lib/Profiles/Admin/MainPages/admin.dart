// import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:touristine/Notifications/SnackBar.dart';
// import 'package:http/http.dart' as http;
import 'package:touristine/Profiles/Admin/MainPages/DestinationUpload/destUploadHome.dart';
import 'package:touristine/Profiles/Admin/MainPages/Home/home.dart';
import 'package:touristine/Profiles/Admin/MainPages/profilePage.dart';
import 'package:touristine/Profiles/Admin/MainPages/chatting.dart';
import 'package:touristine/Profiles/Admin/MainPages/cracksAnalysis.dart';

class AdminProfile extends StatefulWidget {
  final String token;

  const AdminProfile({
    super.key,
    required this.token,
  });

  @override
  _AdminAppState createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminProfile> {
  int _currentIndex = 0;
  late List<Widget> _children = [];
  late Future<void> fetchData;

  // To be edited for the admin.
  // List<Map<String, dynamic>> recommendedDestinations = [];
  // List<Map<String, dynamic>> popularDestinations = [];
  // List<Map<String, dynamic>> otherDestinations = [];

  @override
  void initState() {
    super.initState();
    fetchData = fetchAllData();
  }

  Future<void> fetchAllData() async {
    // await getRecommendedDestinations();
    // await getPopularDestinations();
    // await getOtherDestinations();
    initializeChildren();
  }

  void initializeChildren() {
    _children = [
      HomePage(token: widget.token),
      DestsUploadHomePage(token: widget.token),
      CracksAnalysisPage(token: widget.token),
      ChattingPage(token: widget.token),
      ProfilePage(token: widget.token)
    ];
  }

  void moveToStep(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // To prevent going back.
        return false;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: FutureBuilder(
            future: fetchData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return _children[_currentIndex];
              } else {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF1E889E)),
                  ),
                );
              }
            },
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: onTabTapped,
            items: [
              _buildBottomNavigationBarItem(
                FontAwesomeIcons.house,
                'Home Page',
                0,
              ),
              _buildBottomNavigationBarItem(
                FontAwesomeIcons.mapLocationDot,
                'Upload Places',
                1,
              ),
              _buildBottomNavigationBarItem(
                "assets/Images/Profiles/Admin/crack.png",
                'Cracks Analysis',
                2,
              ),
              _buildBottomNavigationBarItem(
                FontAwesomeIcons.comment,
                'Chatting',
                3,
              ),
              _buildBottomNavigationBarItem(
                FontAwesomeIcons.user,
                'Profile',
                4,
              ),
            ],
            selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
            unselectedItemColor: const Color.fromARGB(255, 255, 255, 255),
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(
    dynamic iconOrImage,
    String label,
    int index,
  ) {
    return BottomNavigationBarItem(
      icon: _currentIndex == index
          ? Padding(
              padding: const EdgeInsets.only(bottom: 8.0, top: 0),
              child: _buildIconOrImage(iconOrImage),
            )
          : _buildIconOrImage(iconOrImage),
      label: label,
      backgroundColor: const Color(0xFF1E889E),
    );
  }

  Widget _buildIconOrImage(dynamic iconOrImage) {
    double imageSize = 24.0; // Set the desired size for the image

    if (iconOrImage is IconData) {
      // If it's an icon, return the Icon widget
      return Icon(iconOrImage, size: imageSize);
    } else if (iconOrImage is String) {
      // If it's a string (assumed to be an image path), return the Image widget
      return SizedBox(
        width: imageSize,
        height: imageSize,
        child: Image.asset(
          iconOrImage,
          fit: BoxFit.contain, // Adjust the fit based on your requirements
        ),
      );
    } else {
      // Handle other cases or throw an exception based on your requirements
      throw ArgumentError('Invalid type for iconOrImage');
    }
  }
}
