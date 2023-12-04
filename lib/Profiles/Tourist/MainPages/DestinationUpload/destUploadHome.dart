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
  
    // A Function to fetch user plans from the backend.
  Future<void> fetchUserDests() async {
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
        // Jenan, I need to retrieve a list of..........to be added later on.
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
    fetchUserDests();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors
            .transparent,
        appBar: PreferredSize(
          preferredSize:
              const Size.fromHeight(30),
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
                      DestinationCardGenerator(token: widget.token, uploadedDestinations: []),
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
