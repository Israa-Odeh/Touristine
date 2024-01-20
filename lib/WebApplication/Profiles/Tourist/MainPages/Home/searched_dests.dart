import 'package:touristine/WebApplication/Notifications/snack_bar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'destination_view.dart';
import 'dart:convert';

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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 0,
                    child: Image.asset(
                      'assets/Images/Profiles/Tourist/emptyListTransparent.gif',
                      fit: BoxFit.fill,
                    ),
                  ),
                  const Positioned(
                    top: 450,
                    child: Text(
                      'No results found',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Gabriola',
                        color: Color.fromARGB(255, 23, 99, 114),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/Images/Profiles/Tourist/homeBackground.jpg',
                      ),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: widget.destinationsList.length > 6
                      ? Scrollbar(
                          thickness: 3,
                          trackVisibility: true,
                          thumbVisibility: true,
                          controller: scrollController,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            controller: scrollController,
                            children: [
                              Wrap(
                                spacing: 10.0,
                                runSpacing: 10.0,
                                children: List.generate(
                                  widget.destinationsList.length,
                                  (index) {
                                    final destinationName =
                                        widget.destinationsList[index]['name'];
                                    return buildPlaceTile(
                                      destinationName,
                                      widget.destinationsList[index]
                                          ['imagePath'],
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
                                              destination: widget
                                                  .destinationsList[index],
                                              token: widget.token,
                                              destinationDetails:
                                                  destinationDetails,
                                              destinationImages:
                                                  destinationImages,
                                              ratings: ratings,
                                            ),
                                          ),
                                        );
                                        print(
                                            'Tapped on ${widget.destinationsList[index]['name']}');
                                      },
                                      isLoadingMap[destinationName] ?? false,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      : Wrap(
                          spacing: 10.0,
                          runSpacing: 10.0,
                          children: List.generate(
                            widget.destinationsList.length,
                            (index) {
                              final destinationName =
                                  widget.destinationsList[index]['name'];
                              return buildPlaceTile(
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
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

// A Function to build a profile tile with a title, image, and onTap action.
Widget buildPlaceTile(
    String title, String imagePath, VoidCallback onTapAction, bool isLoading) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5),
    child: Card(
      color: const Color.fromARGB(21, 4, 208, 249),
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          color: Color(0xFF1E889E),
          width: 4,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        height: 280,
        width: 400,
        child: Stack(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: onTapAction,
              title: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      imagePath,
                      height: 200,
                      width: 400,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
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
            // Circular progress indicator.
            if (isLoading)
              const Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF1E889E)),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
