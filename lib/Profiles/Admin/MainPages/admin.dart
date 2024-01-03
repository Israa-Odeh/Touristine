import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:touristine/Notifications/SnackBar.dart';
import 'package:touristine/Profiles/Admin/MainPages/DestinationUpload/destUploadHome.dart';
import 'package:touristine/Profiles/Admin/MainPages/Home/home.dart';
import 'package:touristine/Profiles/Admin/MainPages/UserInteractions/tabBarViewer.dart';
import 'package:touristine/Profiles/Admin/MainPages/profilePage.dart';
import 'package:touristine/Profiles/Admin/MainPages/cracksAnalysis.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:touristine/Profiles/Tourist/MainPages/Chatting/chatting_list.dart';

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
