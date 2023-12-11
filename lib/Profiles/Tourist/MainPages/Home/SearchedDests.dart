import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:touristine/Notifications/SnackBar.dart';
import 'destinationView.dart';

class SearchedDestinations extends StatefulWidget {
  final String token;
  final List<Map<String, dynamic>> destinationsList;

  const SearchedDestinations(
      {super.key, required this.token, required this.destinationsList});

  @override
  _SearchedDestinationsState createState() => _SearchedDestinationsState();
}

class _SearchedDestinationsState extends State<SearchedDestinations> {
  ScrollController scrollController = ScrollController();

  Map<String, dynamic> destinationDetails = {};
  List<Map<String, dynamic>> destinationImages = [];
  Map<String, int> ratings = {};
  Map<String, bool> isLoadingMap = {};

  // A function to retrieve all of the destination details.
  Future<void> getDestinationDetails(String destName) async {
    final url =
        Uri.parse('https://touristine.onrender.com/get-destination-details');

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
      print('Failed to fetch place details: $error');
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
      body: Builder(
        builder: (context) {
          if (widget.destinationsList.isEmpty) {
            return Center(
              child: Column(
                children: [
                  const SizedBox(height: 150),
                  Image.asset(
                    'assets/Images/Profiles/Tourist/emptyListTransparent.gif',
                    fit: BoxFit.cover,
                  ),
                  const Text(
                    'No results found',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Gabriola',
                      color: Color.fromARGB(255, 23, 99, 114),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/Images/Profiles/Tourist/homeBackground.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: widget.destinationsList.length > 5
                    ? Scrollbar(
                        thickness: 5,
                        trackVisibility: true,
                        thumbVisibility: true,
                        controller: scrollController,
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: widget.destinationsList.length,
                          itemBuilder: (BuildContext context, int index) {
                            final destinationName =
                                widget.destinationsList[index]['name'];
                            return Stack(
                              children: [
                                buildPlaceTile(
                                  destinationName,
                                  widget.destinationsList[index]['imagePath'],
                                  () async {
                                    setState(() {
                                      isLoadingMap[destinationName] = true;
                                    });
                                    await getDestinationDetails(
                                        destinationName);
                                    setState(() {
                                      isLoadingMap[destinationName] = false;
                                    });
                                    // ignore: use_build_context_synchronously
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DestinationDetails(
                                          destination:
                                              widget.destinationsList[index],
                                          token: widget.token,
                                          destinationDetails:
                                              destinationDetails,
                                          destinationImages: destinationImages,
                                          ratings: ratings,
                                        ),
                                      ),
                                    );
                                    print(
                                        'Tapped on ${widget.destinationsList[index]['name']}');
                                  },
                                  isLoadingMap[destinationName] ?? false,
                                ),
                              ],
                            );
                          },
                        ),
                      )
                    : ListView.builder(
                        itemCount: widget.destinationsList.length,
                        itemBuilder: (BuildContext context, int index) {
                          final destinationName =
                              widget.destinationsList[index]['name'];
                          return Stack(
                            children: [
                              buildPlaceTile(
                                destinationName,
                                widget.destinationsList[index]['imagePath'],
                                () async {
                                  setState(() {
                                    isLoadingMap[destinationName] = true;
                                  });
                                  await getDestinationDetails(destinationName);
                                  setState(() {
                                    isLoadingMap[destinationName] = false;
                                  });
                                  // ignore: use_build_context_synchronously
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DestinationDetails(
                                        destination:
                                            widget.destinationsList[index],
                                        token: widget.token,
                                        destinationDetails: destinationDetails,
                                        destinationImages: destinationImages,
                                        ratings: ratings,
                                      ),
                                    ),
                                  );
                                  print(
                                      'Tapped on ${widget.destinationsList[index]['name']}');
                                },
                                isLoadingMap[destinationName] ?? false,
                              ),
                            ],
                          );
                        },
                      ),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'BackToHome',
        onPressed: () {
          Navigator.of(context).pop();
        },
        backgroundColor: const Color(0xFF1E889E),
        elevation: 0,
        child: const Icon(FontAwesomeIcons.arrowLeft),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}

// A Function to build a profile tile with a title, image, and onTap action.
Widget buildPlaceTile(
    String title, String imagePath, VoidCallback onTapAction, bool isLoading) {
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
      child: Stack(
        children: [
          ListTile(
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
                        width: 140,
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
          // Circular progress indicator.
          if (isLoading)
            const Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E889E)),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
