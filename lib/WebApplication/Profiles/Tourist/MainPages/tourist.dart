import 'package:touristine/WebApplication/Profiles/Tourist/MainPages/DestinationUpload/dest_generator.dart';
import 'package:touristine/WebApplication/Profiles/Tourist/MainPages/DestinationUpload/my_dests_list.dart';
import 'package:touristine/WebApplication/Profiles/Tourist/Profile/Sections/interests_filling.dart';
import 'package:touristine/WebApplication/Profiles/Tourist/MainPages/planMaker/plan_generator.dart';
import 'package:touristine/WebApplication/Profiles/Tourist/MainPages/planMaker/my_plans_list.dart';
import 'package:touristine/WebApplication/Profiles/Tourist/MainPages/Home/custom_search_bar.dart';
import 'package:touristine/WebApplication/Profiles/Tourist/MainPages/Chatting/chatting_list.dart';
import 'package:touristine/WebApplication/Profiles/Tourist/Profile/Sections/my_account.dart';
import 'package:touristine/WebApplication/LoginAndRegistration/MainPages/landing_page.dart';
import 'package:touristine/WebApplication/Profiles/Tourist/ActiveStatus/active_status.dart';
import 'package:touristine/WebApplication/Profiles/Tourist/MainPages/Home/home.dart';
import 'package:touristine/WebApplication/Notifications/snack_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
        'https://touristineapp.onrender.com/get-recommended-destinations');

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
    final url = Uri.parse(
        'https://touristineapp.onrender.com/get-popular-destinations');

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
        Uri.parse('https://touristineapp.onrender.com/get-other-destinations');

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
      Container(),
      Container(),
      ChattingList(token: widget.token),
      Container()
    ];
    moveToStep(widget.stepNum);
  }

  String planMenuOption = "Make Plan";
  String destinationMenuOption = "Suggest Place";

  Widget getCurrentTab() {
    if (_currentIndex == 0) {
      // Home Page.
      return _children[0];
    } else if (_currentIndex == 1) {
      // Plan Maker Tab.
      if (planMenuOption == "Make Plan") {
        return MakePlanTab(token: widget.token);
      } else if (planMenuOption == "My Plans") {
        return MyPlansTab(token: widget.token);
      }
    } else if (_currentIndex == 2) {
      // Upload Places Tab.
      if (destinationMenuOption == "Suggest Place") {
        return AddDestTab(token: widget.token);
      } else if (destinationMenuOption == "My Suggestions") {
        return DestinationCardGenerator(token: widget.token);
      }
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

  String profileMenuOption = "My Account";

  Widget openProfilePageOption() {
    if (profileMenuOption == 'My Account') {
      return AccountPage(
        token: widget.token,
        googleAccount: widget.googleAccount,
      );
    } else if (profileMenuOption == 'Interests Filling') {
      return InterestsFillingPage(token: widget.token);
    }
    // Log Out Option.
    else {
      // Extract the tourist email from the token.
      Map<String, dynamic> decodedToken = Jwt.parseJwt(widget.token);
      String touristEmail = decodedToken['email'];

      // Set the tourist active status to false and perform logout.
      setTouristActiveStatus(touristEmail, false).then((_) {
        if (widget.googleAccount) {
          GoogleSignIn googleSignIn = GoogleSignIn();
          googleSignIn.signOut();
          googleSignIn.disconnect();
        }
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LandingPage()));
      });

      // Return a placeholder widget while the logout operation completes.
      return Container();
    }
  }

  void moveToStep(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // A Function to build a search box.
  Widget buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 231, 231, 231),
          borderRadius: BorderRadius.circular(50),
        ),
        child: ListTile(
          tileColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CustomSearchBar(token: widget.token)),
            );
          },
          title: Container(
            padding:
                const EdgeInsets.only(top: 5, bottom: 5, right: 18, left: 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.only(right: 15),
                  child: const Icon(
                    FontAwesomeIcons.magnifyingGlass,
                    color: Color.fromARGB(163, 0, 0, 0),
                    size: 20,
                  ),
                ),
                const Expanded(
                  child: Text(
                    "Search Places",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(163, 0, 0, 0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getProfileBarTitle() {
    if (profileMenuOption == 'My Account') {
      return 'My Account';
    } else if (profileMenuOption == 'Interests Filling') {
      return 'Interests Filling';
    } else {
      return 'Log Out';
    }
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
                        child: buildSearchBox(),
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
                              FontAwesomeIcons.clock,
                              planMenuOption == "Make Plan"
                                  ? 'Make Plan'
                                  : 'My Plans',
                              1,
                            ),
                            _buildBottomNavigationBarItem(
                              FontAwesomeIcons.mapLocationDot,
                              destinationMenuOption == "Suggest Place"
                                  ? 'Suggest Place'
                                  : 'My Suggestions',
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
                ),
              ),
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
      backgroundColor: Colors.transparent,
    );
  }

  void onTabTapped(int index) async {
    if (index == 1) {
      final selectedOption = await showMenu(
        context: context,
        position: _currentIndex == 1
            ? const RelativeRect.fromLTRB(495, 65, 495, 0)
            : _currentIndex == 0
                ? const RelativeRect.fromLTRB(535, 65, 535, 0)
                : const RelativeRect.fromLTRB(465, 65, 465, 0),
        items: <PopupMenuEntry>[
          const PopupMenuItem<String>(
            value: "Make Plan",
            child: Text("Make Plan"),
          ),
          const PopupMenuItem<String>(
            value: "My Plans",
            child: Text("My Plans"),
          ),
        ],
      );
      if (selectedOption != null) {
        setState(() {
          planMenuOption = selectedOption;
          _currentIndex = index;
        });
      }
    } else if (index == 2) {
      final selectedOption = await showMenu(
        context: context,
        position: _currentIndex == 2
            ? const RelativeRect.fromLTRB(620, 65, 620, 0)
            : _currentIndex <= 1
                ? const RelativeRect.fromLTRB(660, 65, 660, 0)
                : const RelativeRect.fromLTRB(580, 65, 580, 0),
        items: <PopupMenuEntry>[
          const PopupMenuItem<String>(
            value: "Suggest Place",
            child: Text("Suggest Place"),
          ),
          const PopupMenuItem<String>(
            value: "My Suggestions",
            child: Text("My Suggestions"),
          ),
        ],
      );
      if (selectedOption != null) {
        setState(() {
          destinationMenuOption = selectedOption;
          _currentIndex = index;
        });
      }
    } else if (index == 4) {
      final selectedOption = await showMenu(
        context: context,
        position: _currentIndex == 4
            ? const RelativeRect.fromLTRB(880, 65, 880, 0)
            : const RelativeRect.fromLTRB(920, 65, 920, 0),
        items: <PopupMenuEntry>[
          const PopupMenuItem<String>(
            value: "My Account",
            child: Text("My Account"),
          ),
          const PopupMenuItem<String>(
            value: "Interests Filling",
            child: Text("Interests Filling"),
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
}
