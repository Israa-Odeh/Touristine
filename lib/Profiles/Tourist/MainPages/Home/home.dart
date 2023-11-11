import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:touristine/Profiles/Tourist/MainPages/Home/destination.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final String token;

  const HomePage({super.key, required this.token});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // A list of recommended destinations. (Testing Sample)
  final List<Map<String, dynamic>> recommended = [
    {
      'name': 'Gaza',
      'image': 'assets/Images/Profiles/Tourist/3T.jpg',
    },
    {
      'name': 'Jerusalem',
      'image': 'assets/Images/Profiles/Tourist/1T.png',
    },
    {
      'name': 'Nablus',
      'image': 'assets/Images/Profiles/Tourist/2T.jpg',
    },
    {
      'name': 'Ramallah',
      'image': 'assets/Images/Profiles/Tourist/4T.jpg',
    },
    // Add more destinations as needed
  ];

  // A list of popular destinations. (Testing Sample)
  final List<Map<String, dynamic>> popular = [
    {
      'name': 'Jenin',
      'image': 'assets/Images/Profiles/Tourist/5T.jpg',
    },
    {
      'name': 'Bethlehem',
      'image': 'assets/Images/Profiles/Tourist/8T.jpg',
    },
    {
      'name': 'Jericho',
      'image': 'assets/Images/Profiles/Tourist/7T.jpg',
    },
    {
      'name': 'Tulkarm',
      'image': 'assets/Images/Profiles/Tourist/6T.jpg',
    },
    // Add more destinations as needed
  ];

  // A list of other destinations. (Testing Smaple)
  final List<Map<String, dynamic>> others = [
    {
      'name': 'Hebron',
      'imagePath': 'assets/Images/Profiles/Tourist/9T.jpg',
    },
    {
      'name': 'Dead Sea',
      'imagePath': 'assets/Images/Profiles/Tourist/10T.jpg',
    },
    {
      'name': 'Garden Cafe',
      'imagePath': 'assets/Images/Profiles/Tourist/11T.jpg',
    },
    {
      'name': 'Sufi Cafe',
      'imagePath': 'assets/Images/Profiles/Tourist/12T.jpg',
    },
  ];

  // Lists containing destinations retrieved from the DB: recommended, popular, and others.
  List<Map<String, dynamic>> recommendedDestinations = [];
  List<Map<String, dynamic>> popularDestinations = [];
  List<Map<String, dynamic>> otherDestinations = [];

  @override
  void initState() {
    super.initState();
    // Uncomment these when functions are complete.
    // getRecommendedDestinations();
    // getPopularDestinations();
    // getOtherDestinations();
  }

  // A function to retrieve a list of recommended destinations.
  Future<void> getRecommendedDestinations() async {
    final url =
        Uri.parse('https://touristine.onrender.com/getRecommendedDestinations');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        // Success.
        // I need the "names" of the destinations along with their
        // corresponding "image paths" --> List<Map<String, dynamic>>.
      } else if (response.statusCode == 500) {
        // Failed.
      } else {
        // ignore: use_build_context_synchronously
        // showCustomSnackBar(context, "Failed to fetch recommendations",
        //     bottomMargin: 0);
      }
    } catch (error) {
      print('Failed to fetch recommendations: $error');
    }
  }

  // A function to fetch popular destinations from the database.
  Future<void> getPopularDestinations() async {
    final url =
        Uri.parse('https://touristine.onrender.com/getPopularDestinations');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        // Success.
        // I need the "names" of the destinations along with their
        // corresponding "image paths" --> List<Map<String, dynamic>>.
      } else if (response.statusCode == 500) {
        // Failed.
      } else {
        // ignore: use_build_context_synchronously
        // showCustomSnackBar(context, "Failed to fetch data",
        //     bottomMargin: 0);
      }
    } catch (error) {
      print('Failed to fetch data: $error');
    }
  }

  // A function to fetch other destinations from the database.
  Future<void> getOtherDestinations() async {
    final url =
        Uri.parse('https://touristine.onrender.com/getOtherDestinations');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        // Success.
        // I need the "names" of the destinations along with their
        // corresponding "image paths" --> List<Map<String, dynamic>>.
      } else if (response.statusCode == 500) {
        // Failed.
      } else {
        // ignore: use_build_context_synchronously
        // showCustomSnackBar(context, "Failed to fetch data",
        //     bottomMargin: 0);
      }
    } catch (error) {
      print('Failed to fetch data: $error');
    }
  }

  // A Function to build a search box.
  Widget buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E889E),
          borderRadius: BorderRadius.circular(50),
        ),
        child: ListTile(
          tileColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          onTap: () {
            showSearch(context: context, delegate: CustomSearchDelegate());
          },
          title: Container(
            padding:
                const EdgeInsets.only(top: 13, bottom: 13, right: 18, left: 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.only(right: 15),
                  child: const Icon(
                    FontAwesomeIcons.magnifyingGlass,
                    color: Color.fromARGB(255, 252, 252, 252),
                  ),
                ),
                const Expanded(
                  child: Text(
                    "Search Places",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 255, 255, 255),
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

  // A Function to build a profile tile with a title, image, and onTap action.
  Widget buildPlaceTile(
      String title, String imagePath, VoidCallback onTapAction) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Card(
        color: const Color.fromARGB(71, 111, 228, 252),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            color: Color(0xFF1E889E),
            width: 4,
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
                      width: 190,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 30,
                        fontFamily: 'Zilla',
                        color: Color.fromARGB(255, 245, 243, 243),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image.
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/Images/Profiles/Tourist/homeBackground.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Search Box on top of the background.
          Container(
            margin: const EdgeInsets.only(top: 50),
            child: buildSearchBox(),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 115.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  // Special For You Section.
                  DestinationList(
                    destinations:
                        recommended, // Israa, replace this with the list retreived from backend.
                    listTitle: 'Special For You',
                  ),
                  // Popular Places Section.
                  DestinationList(
                    destinations:
                        popular, // Israa, replace this with the list retreived from backend.
                    listTitle: 'Popular Places',
                  ),

                  // Other Places Section.
                   const SizedBox(
                    height: 20,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 220),
                    child: Text(
                      "Other Places",
                      style: TextStyle(
                        fontSize: 38,
                        fontFamily: 'Gabriola',
                        color: Color(0xFF1E889E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Adding others section using a loop.
                  for (var place in others) // Israa, replace this with the list retreived from backend.
                    Column(
                      children: [
                        buildPlaceTile(
                          place['name'],
                          place['imagePath'],
                          () {},
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  // A list of search terms.
  List<String> searchTerms = [
    'Gaza',
    'Jenin',
    'Nablus',
    'Ramallah',
    'Tulkarm',
    'Hebron',
    'Jericho',
    'Bethlehem',
    'Jerusalem',
  ];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const FaIcon(FontAwesomeIcons.xmark),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const FaIcon(FontAwesomeIcons.arrowLeft),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var location in searchTerms) {
      if (location.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(location);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var location in searchTerms) {
      if (location.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(location);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }
}
