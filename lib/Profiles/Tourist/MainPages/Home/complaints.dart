import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

class ComplaintsListPage extends StatefulWidget {
  final String token;
  final String destinationName;

  const ComplaintsListPage(
      {Key? key, required this.token, required this.destinationName})
      : super(key: key);

  @override
  _ComplaintsListPageState createState() => _ComplaintsListPageState();
}

class _ComplaintsListPageState extends State<ComplaintsListPage> {
  // List<Map<String, dynamic>> complaints = [];
  List<Map<String, dynamic>> complaints = [
    {
      'title': 'Slow Service',
      'content': 'The service at the restaurant was incredibly slow.',
      'date': '25/10/2019',
      'images': [
        {
          'url':
              'https://cdn.britannica.com/84/73184-050-05ED59CB/Sunflower-field-Fargo-North-Dakota.jpg'
        },
        {
          'url':
              'https://cdn.britannica.com/89/131089-050-A4773446/flowers-garden-petunia.jpg'
        },
        {
          'url':
              'https://cdn.britannica.com/89/131089-050-A4773446/flowers-garden-petunia.jpg'
        },
      ],
    },
    {
      'title': 'Dirty Room',
      'content': 'The hotel room was not clean upon arrival.',
      'date': '15/05/2020',
      'images': [
        {
          'url':
              'https://www.petalrepublic.com/wp-content/uploads/2023/07/Heather.jpeg.webp'
        },
      ],
    },
    {
      'title': 'Dirty Room',
      'content': 'The hotel room was not clean upon arrival.',
      'date': '20/11/2022',
    },
    {
      'title': 'Noisy Environment',
      'content': 'The neighborhood was too noisy during the night.',
      'date': '17/09/2023',
    },
    // Add more complaint entries as needed for testing
  ];

  // Function to fetch user complaints from the backend.
  Future<void> fetchUserComplaints() async {
    final url = Uri.parse('https://touristine.onrender.com/get-complaints');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        // Parse the response JSON and update the complaints list.
        setState(() {
          complaints =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        // Handle error
        print(
            'Failed to fetch complaints. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching complaints: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserComplaints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image:
                AssetImage("assets/Images/Profiles/Tourist/homeBackground.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: complaints.isEmpty
                  ? const Center(child: Text('No complaints found.'))
                  : ListView.builder(
                      itemCount: complaints.length,
                      itemBuilder: (context, index) {
                        return ComplaintCard(complaint: complaints[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'GoBack',
        onPressed: () {
          Navigator.of(context).pop();
        },
        backgroundColor: const Color.fromARGB(129, 30, 137, 158),
        elevation: 0,
        child: const Icon(FontAwesomeIcons.arrowLeft),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}

class ComplaintCard extends StatelessWidget {
  final Map<String, dynamic> complaint;

  const ComplaintCard({Key? key, required this.complaint}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(right: 10, left: 10, bottom: 10),
      color: const Color.fromARGB(68, 30, 137, 158),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Content
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    complaint['title'],
                    style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Times New Roman',
                        color: Color.fromARGB(255, 21, 98, 113)),
                  ),
                  Text(
                    complaint['date'],
                    style: const TextStyle(
                        fontSize: 19.5,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Time New Roman',
                        color: Color.fromARGB(255, 14, 63, 73)),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(
                    color: Color.fromARGB(126, 14, 63, 73),
                    thickness: 2,
                  ),
                  Text(
                    complaint['content'],
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w100,
                        fontFamily: 'Zilla',
                        color: Color.fromARGB(255, 14, 63, 73)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Display images if available
            if (complaint['images'] != null &&
                (complaint['images'] as List).isNotEmpty)
              Container(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: (complaint['images'] as List).length,
                  itemBuilder: (context, imgIndex) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: Color.fromARGB(
                                121, 30, 137, 158), // Set border color
                            width: 3.0, // Set border width
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.network(
                            (complaint['images'] as List)[imgIndex]['url'],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
