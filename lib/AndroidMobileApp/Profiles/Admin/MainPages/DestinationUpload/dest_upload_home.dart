import 'package:touristine/AndroidMobileApp/Profiles/Admin/MainPages/DestinationUpload/dest_generator.dart';
import 'package:touristine/AndroidMobileApp/Profiles/Admin/MainPages/DestinationUpload/my_dests_list.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:async';

// ignore: must_be_immutable
class DestsUploadHomePage extends StatefulWidget {
  final String token;
  Map<String, dynamic> destinationToBeAdded;
  DestsUploadHomePage(
      {super.key, required this.token, this.destinationToBeAdded = const {}});

  @override
  _DestsUploadHomePageState createState() => _DestsUploadHomePageState();
}

class _DestsUploadHomePageState extends State<DestsUploadHomePage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  Map<String, dynamic> destinationToBeAddedInfo = {};

  // Callback function to be passed to AddedDestinationsPage.
  void updateDestinationInfo(Map<String, dynamic> destinationInfo) {
    setState(() {
      destinationToBeAddedInfo = destinationInfo;
      // print(destinationToBeAddedInfo);
    });
    // Using a Timer to delay the tab switching.
    Timer(const Duration(milliseconds: 100), () {
      tabController.animateTo(0); // 0 is the index of the AddDestTab.
    });
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabController.index = 0; // Set the initial tab index to 0 (AddDestTab).
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
                  child: TabBar(
                    controller: tabController,
                    unselectedLabelColor: const Color(0xFF1E889E),
                    tabs: const [
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
                    indicator: const BoxDecoration(
                      color: Color(0xFF1E889E),
                    ),
                    labelStyle: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Times New Roman',
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      AddDestTab(
                          token: widget.token,
                          destinationToBeAdded: destinationToBeAddedInfo),
                      AddedDestinationsPage(
                          token: widget.token,
                          onDestinationEdit: updateDestinationInfo),
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
