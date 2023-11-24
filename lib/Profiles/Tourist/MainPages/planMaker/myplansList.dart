import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:touristine/Profiles/Tourist/MainPages/PlanMaker/planPlaces.dart';

class MyPlansTab extends StatefulWidget {
  final String token;
  final List<Map<String, dynamic>> userPlans;

  const MyPlansTab({super.key, required this.token, required this.userPlans});

  @override
  _MyPlansTabState createState() => _MyPlansTabState();
}

class _MyPlansTabState extends State<MyPlansTab> {
  final List<Map<String, dynamic>> planContents = [
    {
      'placeName': 'Al-Aqsa Mosque',
      'startTime': '06:00',
      'endTime': '08:00',
      'activityList': [
        {
          'title': 'Praying at Al-Aqsa',
          'description':
              'Praying at Al-Aqsa Mosque and making a tour at the museum.'
        },
      ],
      'imagePath': 'assets/Images/Profiles/Tourist/1T.png'
    },
    {
      'placeName': 'The old Town',
      'startTime': '08:30',
      'endTime': '10:30',
      'activityList': [
        {
          'title': 'Falafel Restaurant',
          'description':
              'Eating breakfast at Al-Quds traditional falafel Restaurant.'
        },
        {
          'title': 'Tour in the Souq',
          'description':
              'Making a tour and buying from the traditional souq of Al-Quds.'
        },
      ],
      'imagePath': 'assets/Images/Profiles/Tourist/2T.jpg'
    },
    {
      'placeName': 'Sepulchre Church',
      'startTime': '11:00',
      'endTime': '13:00',
      'activityList': [
        {
          'title': 'Explore the Chapels',
          'description':
              'Explore these chapels, each with its unique details and history.'
        },
        {
          'title': 'Learn about the History',
          'description':
              'Take the time to learn about the rich history of the church.'
        },
        {
          'title': 'Learn about the History',
          'description':
              'Take the time to learn about the rich history of the church.'
        },
      ],
      'imagePath': 'assets/Images/Profiles/Tourist/3T.jpg'
    },
  ];

  // A function to delete a specific plan.
  Future<void> deletePlan(int planId) async {
    final url = Uri.parse('https://touristine.onrender.com/deleteplan/$planId');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        // Success.
        // Israa, show a message.
      } else {
        print('Failed to delete the plan. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error deleting the plan: $error');
    }
  }

  // A function to fetch a specific plan.
  Future<void> fetchPlanContents(int planId) async {
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
          'planID': planId.toString(),
        },
      );

      if (response.statusCode == 200) {
        // Success.
        // Jenan, return back to me the contents of the plan as List<Map<String, dynamic>>
        // similar to the format shown at line 18 for the planContents list.
        // Note: other data such as lat and long for the places included in the plan 
        // might be added later, I will keep you updated if I will add them.
      } else {
        // Handle other cases....
        print('Failed to fetch the plan. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching the plan: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userPlans.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 80),
            Image.asset(
              'assets/Images/Profiles/Tourist/NoComplaints.gif',
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
            onTap: () {
              // print(plan['places']);
              // Handle the card click event.......................
              print(plan['planID']);

              print('Card clicked: ${plan['destName']}');
              fetchPlanContents(plan['planID']);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PlanPlacesPage(
                    planContents: planContents,
                  ),
                ),
              );
            },
            onDelete: () async {
              print(plan['planID']);
              await deletePlan(plan['planID']);
              setState(() {
                widget.userPlans.removeAt(index);
              });
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 140),
                      child: Text(
                        plan['destName'],
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Zilla',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: GestureDetector(
                        onTap: onDelete,
                        child: const FaIcon(
                          FontAwesomeIcons.xmark,
                          color: Color(0xFF1E889E),
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
                          child: Image.asset(
                            plan['imagePath'],
                            height: 195,
                            width: 160,
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
                            padding: const EdgeInsets.only(left: 10.0),
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
                            padding: const EdgeInsets.only(left: 10.0),
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
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              '${plan['startTime']} - ${plan['endTime']}',
                              style: const TextStyle(
                                fontSize: 23,
                                fontFamily: 'Times New Roman',
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              plan['date'],
                              style: const TextStyle(
                                fontSize: 23,
                                fontFamily: 'Times New Roman',
                              ),
                            ),
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
