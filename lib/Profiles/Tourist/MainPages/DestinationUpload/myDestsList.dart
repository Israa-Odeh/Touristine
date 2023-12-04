import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

class DestinationCardGenerator extends StatefulWidget {
  final String token;
  final List<Map<String, dynamic>> uploadedDestinations;

  const DestinationCardGenerator(
      {super.key, required this.token, required this.uploadedDestinations});

  @override
  _DestinationCardGeneratorState createState() =>
      _DestinationCardGeneratorState();
}

class _DestinationCardGeneratorState extends State<DestinationCardGenerator> {
  final List<Map<String, dynamic>> destinations = [
    {
      'destID': 1,
      'date': '07/10/2023',
      'destinationName': 'Al-Aqsa Mosque',
      'category': 'Religious Landmarks',
      'budget': 'Budget-Friendly',
      'timeToSpend': '12h and 30 min',
      'sheltered': true,
      'status': 'Seen',
      'about':
          'It is situated in the heart of the Old City of Jerusalem, is one of the holiest sites in Islam.',
      'imagesURLs': [
        'assets/Images/Profiles/Tourist/1T.png',
        'assets/Images/Profiles/Tourist/11T.jpg',
        'assets/Images/Profiles/Tourist/10T.jpg'
      ],
      'adminComment': "This destination already exists."
    },
    {
      'destID': 2,
      'date': '07/10/2023',
      'destinationName': 'Al-Aqsa Mosque',
      'category': 'Religious Landmarks',
      'budget': 'Mid-Range',
      'timeToSpend': '12h and 30 min',
      'sheltered': true,
      'status': 'Unseen',
      'about':
          'It is situated in the heart of the Old City of Jerusalem, is one of the holiest sites in Islam.',
      'imagesURLs': [
        'assets/Images/Profiles/Tourist/1T.png',
        'assets/Images/Profiles/Tourist/11T.jpg',
        'assets/Images/Profiles/Tourist/10T.jpg'
      ],
    },
    {
      'destID': 3,
      'date': '07/10/2023',
      'destinationName': 'Al-Aqsa Mosque',
      'category': 'Religious Landmarks',
      'budget': 'Mid-Range',
      'timeToSpend': '12h and 30 min',
      'sheltered': true,
      'status': 'Seen',
      'about':
          'It is situated in the heart of the Old City of Jerusalem, is one of the holiest sites in Islam.',
      'imagesURLs': [
        'assets/Images/Profiles/Tourist/1T.png',
        'assets/Images/Profiles/Tourist/11T.jpg',
        'assets/Images/Profiles/Tourist/10T.jpg'
      ],
      'adminComment': "This destination already exists."
    },
  ];

