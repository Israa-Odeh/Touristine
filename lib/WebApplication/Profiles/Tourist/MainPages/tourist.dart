import 'package:touristine/WebApplication/Profiles/Tourist/MainPages/Chatting/chatting_list.dart';
import 'package:touristine/WebApplication/Profiles/Tourist/ActiveStatus/active_status.dart';
import 'package:touristine/WebApplication/Profiles/Tourist/MainPages/DestinationUpload/dest_upload_home.dart';
import 'package:touristine/WebApplication/Profiles/Tourist/MainPages/planMaker/plan_maker_home.dart';
import 'package:touristine/WebApplication/Profiles/Tourist/MainPages/profile_page.dart';
import 'package:touristine/WebApplication/Profiles/Tourist/MainPages/Home/home.dart';
import 'package:touristine/WebApplication/Notifications/snack_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class TouristProfile extends StatefulWidget {
  final String token;
  final bool googleAccount;
  final int stepNum;

  const TouristProfile({
    super.key,
    required this.token,
    this.googleAccount = false,
    this.stepNum = 0,
  });

  @override
  _TouristAppState createState() => _TouristAppState();
}

class _TouristAppState extends State<TouristProfile> {
  int _currentIndex = 0;
  late List<Widget> _children = [];
  late Future<void> fetchData;

  List<Map<String, dynamic>> recommendedDestinations = [];
  List<Map<String, dynamic>> popularDestinations = [];
  List<Map<String, dynamic>> otherDestinations = [];

  @override
  void initState() {
    super.initState();
    fetchData = fetchAllData();

    // Extract the tourist email from the token.
    Map<String, dynamic> decodedToken = Jwt.parseJwt(widget.token);
    String touristEmail = decodedToken['email'];
    // Set the tourist active status to true.
    setTouristActiveStatus(touristEmail, true);
  }

  Future<void> fetchAllData() async {
    await getRecommendedDestinations();
    await getPopularDestinations();
    await getOtherDestinations();
    initializeChildren();
  }

  // A function to retrieve a list of recommended destinations.
  Future<void> getRecommendedDestinations() async {
    final url = Uri.parse(
        'https://touristine.onrender.com/get-recommended-destinations');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        // Success.
        // I need the "names" of the destinations along with their
        // corresponding "image paths" --> List<Map<String, dynamic>>.
        // Update the recommendedDestinations list with the received data.
        setState(() {
          recommendedDestinations =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });

        // Print the contents of recommendedDestinations to the console.
        print('Recommended Destinations:');
        for (var destination in recommendedDestinations) {
          print('Name: ${destination['name']}, Image: ${destination['image']}');
        }
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('error')) {
          if (responseData['error'] == 'User does not exist') {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
          } else if (responseData['error'] ==
              'Failed to retrieve recommended destinations') {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, 'Failed to retrieve recommended places',
                bottomMargin: 0);
          }
        }
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Error retrieving recommended places',
            bottomMargin: 0);
      }
    } catch (error) {
      print('Failed to fetch recommended places: $error');
    }
  }

  // A function to fetch popular destinations from the database.
  Future<void> getPopularDestinations() async {
    final url =
        Uri.parse('https://touristine.onrender.com/get-popular-destinations');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        // Success.
        // I need the "names" of the destinations along with their
        // corresponding "image paths" --> List<Map<String, dynamic>>.
        setState(() {
          popularDestinations =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });

        // Print the contents of popularDestinations to the console.
        print("-----------------------------------------------------");
        print("-----------------------------------------------------");

        print('Popular Destinations:');
        for (var destination in popularDestinations) {
          print('Name: ${destination['name']}, Image: ${destination['image']}');
        }
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('error')) {
          if (responseData['error'] == 'User does not exist') {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
          } else if (responseData['error'] ==
              'Failed to retrieve popular destinations') {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, 'Failed to retrieve popular places',
                bottomMargin: 0);
          }
        }
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Error retrieving popular places',
            bottomMargin: 0);
      }
    } catch (error) {
      print('Failed to fetch popular places: $error');
    }
  }

  // A function to fetch other destinations from the database.
  Future<void> getOtherDestinations() async {
    final url =
        Uri.parse('https://touristine.onrender.com/get-other-destinations');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        // Success.
        // I need the "names" of the destinations along with their
        // corresponding "image paths" --> List<Map<String, dynamic>>.

        setState(() {
          otherDestinations =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });

        // Print the contents of popularDestinations to the console.
        print("-----------------------------------------------------");
        print("-----------------------------------------------------");

        print('Other Destinations:');
        for (var destination in otherDestinations) {
          print('Name: ${destination['name']}, Image: ${destination['image']}');
        }
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('error')) {
          if (responseData['error'] == 'User does not exist') {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
          } else if (responseData['error'] ==
              'Failed to get other destinations') {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, 'Failed to retrieve other places',
                bottomMargin: 0);
          }
        }
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Error retrieving other places',
            bottomMargin: 0);
      }
    } catch (error) {
      print('Failed to fetch other places: $error');
    }
  }

  void initializeChildren() {
    _children = [
      HomePage(
        token: widget.token,
        recommendedDestinations: recommendedDestinations,
        popularDestinations: popularDestinations,
        otherDestinations: otherDestinations,
      ),
      PlanMakerPage(token: widget.token),
      DestsUploadHomePage(token: widget.token),
      ChattingList(token: widget.token),
      ProfilePage(token: widget.token, googleAccount: widget.googleAccount)
    ];

    moveToStep(widget.stepNum);
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
                FontAwesomeIcons.clock,
                'Plan Maker',
                1,
              ),
              _buildBottomNavigationBarItem(
                FontAwesomeIcons.mapLocationDot,
                'Upload Places',
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
    IconData icon,
    String label,
    int index,
  ) {
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
