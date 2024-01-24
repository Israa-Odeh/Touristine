import 'package:touristine/WebApplication/Profiles/Admin/MainPages/Destinations/touristine_destinations.dart';
import 'package:touristine/WebApplication/Profiles/Admin/MainPages/Chatting/chatting_list.dart';
import 'package:touristine/WebApplication/Profiles/Admin/Profile/Sections/adding_admins.dart';
import 'package:touristine/WebApplication/LoginAndRegistration/MainPages/landing_page.dart';
import 'package:touristine/WebApplication/Profiles/Admin/Profile/Sections/admins_list.dart';
import 'package:touristine/WebApplication/Profiles/admin/Profile/Sections/my_account.dart';
import 'package:touristine/WebApplication/Profiles/Admin/ActiveStatus/active_status.dart';
import 'package:touristine/WebApplication/Profiles/Admin/MainPages/Cracks/mapView.dart';
import 'package:touristine/WebApplication/Profiles/Admin/MainPages/Home/home.dart';
import 'package:touristine/WebApplication/Notifications/snack_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

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
  Map<String, int> mainStatistics = {};

  Future<void> updateChart() async {
    final url = Uri.parse('https://touristineapp.onrender.com/get-statistics');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {
          'StatisticType': "Visits Count",
          'city': "allcities",
          'category': "bycity"
        },
      );

      if (response.statusCode == 200) {
        // Israa, here you must handle the state of
        // the chart to be updated with the new data.
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> graphData = responseData['graphData'];

        // Map the data to categories using getPlaceCategory function
        final Map<String, int> newStatisticsResult = {};

        for (var item in graphData) {
          if (item is Map<String, dynamic> && item.length == 1) {
            final String key = item.keys.first;
            final double value = item.values.first.toDouble();
            newStatisticsResult[key] = value.toInt();
          }
        }
        setState(() {
          mainStatistics = Map.fromEntries(newStatisticsResult.entries);
        });
        print(mainStatistics);
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Error finding a result', bottomMargin: 0);
      }
    } catch (error) {
      print('Error during finding a result: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData = fetchAllData();

    // Extract the admin email from the token.
    Map<String, dynamic> decodedToken = Jwt.parseJwt(widget.token);
    String adminEmail = decodedToken['email'];
    // Set the admin active status to true.
    setAdminActiveStatus(adminEmail, true);
  }

  Future<void> fetchAllData() async {
    await updateChart();
    initializeChildren();
  }

  void initializeChildren() {
    _children = [
      HomePage(
        token: widget.token,
        statisticsResult: mainStatistics,
        selectedCity: 'All Cities',
        selectedCategory: 'By City',
        selectedStatisticsType: 'Visits Count',
      ),
      TouristineDestinations(token: widget.token),
      CracksMapViewer(token: widget.token),
      ChattingList(token: widget.token),
      Container()
    ];
  }

  String profileMenuOption = "My Account";

  String getProfileBarTitle() {
    if (profileMenuOption == 'My Account') {
      return 'My Account';
    } else if (profileMenuOption == 'New Admin') {
      return 'New Admin';
    } else if (profileMenuOption == 'View Admins') {
      return 'View Admins';
    } else {
      return 'Log Out';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Column(
            children: [
              Container(
                  color: const Color(0xFF1E889E),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 0.0),
                    child: Row(
                      children: [
                        const SizedBox(
                          height: 50,
                          width: 230,
                        ),
                        SizedBox(
                          width: 800,
                          child: BottomNavigationBar(
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
                                'Destinations',
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
                                getProfileBarTitle(),
                                4,
                              ),
                            ],
                            selectedItemColor:
                                const Color.fromARGB(255, 255, 255, 255),
                            unselectedItemColor:
                                const Color.fromARGB(255, 255, 255, 255),
                            selectedLabelStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  )),
              Expanded(
                child: FutureBuilder(
                  future: fetchData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return getCurrentTab();
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  String userMenuOption = "User Interactions";

  Widget getCurrentTab() {
    if (_currentIndex == 0) {
      // Home Page.
      return _children[0];
    } else if (_currentIndex == 1) {
      // Destinations Tab.
      return _children[1];
    } else if (_currentIndex == 2) {
      // Cracks Tab.
      return _children[2];
    } else if (_currentIndex == 3) {
      // Chatting Tab.
      return _children[3];
    } else if (_currentIndex == 4) {
      // Profile Tab.
      return openProfilePageOption();
    }
    // Return a default widget if the index doesn't match any tab.
    return Container();
  }

  Widget openProfilePageOption() {
    if (profileMenuOption == 'My Account') {
      return AccountPage(token: widget.token);
    } else if (profileMenuOption == 'New Admin') {
      return AdminAddingPage(token: widget.token);
    } else if (profileMenuOption == 'View Admins') {
      return AdminsListPage(token: widget.token);
    }
    // Log Out Option.
    else {
      // Extract the admin email from the token.
      Map<String, dynamic> decodedToken = Jwt.parseJwt(widget.token);
      String adminEmail = decodedToken['email'];

      // Set the admin active status to false.
      setAdminActiveStatus(adminEmail, false).then((_) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LandingPage()));
      });

      // Return a placeholder widget while the logout operation completes.
      return Container();
    }
  }

  void onTabTapped(int index) async {
    if (index == 4) {
      final selectedOption = await showMenu(
        context: context,
        position: _currentIndex == 4
            ? const RelativeRect.fromLTRB(850, 65, 850, 0)
            : const RelativeRect.fromLTRB(890, 65, 890, 0),
        items: <PopupMenuEntry>[
          const PopupMenuItem<String>(
            value: "My Account",
            child: Text("My Account"),
          ),
          const PopupMenuItem<String>(
            value: "New Admin",
            child: Text("New Admin"),
          ),
          const PopupMenuItem<String>(
            value: "View Admins",
            child: Text("View Admins"),
          ),
          const PopupMenuItem<String>(
            value: "Log Out",
            child: Text("Log Out"),
          ),
        ],
      );
      if (selectedOption != null) {
        setState(() {
          profileMenuOption = selectedOption;
          _currentIndex = index;
        });
      }
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
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
    double imageSize = 24.0;

    if (iconOrImage is IconData) {
      return Icon(iconOrImage, size: imageSize);
    } else if (iconOrImage is String) {
      return SizedBox(
        width: imageSize,
        height: imageSize,
        child: Image.asset(
          iconOrImage,
          fit: BoxFit.cover,
        ),
      );
    } else {
      throw ArgumentError('Invalid type for iconOrImage');
    }
  }
}
