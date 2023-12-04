import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:touristine/Profiles/Tourist/MainPages/DestinationUpload/destGenerator.dart';
import 'package:touristine/Profiles/Tourist/MainPages/DestinationUpload/myDestsList.dart';

class DestsUploadHomePage extends StatefulWidget {
  final String token;

  const DestsUploadHomePage({super.key, required this.token});

  @override
  _DestsUploadHomePageState createState() => _DestsUploadHomePageState();
}

class _DestsUploadHomePageState extends State<DestsUploadHomePage> {
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
        // Jenan, I need to retrieve a list of uploaded destinations in the following format:
        /*
        final List<Map<String, dynamic>> destinations = [
          {
            'destID': 1,
            'date': '07/10/2023',
            'destinationName': 'Al-Aqsa Mosque',
            'category': 'Religious Landmarks',
            'budget': 'Mid-Range',
            'timeToSpend': '12h and 30 min',
            'sheltered': true, // or false
            'status': 'Seen', // or Unseen
            'about':
                'It is situated in the heart of the Old City of Jerusalem, is one of the holiest sites in Islam.',
            'imagesURLs': [
              'assets/Images/Profiles/Tourist/1T.png',
              'assets/Images/Profiles/Tourist/11T.jpg',
              'assets/Images/Profiles/Tourist/10T.jpg'
            ],
            // If the status of the uploaded dest is unseen, by default there
            // won't be an admin comment, so don't send this field in such cases.
            'adminComment': "This destination already exists."
          },
          ///////////////Other destinations.
        ]; 
        */
      } else {
        // Handle other possible cases.
      }
    } catch (error) {
      print('Error fetching uploaded dests: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUploadedDests();
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
                      DestinationCardGenerator(
                          token: widget.token, uploadedDestinations: []),
                      // The list of uplaoded destinations must be passed.
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
