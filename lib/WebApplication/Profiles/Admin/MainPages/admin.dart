import 'package:touristine/WebApplication/Profiles/Admin/MainPages/DestinationUpload/dest_upload_home.dart';
import 'package:touristine/WebApplication/Profiles/Admin/MainPages/UserInteractions/user_interactions.dart';
import 'package:touristine/WebApplication/Profiles/Admin/MainPages/UserInteractions/suggested_places.dart';
import 'package:touristine/WebApplication/Profiles/Admin/MainPages/DestinationUpload/dest_generator.dart';
import 'package:touristine/WebApplication/Profiles/Admin/MainPages/DestinationUpload/my_dests_list.dart';
import 'package:touristine/WebApplication/Profiles/Admin/MainPages/UserInteractions/tab_bar_viewer.dart';
import 'package:touristine/WebApplication/Profiles/Admin/MainPages/Chatting/chatting_list.dart';
import 'package:touristine/WebApplication/Profiles/Admin/ActiveStatus/active_status.dart';
import 'package:touristine/WebApplication/Profiles/Admin/MainPages/cracks_analysis.dart';
import 'package:touristine/WebApplication/Profiles/Admin/MainPages/profile_page.dart';
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
    final url = Uri.parse('https://touristine.onrender.com/get-statistics');

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
      DestsUploadHomePage(token: widget.token),
      TabBarViewer(token: widget.token, changeTabIndex: changeTabIndex),
      CracksAnalysisPage(token: widget.token),
      ChattingList(token: widget.token),
      ProfilePage(token: widget.token)
    ];
  }

  void changeTabIndex(int newIndex, Map<String, dynamic> destinationInfo) {
    setState(() {
      _currentIndex = newIndex;
    });
    // Pass destinationToBeAdded to DestsUploadHomePage.
    _children[newIndex] = DestsUploadHomePage(
        token: widget.token, destinationToBeAdded: destinationInfo);
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
                        SizedBox(
                          height: 50,
                          width: 300,
                          // child: buildSearchBox(),
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
                                'Upload Places',
                                1,
                              ),
                              _buildBottomNavigationBarItem(
                                FontAwesomeIcons.usersViewfinder,
                                'User Interactions',
                                2,
                              ),
                              _buildBottomNavigationBarItem(
                                "assets/Images/Profiles/Admin/crack.png",
                                'Cracks Analysis',
                                3,
                              ),
                              _buildBottomNavigationBarItem(
                                FontAwesomeIcons.comment,
                                'Chatting',
                                4,
                              ),
                              _buildBottomNavigationBarItem(
                                FontAwesomeIcons.user,
                                'Profile',
                                5,
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

  String destinationMenuOption = "Add a Place";
  String userMenuOption = "User Interactions";

  Widget getCurrentTab() {
    if (_currentIndex == 0) {
      // Home Page.
      return _children[0];
    } else if (_currentIndex == 1) {
      // Plan Maker Tab.
      _children[1];
      // if (destinationMenuOption == "Add a Place") {
      //   return AddDestTab(token: widget.token);
      // } else if (destinationMenuOption == "My Places") {
      //   return AddedDestinationsPage(
      //     token: widget.token,
      //     onDestinationEdit: (Map<String, dynamic> destinationInfo) {},
      //   );
      // }
    } else if (_currentIndex == 2) {
      // Upload Places Tab.
      _children[2];
      // if (userMenuOption == "User Interactions") {
      //   return UserInteractionsPage(token: widget.token);
      // } else if (userMenuOption == "User Suggestions") {
      //   return SuggestedPlacesPage(
      //       token: widget.token, changeTabIndex: (int , Map<String, dynamic> ) {  },);
      // }
    } else if (_currentIndex == 3) {
      // Cracks Tab.
      return _children[3];
    } else if (_currentIndex == 4) {
      _children[3];
      // Chatting Tab.
    } else if (_currentIndex == 5) {
      // Profile Tab.
      _children[5];
      // return openProfilePageOption();
    }
    // Return a default widget if the index doesn't match any tab.
    return Container();
  }

  // void onTabTapped(int index) {
  //   setState(() {
  //     _currentIndex = index;
  //   });
  // }

  String profileMenuOption = "My Account"; // Will be moved.

  void onTabTapped(int index) async {
    if (index == 1) {
      final selectedOption = await showMenu(
        context: context,
        position: _currentIndex == 1
            ? const RelativeRect.fromLTRB(430, 65, 430, 0)
            : _currentIndex == 0
                ? const RelativeRect.fromLTRB(460, 65, 460, 0)
                : const RelativeRect.fromLTRB(400, 65, 400, 0),
        items: <PopupMenuEntry>[
          const PopupMenuItem<String>(
            value: "Add a Place",
            child: Text("Add a Place"),
          ),
          const PopupMenuItem<String>(
            value: "My Places",
            child: Text("My Places"),
          ),
        ],
      );
      if (selectedOption != null) {
        setState(() {
          destinationMenuOption = selectedOption;
          _currentIndex = index;
        });
      }
    } else if (index == 2) {
      final selectedOption = await showMenu(
        context: context,
        position: _currentIndex == 2
            ? const RelativeRect.fromLTRB(560, 65, 560, 0)
            : _currentIndex <= 1
                ? const RelativeRect.fromLTRB(590, 65, 590, 0)
                : const RelativeRect.fromLTRB(530, 65, 530, 0),
        items: <PopupMenuEntry>[
          const PopupMenuItem<String>(
            value: "User Interactions",
            child: Text("User Interactions"),
          ),
          const PopupMenuItem<String>(
            value: "User Suggestions",
            child: Text("User Suggestions"),
          ),
        ],
      );
      if (selectedOption != null) {
        setState(() {
          userMenuOption = selectedOption;
          _currentIndex = index;
        });
      }
    } else if (index == 5) {
      final selectedOption = await showMenu(
        context: context,
        position: _currentIndex == 5
            ? const RelativeRect.fromLTRB(920, 65, 920, 0)
            : const RelativeRect.fromLTRB(960, 65, 960, 0),
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
