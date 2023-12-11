import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:touristine/Notifications/SnackBar.dart';
import 'package:touristine/Profiles/Tourist/MainPages/Home/destinationView.dart';
import 'package:touristine/Profiles/Tourist/MainPages/Home/dotsBar.dart';
import 'package:http/http.dart' as http;

class DestinationList extends StatefulWidget {
  final List<Map<String, dynamic>> destinations;
  final String listTitle;
  final String token;

  const DestinationList({
    super.key,
    required this.destinations,
    required this.listTitle,
    required this.token,
  });

  @override
  _DestinationListState createState() => _DestinationListState();
}

class _DestinationListState extends State<DestinationList> {
  final PageController _pageController = PageController();
  int _selectedTileIndex = -1;
  int _currentPageIndex = 0;
  late Timer _timer;
  bool _isLoading = false;

  Map<String, dynamic> destinationDetails = {};
  List<Map<String, dynamic>> destinationImages = [];
  Map<String, int> ratings = {};

  // A function to retrieve all of the destination details.
  Future<void> getDestinationDetails(String destName) async {
    final url = Uri.parse('https://touristine.onrender.com/get-destination-details');

    try {
      setState(() {
        _isLoading = true;
      });

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

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        // Success.
        // Parse the response body.
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Extract destinationImages as List<Map<String, dynamic>>
        destinationImages = List<Map<String, dynamic>>.from(responseData['destinationImages']);

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
          if (responseData['error'] == 'Details for this destination are not available') {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, 'Place details aren\'t available', bottomMargin: 0);
          } else {
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
          }
        }
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Error retrieving place details', bottomMargin: 0);
      }
    } catch (error) {
      print('Failed to fetch place details: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    // Set up a timer for automatic scrolling every 5 seconds.
    startTimer();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  Future<void> navigateToDetailsPage(int index) async {
    // Cancel the timer when the details page is opened.
    _timer.cancel();
    await getDestinationDetails(widget.destinations[index]['name']);

    // ignore: use_build_context_synchronously
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DestinationDetails(
          destination: widget.destinations[index],
          token: widget.token,
          destinationDetails: destinationDetails,
          destinationImages: destinationImages,
          ratings: ratings,
        ),
      ),
    ).then((value) {
      setState(() {
        if (value == null) {
          _selectedTileIndex = -1;
        } else {
          _selectedTileIndex = value;
        }
      });
      // Restart the timer when the details page is exited.
      startTimer();
    });
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPageIndex < widget.destinations.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease,
        );
      } else {
        _pageController.jumpToPage(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
            ),
            child: Text(
              widget.listTitle,
              style: const TextStyle(
                fontSize: 38,
                fontFamily: 'Gabriola',
                color: Color(0xFF1E889E),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
              height: 230,
              width: 400,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: widget.destinations.length,
                    onPageChanged: (int index) {
                      setState(() {
                        _currentPageIndex = index;
                      });
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedTileIndex = index;
                          });
                          navigateToDetailsPage(index);
                          print('Clicked on ${widget.destinations[index]['name']}');
                        },
                        child: Container(
                          margin: const EdgeInsets.all(0),
                          child: Card(
                            color: _selectedTileIndex == index
                                ? const Color.fromARGB(255, 231, 231, 231)
                                : const Color.fromARGB(255, 255, 255, 255),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  color: Color(0xFF1E889E), width: 3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: [
                                Image.network(
                                  widget.destinations[index]['image'],
                                  width: 400,
                                  height: 165,
                                  fit: BoxFit.fill,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      widget.destinations[index]['name'],
                                      style: TextStyle(
                                        color: _selectedTileIndex == index
                                            ? const Color.fromARGB(255, 25, 114, 132)
                                            : const Color(0xFF1E889E),
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Zilla',
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  if (_isLoading) const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF1E889E)),
                  ),
                ],
              ),
            ),
          ),
          DotsBar(
            itemCount: widget.destinations.length,
            currentIndex: _currentPageIndex,
          ),
        ],
      ),
    );
  }
}
