import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

class ComplaintsListPage extends StatefulWidget {
  final String token;
  final String destinationName;
  final List<Map<String, dynamic>> complaints;

  const ComplaintsListPage(
      {super.key,
      required this.token,
      required this.destinationName,
      required this.complaints});

  @override
  _ComplaintsListPageState createState() => _ComplaintsListPageState();
}

class _ComplaintsListPageState extends State<ComplaintsListPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: widget.complaints.isNotEmpty? 0.0: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            image: widget.complaints.isNotEmpty
                ? const DecorationImage(
                    image: AssetImage(
                        "assets/Images/Profiles/Tourist/homeBackground.jpg"),
                    fit: BoxFit.cover,
                  )
                : const DecorationImage(
                    image: AssetImage(
                        "assets/Images/Profiles/Tourist/ComplaintsBackground.png"),
                    fit: BoxFit.cover,
                  ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: widget.complaints.isEmpty
                    ? Center(
                        child: Column(
                        children: [
                          const SizedBox(height: 150),
                          Image.asset(
                            'assets/Images/Profiles/Tourist/NoComplaints.gif',
                            fit: BoxFit.cover,
                          ),
                          const Text(
                            'No complaints found',
                            style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Gabriola',
                                color: Color.fromARGB(255, 23, 99, 114)),
                          ),
                        ],
                      ))
                    : ListView.builder(
                        itemCount: widget.complaints.length,
                        itemBuilder: (context, index) {
                          return ComplaintCard(
                              complaint: widget.complaints[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: widget.complaints.isNotEmpty? 0.0: 10.0),
        child: FloatingActionButton(
          heroTag: 'GoBack',
          onPressed: () {
            Navigator.of(context).pop();
          },
          backgroundColor: widget.complaints.isNotEmpty? const Color.fromARGB(129, 30, 137, 158): const Color(0xFF1E889E),
          elevation: 0,
          child: const Icon(FontAwesomeIcons.arrowLeft),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}

class ComplaintCard extends StatelessWidget {
  final Map<String, dynamic> complaint;

  const ComplaintCard({super.key, required this.complaint});

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
            // Display images if available.
            if (complaint['images'] != null &&
                (complaint['images'] as List).isNotEmpty)
              SizedBox(
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
                            color: const Color.fromARGB(121, 30, 137, 158),
                            width: 3.0,
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
