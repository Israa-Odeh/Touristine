import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:touristine/Notifications/SnackBar.dart';
import 'package:touristine/Profiles/Tourist/MainPages/PlanMaker/myPlansList.dart';
import 'package:touristine/Profiles/Tourist/MainPages/PlanMaker/planGenerator.dart';

class PlanMakerPage extends StatefulWidget {
  final String token;

  const PlanMakerPage({super.key, required this.token});

  @override
  _PlanMakerPageState createState() => _PlanMakerPageState();
}

class _PlanMakerPageState extends State<PlanMakerPage> {
  List<Map<String, dynamic>> plans = [];
  List<Map<String, dynamic>> plansSample = [
    {
      'planID': 1, // Plan ID
      'destName': 'Jerusalem', // Dest. Name.
      'numOfPlaces': 5, // # Of suggested places in the dest.
      'totalTime': 5, // total estimated time to spend at the destination.
      'startTime': '10:00', // start time.
      'endTime': '15:00', // end time.
      'imagePath':
          'assets/Images/Profiles/Tourist/1T.png', // An image indicating the destination of the plan.
      'date': '26/05/2023', // The creation date of the plan.
      // Other data details will be added later on.
    },
    {
      'planID': 2,
      'destName': 'Nablus',
      'numOfPlaces': 3,
      'totalTime': 2,
      'startTime': '13:00',
      'endTime': '15:00',
      'imagePath': 'assets/Images/Profiles/Tourist/2T.jpg',
      'date': '06/10/2021'
    },
    {
      'planID': 3,
      'destName': 'Gaza',
      'numOfPlaces': 6,
      'totalTime': 4,
      'startTime': '09:00',
      'endTime': '13:00',
      'imagePath': 'assets/Images/Profiles/Tourist/3T.jpg',
      'date': '10/11/2020',
    },
  ];

  // A Function to fetch user plans from the backend.
  Future<void> fetchUserPlans() async {
    final url = Uri.parse('https://touristine.onrender.com/get-plans');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
      );
      if (mounted) {
        // Check if the widget is still mounted before updating the state.
        if (response.statusCode == 200) {
          // Jenan, I need to retrieve a list of plans - if there is any,
          // the retrieved list of plans will contain the following info:
          // the plan ID, Dest. Name, # Of suggested places in the dest.,
          // total estimated time to spend at the destination, the time
          // interval (from - to) which will be spent at the dest in general
          // (start time and end time), the creation date of the plan. You can
          // see the format of the list called plans at line 16.
          // Note: other data will be added later on.
          setState(() {
            // Update state only if the widget is still mounted.
            plans = List<Map<String, dynamic>>.from(json.decode(response.body));
            print(plans);
          });
        } else if (response.statusCode == 500) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
        } else {
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, 'Error fetching your plans',
              bottomMargin: 0);
        }
      }
    } catch (error) {
      print('Error fetching plans: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserPlans();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors
            .transparent, // Set the scaffold background color to transparent.
        appBar: PreferredSize(
          preferredSize:
              const Size.fromHeight(30), // Set height to 0 to hide the app bar.
          child: AppBar(
            backgroundColor: const Color.fromARGB(255, 25, 113, 130),
            elevation: 0, // Set elevation to 0 to remove shadow.
          ),
        ),
        body: Stack(
          children: [
            // Background Image.
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/Images/Profiles/Tourist/homeBackground.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              children: [
                Container(
                  color: const Color.fromARGB(31, 30, 137, 158),
                  child: const TabBar(
                    unselectedLabelColor: Color(0xFF1E889E),
                    tabs: [
                      Tab(
                        height: 60,
                        icon: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(FontAwesomeIcons.plus),
                            SizedBox(width: 15),
                            Text(
                              'Make Plan',
                            ),
                          ],
                        ),
                      ),
                      Tab(
                        height: 60,
                        icon: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.list,
                            ),
                            SizedBox(width: 15),
                            Text(
                              'My Plans',
                            ),
                          ],
                        ),
                      ),
                    ],
                    indicator: BoxDecoration(
                      color: Color(0xFF1E889E),
                    ),
                    labelStyle: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Times New Roman',
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      MakePlanTab(
                        token: widget.token,
                      ),
                      MyPlansTab(
                        token: widget.token,
                        userPlans: plans,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
