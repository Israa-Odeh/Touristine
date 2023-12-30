import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:touristine/Profiles/Admin/MainPages/DestinationUpload/destGenerator.dart';
import 'package:touristine/Profiles/Admin/MainPages/DestinationUpload/myDestsList.dart';

// ignore: must_be_immutable
class DestsUploadHomePage extends StatefulWidget {
  final String token;
  Map<String, dynamic> destinationToBeAdded;
  final Function(int, Map<String, dynamic>) editDestinationCallback;

  DestsUploadHomePage(
      {super.key,
      required this.token,
      this.destinationToBeAdded = const {},
      required this.editDestinationCallback});

  @override
  _DestsUploadHomePageState createState() => _DestsUploadHomePageState();
}

class _DestsUploadHomePageState extends State<DestsUploadHomePage> {
  Map<String, dynamic> destinationToBeAddedInfo = {};

  @override
  void initState() {
    super.initState();
    destinationToBeAddedInfo = widget.destinationToBeAdded;
    widget.destinationToBeAdded = {};
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
                      'assets/Images/Profiles/Admin/mainBackground.jpg'),
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
                          destinationToBeAdded: destinationToBeAddedInfo),
                      AddedDestinationsPage(
                          token: widget.token,
                          editDestinationCallback:
                              widget.editDestinationCallback),
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