  @override
  Widget build(BuildContext context) {
    ScrollController pageScrollController = ScrollController();

    return destinations.length > 1
        ? ScrollbarTheme(
            data: ScrollbarThemeData(
              thumbColor: MaterialStateProperty.all(const Color(0xFF1E889E)),
              radius: const Radius.circular(0),
            ),
            child: Scrollbar(
              thumbVisibility: true,
              trackVisibility: true,
              thickness: 6.0,
              controller: pageScrollController,
              child: ListView.builder(
                controller: pageScrollController,
                itemCount: destinations.length,
                itemBuilder: (context, index) {
                  return DestinationCard(
                    token: widget.token,
                    destination: destinations[index],
                    onDelete: () {
                      setState(() {
                        destinations.removeAt(index);
                      });
                    },
                  );
                },
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: ListView.builder(
              itemCount: destinations.length,
              itemBuilder: (context, index) {
                return DestinationCard(
                  token: widget.token,
                  destination: destinations[index],
                  onDelete: () {
                    setState(() {
                      destinations.removeAt(index);
                    });
                  },
                );
              },
            ),
          );
  }
}

class DestinationCard extends StatefulWidget {
  final String token;

  final Map<String, dynamic> destination;
  final VoidCallback onDelete;

  const DestinationCard(
      {super.key,
      required this.token,
      required this.destination,
      required this.onDelete});

  @override
  _DestinationCardState createState() => _DestinationCardState();
}

class _DestinationCardState extends State<DestinationCard> {
  final ScrollController imagesScrollController = ScrollController();
  final ScrollController aboutScrollController = ScrollController();

  // A function to delete a specific destination.
  Future<void> deleteDestination(int destID) async {
    final url =
        Uri.parse('https://touristine.onrender.com/deletedestination/$destID');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        // Success.
        // Israa, show a message.
        // Israa, here the card should be deleted from the whole widget.
      } else {
        // Israa, Handle other possible cases....
        print(
            'Failed to delete the destination. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error deleting the destination: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: const BorderSide(
          color: Color.fromARGB(80, 0, 0, 0),
          width: 2.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status icon and button row.
            Container(
              height: 55,
              color: const Color.fromARGB(94, 195, 195, 195),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          widget.destination['status'].toLowerCase() == "seen"
                              ? FontAwesomeIcons.circleCheck
                              : FontAwesomeIcons.circleXmark,
                          color: const Color(0xFF7F7F7F),
                          size: 23,
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          widget.destination['status'],
                          style: const TextStyle(
                              color: Color(0xFF7F7F7F),
                              fontFamily: 'Calibri',
                              fontWeight: FontWeight.bold,
                              fontSize: 25),
                        ),
                      ],
                    ),
                    Visibility(
                      visible:
                          widget.destination['status'].toLowerCase() == "seen",
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            showCommentDialog(
                                widget.destination['adminComment']);
                          },
                          borderRadius: BorderRadius.circular(100.0),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 0.0),
                            child: Visibility(
                              visible: widget.destination['adminComment'] != "",
                              child: Image.asset(
                                  'assets/Images/Profiles/Tourist/DestUpload/adminIcon.png',
                                  color: Colors.black,
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Horizontal ListView of images.
            SizedBox(
              height: 220,
              child: Scrollbar(
                trackVisibility: true,
                thumbVisibility: true,
                thickness: 5,
                controller: imagesScrollController,
                child: ListView.builder(
                  controller: imagesScrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.destination['imagesURLs'].length,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 400,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Image.asset(
                          widget.destination['imagesURLs'][index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Destination name and category row.
            Padding(
              padding:
                  const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.destination['destinationName'] ?? '',
                    style: const TextStyle(
                        color: Color.fromARGB(255, 12, 53, 61),
                        fontFamily: 'Zilla Slab Light',
                        fontWeight: FontWeight.bold,
                        fontSize: 24),
                  ),
                  Text(
                    widget.destination['category'] ?? '',
                    style: const TextStyle(
                        color: Color.fromARGB(255, 12, 53, 61),
                        fontFamily: 'Zilla Slab Light',
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ],
              ),
            ),
            // Divider.
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child:
                  Divider(thickness: 3, color: Color.fromARGB(80, 19, 83, 96)),
            ),
            // About destination text.
            Scrollbar(
              thickness: 5.0,
              thumbVisibility: true,
              trackVisibility: true,
              controller: aboutScrollController,
              child: SizedBox(
                height: 130.0,
                child: SingleChildScrollView(
                  controller: aboutScrollController,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 8),
                    child: Text(
                      widget.destination['about'] ?? '',
                      style: const TextStyle(
                        fontFamily: 'Andalus',
                        color: Color(0xFF595959),
                        fontSize: 25,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Divider.
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Divider(thickness: 2.0, color: Color(0xFFbfbfbf)),
            ),
            // Budget and sheltered status row.
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.destination['budget'] ?? '',
                    style: const TextStyle(fontFamily: 'Calibri', fontSize: 20),
                  ),
                  Text(
                      widget.destination['sheltered'] == true
                          ? 'Sheltered'
                          : 'Unsheltered',
                      style:
                          const TextStyle(fontFamily: 'Calibri', fontSize: 20)),
                ],
              ),
            ),
            // Divider.
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Divider(thickness: 2.0, color: Color(0xFFbfbfbf)),
            ),
            // Time to spend and date row.
            Padding(
              padding: widget.destination['status'].toLowerCase() == "seen"
                  ? const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10)
                  : const EdgeInsets.only(
                      left: 15.0, right: 15, top: 10, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.destination['timeToSpend'] ?? '',
                      style:
                          const TextStyle(fontFamily: 'Calibri', fontSize: 20)),
                  Text(widget.destination['date'] ?? '',
                      style:
                          const TextStyle(fontFamily: 'Calibri', fontSize: 20)),
                ],
              ),
            ),
            // Container with icon button.
            Visibility(
              visible: widget.destination['status'].toLowerCase() == "seen",
              child: Container(
                color: const Color.fromARGB(94, 195, 195, 195),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            print(widget.destination['destID']);
                            await deleteDestination(
                                widget.destination['destID']);
                            // This will be called only if the deletion process succeeded.
                            widget.onDelete();
                          },
                          borderRadius: BorderRadius.circular(30.0),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10),
                            child: FaIcon(
                              FontAwesomeIcons.solidTrashCan,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showCommentDialog(String comment) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Admin Comment',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontFamily: 'Gabriola',
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 18, 84, 97),
                  ),
                ),
                const Divider(
                    thickness: 1, color: Color.fromARGB(255, 16, 73, 85)),
                const SizedBox(height: 10.0),
                Text(
                  comment,
                  style: const TextStyle(
                    fontSize: 22.0,
                    fontFamily: 'Zilla Slab Light',
                    color: Color.fromARGB(255, 18, 84, 97),
                  ),
                ),
                const SizedBox(height: 20.0),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 22.0,
                        fontFamily: 'Zilla',
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 214, 61, 27),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
