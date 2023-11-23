import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

class MyPlansTab extends StatefulWidget {
  final String token;
  final List<Map<String, dynamic>> userPlans;

  const MyPlansTab({super.key, required this.token, required this.userPlans});

  @override
  _MyPlansTabState createState() => _MyPlansTabState();
}

class _MyPlansTabState extends State<MyPlansTab> {
  
  Future<void> deletePlan(int planId) async {
    final url = Uri.parse('https://touristine.onrender.com/plans/$planId');

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
              // Handle the card click event.......................
              print('Card clicked: ${plan['destName']}');
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
                            fit: BoxFit.cover,
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
