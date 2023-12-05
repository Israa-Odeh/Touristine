import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SearchedDestinations extends StatefulWidget {
  final String token;
  final Map<String, dynamic> destinationsList;

  const SearchedDestinations(
      {super.key, required this.token, required this.destinationsList});

  @override
  _SearchedDestinationsState createState() => _SearchedDestinationsState();
}

class _SearchedDestinationsState extends State<SearchedDestinations> {
  ScrollController scrollController = ScrollController();

  final List<Map<String, dynamic>> destinationsList = [
    {
      'name': 'Gaza Mosque',
      'imagePath': 'assets/Images/Profiles/Tourist/3T.jpg',
    },
    {
      'name': 'Al-Aqsa Mosque',
      'imagePath': 'assets/Images/Profiles/Tourist/1T.png',
    },
    {
      'name': 'Nablus Mountain',
      'imagePath': 'assets/Images/Profiles/Tourist/2T.jpg',
    },
    {
      'name': 'Rawabi Theater',
      'imagePath': 'assets/Images/Profiles/Tourist/4T.jpg',
    }
  ];

  // A function to retrieve all of the destination details.
  Future<void> getDestinationDetails(String destName) async {
    final url =
        Uri.parse('https://touristine.onrender.com/getDestinationDetails');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {
          'destinationName': destName,
        },
      );

      if (response.statusCode == 200) {
        // Success.
      } else if (response.statusCode == 500) {
        // Failed.
      } else {}
    } catch (error) {
      print('Failed to fetch destination details: $error');
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'assets/Images/Profiles/Tourist/homeBackground.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: destinationsList.length > 5
              ? Scrollbar(
                  thickness: 5,
                  trackVisibility: true,
                  thumbVisibility: true,
                  controller: scrollController,
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: destinationsList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return buildPlaceTile(
                        destinationsList[index]['name'],
                        destinationsList[index]['imagePath'],
                        () {
                          // Add your onTap logic here
                          print('Tapped on ${destinationsList[index]['name']}');
                          // getDestinationDetails(destinationsList[index]['name']);
                        },
                      );
                    },
                  ),
                )
              : ListView.builder(
                  itemCount: destinationsList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return buildPlaceTile(
                      destinationsList[index]['name'],
                      destinationsList[index]['imagePath'],
                      () {
                        // Add your onTap logic here
                        print('Tapped on ${destinationsList[index]['name']}');
                        // getDestinationDetails(destinationsList[index]['name']);
                      },
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'BackToHome',
        onPressed: () {
          Navigator.of(context).pop();
        },
        backgroundColor: const Color.fromARGB(165, 30, 137, 158),
        elevation: 0,
        child: const Icon(FontAwesomeIcons.arrowLeft),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}

// A Function to build a profile tile with a title, image, and onTap action.
Widget buildPlaceTile(
    String title, String imagePath, VoidCallback onTapAction) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Card(
      color: const Color.fromARGB(21, 4, 208, 249),
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          color: Color(0xFF1E889E),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: onTapAction,
        title: Container(
          padding: const EdgeInsets.only(
            left: 0,
            right: 25,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.only(right: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    imagePath,
                    width: 145,
                    height: 130,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 25,
                      fontFamily: 'Zilla',
                      color: Color.fromARGB(159, 0, 0, 0),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
