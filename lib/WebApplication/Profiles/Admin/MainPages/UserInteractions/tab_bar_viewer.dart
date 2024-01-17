import 'package:touristine/WebApplication/Profiles/Admin/MainPages/UserInteractions/suggested_places.dart';
import 'package:touristine/WebApplication/Profiles/Admin/MainPages/UserInteractions/user_interactions.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

class TabBarViewer extends StatefulWidget {
  final String token;
  final Function(int, Map<String, dynamic>) changeTabIndex;

  const TabBarViewer({
    super.key,
    required this.token,
    required this.changeTabIndex,
  });

  @override
  _TabBarViewerState createState() => _TabBarViewerState();
}

class _TabBarViewerState extends State<TabBarViewer> {
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
                            Icon(FontAwesomeIcons.star),
                            SizedBox(width: 15),
                            Text('Interactions'),
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
                            Text('Suggestions'),
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
                      UserInteractionsPage(token: widget.token),
                      SuggestedPlacesPage(
                        token: widget.token,
                        // changeTabIndex: widget.changeTabIndex,
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
