import 'package:touristine/AndroidMobileApp/Profiles/Tourist/MainPages/DestinationUpload/dest_generator.dart';
import 'package:touristine/AndroidMobileApp/Profiles/Tourist/MainPages/DestinationUpload/my_dests_list.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

class DestsUploadHomePage extends StatefulWidget {
  final String token;

  const DestsUploadHomePage({super.key, required this.token});

  @override
  _DestsUploadHomePageState createState() => _DestsUploadHomePageState();
}

class _DestsUploadHomePageState extends State<DestsUploadHomePage> {
  List<Map<String, dynamic>> uploadedDestinations = [];

  @override
  void initState() {
    super.initState();
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
                            SizedBox(width: 10),
                            Text(
                              'Suggest Place',
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
                            SizedBox(width: 10),
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
                      fontSize: 24,
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
                      DestinationCardGenerator(token: widget.token),
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
