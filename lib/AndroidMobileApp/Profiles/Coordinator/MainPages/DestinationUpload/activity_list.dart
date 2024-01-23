import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ActivityListPage extends StatefulWidget {
  List<Map<String, String>> addedActivities;

  ActivityListPage({super.key, required this.addedActivities});
  @override
  _ActivityListPageState createState() => _ActivityListPageState();
}

class _ActivityListPageState extends State<ActivityListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding:
            EdgeInsets.only(top: widget.addedActivities.isNotEmpty ? 0.0 : 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            image: widget.addedActivities.isNotEmpty
                ? const DecorationImage(
                    image: AssetImage(
                        "assets/Images/Profiles/Admin/mainBackground.jpg"),
                    fit: BoxFit.cover,
                  )
                : const DecorationImage(
                    image: AssetImage(
                        "assets/Images/Profiles/Tourist/emptyListBackground.png"),
                    fit: BoxFit.cover,
                  ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: widget.addedActivities.isEmpty
                    ? Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 150),
                            Image.asset(
                              'assets/Images/Profiles/Tourist/emptyList.gif',
                              fit: BoxFit.cover,
                            ),
                            const Text(
                              'No activities found',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Gabriola',
                                color: Color.fromARGB(255, 23, 99, 114),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: widget.addedActivities.length,
                        itemBuilder: (context, index) {
                          return buildSingleActivity(
                            widget.addedActivities[index]['title'] ?? '',
                            widget.addedActivities[index]['description'] ?? '',
                            () {
                              setState(() {
                                widget.addedActivities.removeAt(index);
                              });
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
            bottom: widget.addedActivities.isNotEmpty ? 0.0 : 10.0),
        child: FloatingActionButton(
          heroTag: 'GoBack',
          onPressed: () {
            Navigator.of(context).pop();
          },
          backgroundColor: widget.addedActivities.isNotEmpty
              ? const Color.fromARGB(129, 30, 137, 158)
              : const Color(0xFF1E889E),
          elevation: 0,
          child: const FaIcon(FontAwesomeIcons.arrowLeft),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget buildSingleActivity(
    String title,
    String content,
    VoidCallback onDelete,
  ) {
    int? maxLines = title.length > 25 ? 5 : 2;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 120,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Times New Roman',
                      color: Color.fromARGB(255, 21, 98, 113),
                    ),
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.trash,
                    color: Color(0xFF1E889E),
                    size: 26,
                  ),
                  onPressed: onDelete,
                ),
              ],
            ),
            const Divider(
              color: Color.fromARGB(126, 14, 63, 73),
              thickness: 2,
            ),
            Text(
              content,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w100,
                fontFamily: 'Andalus',
                color: Color.fromARGB(255, 14, 63, 73),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
