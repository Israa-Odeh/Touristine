import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:touristine/Notifications/SnackBar.dart';
import 'package:touristine/Profiles/Tourist/MainPages/DestinationUpload/destGenerator.dart';
import 'package:touristine/Profiles/Tourist/MainPages/DestinationUpload/myDestsList.dart';

class DestsUploadHomePage extends StatefulWidget {
  final String token;

  const DestsUploadHomePage({super.key, required this.token});

  @override
  _DestsUploadHomePageState createState() => _DestsUploadHomePageState();
}

class _DestsUploadHomePageState extends State<DestsUploadHomePage> {
  List<Map<String, dynamic>> uploadedDestinations = [];
  late Future<void> fetchUploadedDestsFuture;

  // A Function to fetch user uploaded destinations.
  Future<void> fetchUploadedDests() async {
    final url = Uri.parse('https://touristine.onrender.com/get-uploaded-dests');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        // Convert destinationsData into a list of maps.
        uploadedDestinations = responseData.map((destinationData) {
          return {
            'destID': destinationData['destID'],
            'date': destinationData['date'],
            'destinationName': destinationData['destinationName'],
            'city': destinationData['city'],
            'category': destinationData['category'],
            'budget': destinationData['budget'],
            'timeToSpend': destinationData['timeToSpend'],
            'sheltered': destinationData['sheltered'],
            'status': destinationData['status'],
            'about': destinationData['about'],
            'imagesURLs': destinationData['imagesURLs'],
            'adminComment': destinationData['adminComment'],
          };
        }).toList();
        print(uploadedDestinations);
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Error retrieving your places',
            bottomMargin: 0);
      }
    } catch (error) {
      print('Error fetching uploaded dests: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUploadedDestsFuture = fetchUploadedDests();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: AppBar(
            backgroundColor: const Color.fromARGB(255, 25, 113, 130),
            elevation: 0,
          ),
        ),
        body: Stack(
          children: [
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
                              'Add Place',
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
                              'My Places',
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
                      AddDestTab(
                        token: widget.token,
                      ),
                      FutureBuilder<void>(
                        future: fetchUploadedDestsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return DestinationCardGenerator(
                              token: widget.token,
                              uploadedDestinations: uploadedDestinations,
                            );
                          } else {
                            return const Center(
                                child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF1E889E)),
                            ));
                          }
                        },
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
