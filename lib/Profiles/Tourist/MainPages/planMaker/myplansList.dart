import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:touristine/Notifications/SnackBar.dart';
import 'package:touristine/Profiles/Tourist/MainPages/PlanMaker/planPlaces.dart';

// ignore: must_be_immutable
class MyPlansTab extends StatefulWidget {
  final String token;
  List<Map<String, dynamic>> userPlans;

  MyPlansTab({super.key, required this.token, required this.userPlans});

  @override
  _MyPlansTabState createState() => _MyPlansTabState();
}

class _MyPlansTabState extends State<MyPlansTab> {
  List<Map<String, dynamic>> planContents = [];

  // A function to delete a specific plan.
  Future<void> deletePlan(String planId, int index) async {
    final url =
        Uri.parse('https://touristine.onrender.com/delete-plan/$planId');

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
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('message')) {
          setState(() {
            widget.userPlans.removeAt(index);
          });
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, 'Your plan has been deleted',
              bottomMargin: 0);
        } else {
          print('No message keyword found in the response');
        }
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
      } else if (response.statusCode == 404) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print("Plan was not found");
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Failed to delete this plan',
            bottomMargin: 0);
      }
    } catch (error) {
      print('Error deleting the plan: $error');
    }
  }

  // A function to fetch a specific plan.
  Future<void> fetchPlanContents(String planID) async {
    final url =
        Uri.parse('https://touristine.onrender.com/fetch-plan-contents');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {
          'planId': planID,
        },
      );
      if (response.statusCode == 200) {
        // Success.
        // Jenan, return back to me the contents of the plan as List<Map<String, dynamic>>
        // similar to the format shown at line 18 for the planContents list.
        // Note: other data such as lat and long for the places included in the plan
        // might be added later, I will keep you updated if I will add them.
        final Map<String, dynamic> responseData = json.decode(response.body);
        planContents =
            List<Map<String, dynamic>>.from(responseData['planData']);
        print(planContents);
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Error fetching the plan contents',
            bottomMargin: 0);
      }
    } catch (error) {
      print('Error fetching the plan: $error');
    }
  }

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
            widget.userPlans =
                List<Map<String, dynamic>>.from(json.decode(response.body));
            print(widget.userPlans);
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
      if (mounted) {
        print('Error fetching plans: $error');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserPlans();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userPlans.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 80),
            Image.asset(
              'assets/Images/Profiles/Tourist/emptyListTransparent.gif',
              fit: BoxFit.cover,
            ),
            const Text(
              'No plans found',
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Gabriola',
                  color: Color.fromARGB(255, 23, 99, 114)),
            ),
          ],
        ),
      );
    } else {
      return ListView.builder(
        itemCount: widget.userPlans.length,
        itemBuilder: (context, index) {
          final plan = widget.userPlans[index];
          return PlanCard(
            plan: plan,
            onTap: () async {
              // print(plan['places']);
              // Handle the card click event.......................
              print(plan['planId']);

              print('Card clicked: ${plan['destination']}');
              await fetchPlanContents(plan['planId']);
              // ignore: use_build_context_synchronously
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PlanPlacesPage(
                    token: widget.token,
                    planContents: planContents,
                  ),
                ),
              );
            },
            onDelete: () async {
              print(plan['planId']);
              await deletePlan(plan['planId'], index);
            },
          );
        },
      );
    }
  }
}

class PlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PlanCard({
    Key? key,
    required this.plan,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          height: 297,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
          ),
          child: Container(
            color: const Color.fromARGB(24, 30, 137, 158),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 10),
                      child: Text(
                        plan['destination'],
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Zilla',
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, right: 8),
                  child: Divider(
                    color: Color.fromARGB(126, 14, 63, 73),
                    thickness: 2,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0, left: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Image.network(
                            plan['imagePath'],
                            height: 195,
                            width: 155,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontFamily: 'Gabriola',
                                  color: Colors.black,
                                ),
                                children: [
                                  TextSpan(
                                    text: '${plan['numOfPlaces']}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontFamily: 'Time New Roman',
                                    ),
                                  ),
                                  const TextSpan(text: ' places suggested'),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontFamily: 'Gabriola',
                                  color: Colors.black,
                                ),
                                children: [
                                  TextSpan(
                                    text: '${plan['totalTime']}h',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontFamily: 'Time New Roman',
                                    ),
                                  ),
                                  const TextSpan(text: ' estimated time'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Text(
                              '${plan['startTime']} - ${plan['endTime']}',
                              style: const TextStyle(
                                fontSize: 23,
                                fontFamily: 'Times New Roman',
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Text(
                                  plan['date'],
                                  style: const TextStyle(
                                    fontSize: 23,
                                    fontFamily: 'Times New Roman',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 70),
                              GestureDetector(
                                onTap: onDelete,
                                child: const FaIcon(
                                  FontAwesomeIcons.trash,
                                  color: Color(0xFF1E889E),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
