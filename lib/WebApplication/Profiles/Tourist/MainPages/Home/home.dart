import 'package:touristine/WebApplication/Profiles/Tourist/MainPages/Home/destination_view.dart';
import 'package:touristine/WebApplication/Profiles/Tourist/MainPages/Home/destinations.dart';
import 'package:touristine/WebApplication/Notifications/snack_bar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  final String token;
  final List<Map<String, dynamic>> recommendedDestinations;
  final List<Map<String, dynamic>> popularDestinations;
  final List<Map<String, dynamic>> otherDestinations;

  const HomePage(
      {super.key,
      required this.token,
      required this.recommendedDestinations,
      required this.popularDestinations,
      required this.otherDestinations});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic> destinationDetails = {};
  List<Map<String, dynamic>> destinationImages = [];
  Map<String, int> ratings = {};
  bool isLoadingPlaceDetails = false;
  int selectedPlaceIndex = -1;

  @override
  void initState() {
    super.initState();
  }

  // A function to retrieve all of the destination details.
  Future<void> getDestinationDetails(String destName) async {
    final url =
        Uri.parse('https://touristine.onrender.com/get-destination-details');

    try {
      if (mounted) {
        setState(() {
          isLoadingPlaceDetails = true;
        });
      }

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
      if (mounted) {
        setState(() {
          isLoadingPlaceDetails = false;
        });
      }

      if (response.statusCode == 200) {
        // Success.
        // Parse the response body.
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Extract destinationImages as List<Map<String, dynamic>>
        destinationImages =
            List<Map<String, dynamic>>.from(responseData['destinationImages']);

        // Access destination details and other data.
        destinationDetails = responseData['destinationDetails'];
        ratings = Map<String, int>.from(responseData['rating']);

        // Now you can use the data as needed
        print('Destination Images: $destinationImages');
        print('Destination Details: $destinationDetails');
        print('Rating: $ratings');
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('error')) {
          if (responseData['error'] ==
              'Details for this destination are not available') {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, 'Place details aren\'t available',
                bottomMargin: 0);
          } else {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
          }
        }
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Error retrieving place details',
            bottomMargin: 0);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          isLoadingPlaceDetails = false;
        });
      }
      print('Failed to fetch place details: $error');
    }
  }

  // A Function to build a profile tile with a title, image, and onTap action.
  Widget buildPlaceTile(
      String title, String imagePath, VoidCallback onTapAction) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 240),
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
                  padding: const EdgeInsets.only(right: 15),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      imagePath,
                      width: 300,
                      height: 200,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontFamily: 'Zilla',
                        color: Color.fromARGB(227, 245, 243, 243),
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
                fit: BoxFit.fill,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              controller: ScrollController(),
              child: Column(
                children: [
                  // Special For You Section.
                  DestinationList(
                    destinations: widget.recommendedDestinations,
                    listTitle: 'Special Places For You',
                    token: widget.token,
                  ),
                  const SizedBox(height: 20),
                  // Popular Places Section.
                  DestinationList(
                    destinations: widget.popularDestinations,
                    listTitle: 'Popular Places',
                    token: widget.token,
                  ),

                  // Other Places Section.
                  const SizedBox(height: 30),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 100.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Color(0xFF1E889E),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            "Other Places",
                            style: TextStyle(
                              fontSize: 34,
                              fontFamily: 'Gabriola',
                              color: Color(0xFF1E889E),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Color(0xFF1E889E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Adding others section using a loop.
                  for (var index = 0;
                      index < widget.otherDestinations.length;
                      index++)
                    Stack(
                      children: [
                        Column(
                          children: [
                            buildPlaceTile(
                              widget.otherDestinations[index]['name'],
                              widget.otherDestinations[index]['image'],
                              () async {
                                print(widget.otherDestinations[index]['name']);
                                setState(() {
                                  selectedPlaceIndex = index;
                                });

                                await getDestinationDetails(
                                    widget.otherDestinations[index]['name']);

                                // ignore: use_build_context_synchronously
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DestinationDetails(
                                      destination:
                                          widget.otherDestinations[index],
                                      token: widget.token,
                                      destinationDetails: destinationDetails,
                                      destinationImages: destinationImages,
                                      ratings: ratings,
                                    ),
                                  ),
                                ).then((value) {
                                  setState(() {
                                    selectedPlaceIndex = -1;
                                  });
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                        if (selectedPlaceIndex == index)
                          if (isLoadingPlaceDetails)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 80.0),
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF1E889E)),
                                ),
                              ),
                            ),
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
