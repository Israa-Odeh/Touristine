import 'package:touristine/AndroidMobileApp/Profiles/Tourist/MainPages/Home/adding_complaint.dart';
import 'package:touristine/AndroidMobileApp/Profiles/Tourist/MainPages/Home/location_tracking.dart';
import 'package:touristine/AndroidMobileApp/Profiles/Tourist/MainPages/Home/uploaded_images.dart';
import 'package:touristine/AndroidMobileApp/Profiles/Tourist/MainPages/Home/uploading_images.dart';
import 'package:touristine/AndroidMobileApp/Profiles/Tourist/MainPages/Home/adding_review.dart';
import 'package:touristine/AndroidMobileApp/Profiles/Tourist/MainPages/Home/images_list.dart';
import 'package:touristine/AndroidMobileApp/Profiles/Tourist/MainPages/Home/complaints.dart';
import 'package:touristine/AndroidMobileApp/Profiles/Tourist/MainPages/Home/reviews.dart';
import 'package:touristine/AndroidMobileApp/Notifications/snack_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';

import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class DestinationDetails extends StatefulWidget {
  final String token;
  final Map<String, dynamic> destination;
  Map<String, dynamic> destinationDetails;
  List<Map<String, dynamic>> destinationImages;
  Map<String, int> ratings;

  DestinationDetails(
      {super.key,
      required this.token,
      required this.destination,
      required this.destinationDetails,
      required this.destinationImages,
      required this.ratings});

  @override
  _DestinationDetailsState createState() => _DestinationDetailsState();
}

class _DestinationDetailsState extends State<DestinationDetails> {
  late String selectedImage;
  double destLat = 0;
  double destLng = 0;
  Position? _currentPosition;
  double airDistance = 0;
  bool isRouteFetched = false;
  double distanceFromTo = 0;
  int timeFromToH = 0;
  int timeFromToMin = 0;

  List<Map<String, dynamic>> reviews = [];
  List<Map<String, dynamic>> complaints = [];
  List<Map<String, dynamic>> uploadedImages = [];

  @override
  void initState() {
    super.initState();
    selectedImage =
        widget.destination['image'] ?? widget.destination['imagePath'];
    getDestinationLatLng();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // A function to retrieve the users review data.
  Future<void> getAllReviews() async {
    final url = Uri.parse('https://touristineapp.onrender.com/get-all-reviews');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {
          'destinationName': widget.destination['name'],
        },
      );

      if (response.statusCode == 200) {
        // Success.
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('reviews')) {
          // Retrieve the list of reviews.
          final List<dynamic> reviewsData = responseData['reviews'];

          reviews = reviewsData.map((reviewData) {
            return {
              'firstName': reviewData['firstName'],
              'lastName': reviewData['lastName'],
              'date': reviewData['date'],
              'stars': reviewData['stars'],
              'commentTitle': reviewData['commentTitle'],
              'commentContent': reviewData['commentContent'],
            };
          }).toList();
          print(reviews);
        } else {
          print('Error: Reviews key not found in the response');
        }
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['error'] ==
            'Reviews are not available for this destination') {
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, 'Reviews are not available',
              bottomMargin: 310);
        } else {
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, responseData['error'], bottomMargin: 310);
        }
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Error retrieving destination reviews',
            bottomMargin: 310);
      }
    } catch (error) {
      print('Failed to fetch destination reviews: $error');
    }
  }

  // A function to retrieve the user's review data.
  Future<void> getReviewData() async {
    final url = Uri.parse('https://touristineapp.onrender.com/get-review-data');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {
          'destinationName': widget.destination['name'],
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AddingReviewPage(
                    token: widget.token,
                    destinationName: widget.destination['name'],
                    reviewStars: responseData['stars'],
                    reviewTitle: responseData['title'],
                    reviewContent: responseData['content'],
                    onReviewAdded: () {
                      // This function will be called when a new review is added.
                      getDestinationDetails(widget.destination['name']);
                    },
                  )),
        );
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, responseData['error'], bottomMargin: 310);
      } else if (response.statusCode == 404) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // ignore: use_build_context_synchronously
        // showCustomSnackBar(context, responseData['message'], bottomMargin: 310);
        print(responseData['message']);
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AddingReviewPage(
                    token: widget.token,
                    destinationName: widget.destination['name'],
                    onReviewAdded: () {
                      // This function will be called when a new review is added.
                      getDestinationDetails(widget.destination['name']);
                    },
                  )),
        );
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Error fetching your review',
            bottomMargin: 310);
      }
    } catch (error) {
      print('Failed to fetch your review: $error');
    }
  }

  // A function to retrieve all of the destination details.
  Future<void> getDestinationDetails(String destName) async {
    final url =
        Uri.parse('https://touristineapp.onrender.com/get-destination-details');

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
        widget.destinationImages =
            List<Map<String, dynamic>>.from(responseData['destinationImages']);

        // Access destination details and other data.
        widget.destinationDetails = responseData['destinationDetails'];
        widget.ratings = Map<String, int>.from(responseData['rating']);

        // Now you can use the data as needed
        print('Destination Images: ${widget.destinationImages}');
        print('Destination Details: ${widget.destinationDetails}');
        print('Rating: ${widget.ratings}');
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

  // A function to retrieve the destination latitude and longitude.
  Future<void> getDestinationLatLng() async {
    final url =
        Uri.parse('https://touristineapp.onrender.com/get-destination-lat-lng');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {
          'destinationName': widget.destination['name'],
        },
      );

      if (response.statusCode == 200) {
        // Success.
        // Jenan, I want to retrieve the latitude and longitude of the destination.
        final Map<String, dynamic> responseData = json.decode(response.body);
        destLat = double.parse(responseData['latitude']);
        destLng = double.parse(responseData['longitude']);
        print(destLat);
        print(destLng);
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('error')) {
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, responseData['error'], bottomMargin: 310);
        }
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Error retrieving place location',
            bottomMargin: 310);
      }
    } catch (error) {
      print('Failed to fetch the destination lat and lng: $error');
    }
  }

  // A Function to fetch user complaints from the backend.
  Future<void> fetchUserComplaints() async {
    final url = Uri.parse('https://touristineapp.onrender.com/get-complaints');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {
          'destinationName': widget.destination['name'],
        },
      );

      if (response.statusCode == 200) {
        // Jenan, I need to retrieve a list of complaints - if there is any,
        // the retrieved list<map> will be of the same format as the one
        // given at line 211.
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('complaints')) {
          complaints =
              List<Map<String, dynamic>>.from(responseData['complaints']);
          print(complaints);
        } else {
          // Handle the case when 'complaints' key is not present in the response
          print('No complaints keyword found in the response');
        }
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, responseData['error'], bottomMargin: 310);
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Error retrieving your complaints',
            bottomMargin: 310);
      }
    } catch (error) {
      print('Error fetching complaints: $error');
    }
  }

  // A Function to fetch user images-uploads from the backend.
  Future<void> fetchUploadedImages() async {
    final url =
        Uri.parse('https://touristineapp.onrender.com/get-uploaded-images');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {
          'destinationName': widget.destination['name'],
        },
      );

      if (response.statusCode == 200) {
        // Jenan, I need to retrieve a list of uplaoded images by this user for this dest.
        // with the keywords added when images are uplaoded from the upload interface.
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('uploadedImages')) {
          uploadedImages =
              List<Map<String, dynamic>>.from(responseData['uploadedImages']);
          print(uploadedImages);
        } else {
          print('No uploadedImages keyword found in the response');
        }
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, responseData['error'], bottomMargin: 310);
      } else if (response.statusCode == 404) {
        print("Uploaded images list is empty");
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Error retrieving your uploads',
            bottomMargin: 310);
      }
    } catch (error) {
      print('Error fetching uploads: $error');
    }
  }

  void updateSelectedImage(String imagePath) {
    setState(() {
      selectedImage = imagePath;
    });
  }

  String getFormattedDays(List<dynamic> days) {
    // Define the order of days.
    List<String> orderOfDays = [
      "Saturday",
      "Sunday",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
    ];

    // Check if the given days are in the desired order.
    bool isInOrder = List.generate(days.length, (index) => index)
        .every((index) => days[index] == orderOfDays[index]);

    // Sort the days if they are not in order.
    if (!isInOrder) {
      days.sort((a, b) => orderOfDays.indexOf(a) - orderOfDays.indexOf(b));
    }

    // Check if the days are in sequence.
    bool isInSequence = List.generate(days.length, (index) => index)
        .every((index) => orderOfDays.indexOf(days[index]) == index);

    // Identify consecutive days.
    List<String> formattedDays = [];
    int startConsecutiveIndex = 0;
    for (int i = 1; i < days.length; i++) {
      if (orderOfDays.indexOf(days[i]) ==
          orderOfDays.indexOf(days[i - 1]) + 1) {
        // Continue checking consecutive days.
        continue;
      } else {
        // Consecutive sequence ended.
        if (startConsecutiveIndex == i - 1) {
          // Consecutive days were just one day, add that day.
          formattedDays.add(days[startConsecutiveIndex].toString());
        } else {
          // Add the consecutive range.
          formattedDays.add(
              '${days[startConsecutiveIndex].toString()}-${days[i - 1].toString()}');
        }
        // Reset start index for the next consecutive sequence.
        startConsecutiveIndex = i;
      }
    }

    // Add the last day or consecutive range.
    if (startConsecutiveIndex == days.length - 1) {
      formattedDays.add(days[startConsecutiveIndex].toString());
    } else {
      formattedDays.add(
          '${days[startConsecutiveIndex].toString()}-${days[days.length - 1].toString()}');
    }

    // Return the formatted string based on the conditions.
    if (days.length == 1) {
      return days.first.toString();
    } else if (days.length == 2) {
      return '${days.first}, ${days.last}';
    } else {
      return (isInSequence)
          ? '${days.first} - ${days.last}'
          : formattedDays.join(', ');
    }
  }

  void showWDDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Working Days"),
          content: Text(
            getFormattedDays(widget.destinationDetails['WorkingDays']),
            style: const TextStyle(
              fontFamily: 'Time New Roman',
              fontSize: 18,
              fontWeight: FontWeight.normal,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Close',
                style: TextStyle(
                  fontSize: 22.0,
                  fontFamily: 'Zilla',
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 200, 50, 27),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Section of location accquistion functions.
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // ignore: use_build_context_synchronously
      showCustomSnackBar(context, "Location services are disabled",
          bottomMargin: 310);
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, "Location permissions are denied",
            bottomMargin: 310);
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Location permissions are permanently denied, we cannot request permissions,
      // ignore: use_build_context_synchronously
      showCustomSnackBar(context, "Location permissions permanently denied",
          bottomMargin: 310);

      return false;
    }
    // ignore: use_build_context_synchronously
    showCustomSnackBar(context, "Please wait for a moment", bottomMargin: 310);
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
      _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      // Placemark place = placemarks[0];
      setState(() {
        // print(_currentPosition!.latitude);
        // print(_currentPosition!.longitude);
        // airDistance = Geolocator.distanceBetween(_currentPosition!.latitude,
        //         _currentPosition!.longitude, destLat, destLng) /
        //     1000;
        // print("**************************************************");
        // print(airDistance);
        // print("**************************************************");
      });
    }).catchError((e) {
      print("An error occured $e");
    });
  }

  Future<Map<String, dynamic>> getDirections(
      double startLat, double startLng, double endLat, double endLng) async {
    const apiKey = 'AIzaSyACRpyMRSxrAcO00IGbMzYI0N4zKxUPWg4';
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$startLat,$startLng&destination=$endLat,$endLng&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final routes = decoded['routes'] as List<dynamic>;
      if (routes.isNotEmpty) {
        final legs = routes[0]['legs'] as List<dynamic>;
        if (legs.isNotEmpty) {
          final distance = legs[0]['distance']['value'] as int;
          final duration = legs[0]['duration']['value'] as int;
          final startAddress = legs[0]['start_address'] as String;
          final endAddress = legs[0]['end_address'] as String;

          final airDistance =
              calculateAirDistance(startLat, startLng, endLat, endLng);

          isRouteFetched = true;
          // Convert duration to hours and minutes
          final int hours = duration ~/ 3600;
          final int remainingSeconds = duration % 3600;
          final int minutes = remainingSeconds ~/ 60;

          return {
            'distance': distance / 1000.0, // Convert meters to kilometers.
            'duration': {'hours': hours, 'minutes': minutes},
            'startAddress': startAddress,
            'endAddress': endAddress,
            'airDistance': airDistance,
          };
        }
      }
    }

    // Handle errors or no route found scenario.
    return {
      'distance': -1.0,
      'duration': -1,
      'startAddress': '',
      'endAddress': '',
      'airDistance': -1.0,
    };
  }

  double calculateAirDistance(
      double startLat, double startLng, double endLat, double endLng) {
    const earthRadius = 6371.0; // Radius of the Earth in kilometers.

    // Conversion from degrees to radians.
    final lat1Rad = startLat * (pi / 180.0);
    final lng1Rad = startLng * (pi / 180.0);
    final lat2Rad = endLat * (pi / 180.0);
    final lng2Rad = endLng * (pi / 180.0);

    // differences in latitude and longitude.
    final dlat = lat2Rad - lat1Rad;
    final dlng = lng2Rad - lng1Rad;

    final a = pow(sin(dlat / 2), 2) +
        cos(lat1Rad) * cos(lat2Rad) * pow(sin(dlng / 2), 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    final distance = earthRadius * c;

    return distance;
  }

  void fetchRouteClicked() async {
    try {
      await _getCurrentPosition();
      // Ensure that _getCurrentPosition has successfully obtained the position.
      if (_currentPosition != null) {
        final directions = await getDirections(_currentPosition!.latitude,
            _currentPosition!.longitude, destLat, destLng);

        if (directions['distance'] != -1.0) {
          distanceFromTo = directions['distance'];
          airDistance = directions['airDistance'];
          timeFromToH = directions['duration']['hours'];
          timeFromToMin = directions['duration']['minutes'];

          print('Real distance: ${directions['distance']} km');
          print('Duration: ${directions['duration']} hours');
          print('Start Address: ${directions['startAddress']}');
          print('End Address: ${directions['endAddress']}');
          print('Air Distance: ${directions['airDistance']} km');
        } else {
          print('Error calculating distance or no route found.');
        }
      } else {
        print(
            'Error getting current position. Please check location permissions.');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    int tabLength =
        widget.destinationDetails['virtualTourLink'].toString().isEmpty ? 7 : 8;
    return DefaultTabController(
      length: tabLength,
      child: Scaffold(
        body: Stack(
          children: [
            Image.asset(
              "assets/Images/Profiles/Tourist/homeBackground.jpg",
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top),
                  Image.network(
                    selectedImage,
                    width: 500,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 8),
                  if (widget.destinationImages.isNotEmpty)
                    ImagesList(
                      listOfImages: widget.destinationImages,
                      onImageSelected: updateSelectedImage,
                    ),
                  if (widget.destinationImages.isEmpty)
                    const SizedBox(height: 130),
                  const SizedBox(height: 8),
                  TabBar(
                    isScrollable: true,
                    indicatorColor: const Color(0xFF1E889E),
                    indicatorPadding:
                        const EdgeInsets.symmetric(horizontal: 15),
                    indicatorWeight: 3,
                    labelColor: const Color(0xFF1E889E),
                    unselectedLabelColor:
                        const Color.fromARGB(182, 30, 137, 158),
                    labelStyle:
                        const TextStyle(fontSize: 30.0, fontFamily: 'Zilla'),
                    unselectedLabelStyle:
                        const TextStyle(fontSize: 25.0, fontFamily: 'Zilla'),
                    tabs: [
                      const Tab(text: 'About'),
                      const Tab(text: 'Description'),
                      const Tab(text: 'Services'),
                      const Tab(text: 'Location'),
                      // Add Virtual Tour Tab if there is a virtual tour link.
                      if (widget.destinationDetails['virtualTourLink']
                          .toString()
                          .isNotEmpty)
                        const Tab(text: 'Virtual Tour'),
                      const Tab(text: 'Reviews'),
                      const Tab(text: 'Complaints'),
                      const Tab(text: 'Images'),
                    ],
                  ),
                  SizedBox(
                    height: 320,
                    child: TabBarView(
                      children: [
                        _buildAboutTab(),
                        _buildDescriptionTab(),
                        _buildServicesTab(),
                        _buildLocationsTab(),
                        if (widget.destinationDetails['virtualTourLink']
                            .toString()
                            .isNotEmpty)
                          _buildVirtualTourTab(),
                        _buildReviewsTab(),
                        _buildComplaintsTab(),
                        _buildImagesUplaodTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Floating Action Button
            Positioned(
              top: 26.0,
              left: 5.0,
              child: FloatingActionButton(
                heroTag: 'BackHome',
                onPressed: () {
                  Navigator.of(context).pop();
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: const Icon(FontAwesomeIcons.arrowLeft),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getPlaceCategory(String placeCategory) {
    if (placeCategory.toLowerCase() == "coastalareas") {
      return "Coastal Area";
    } else if (placeCategory.toLowerCase() == "mountains") {
      return "Mountain";
    } else if (placeCategory.toLowerCase() == "nationalparks") {
      return "National Park";
    } else if (placeCategory.toLowerCase() == "majorcities") {
      return "Major City";
    } else if (placeCategory.toLowerCase() == "countryside") {
      return "Countryside";
    } else if (placeCategory.toLowerCase() == "historicalsites") {
      return "Historical Site";
    } else if (placeCategory.toLowerCase() == "religiouslandmarks") {
      return "Religious Landmark";
    } else if (placeCategory.toLowerCase() == "aquariums") {
      return "Aquarium";
    } else if (placeCategory.toLowerCase() == "zoos") {
      return "Zoo";
    } else {
      return "Others";
    }
  }

  Widget _buildAboutTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                double additionalMargin = 0;
                if (constraints.maxHeight > 295) {
                  additionalMargin = 10.0;
                }

                String destinationName = widget.destination['name'];
                String category =
                    getPlaceCategory(widget.destinationDetails['Category']);

                int totalLength = destinationName.length + category.length;

                bool displayInSameRow = totalLength <= 32;

                return Padding(
                  padding: EdgeInsets.only(bottom: 5.0 + additionalMargin),
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: 295,
                    ),
                    width: 400,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(33, 20, 89, 121),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 13.0, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (displayInSameRow)
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 2.0),
                                    child: Text(
                                      destinationName,
                                      style: const TextStyle(
                                        fontSize: 35,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Gabriola',
                                        color: Color.fromARGB(195, 18, 83, 96),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        125, 255, 255, 255),
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Text(
                                    category,
                                    style: const TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Gabriola',
                                      color: Color.fromARGB(195, 18, 83, 96),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (!displayInSameRow)
                            Padding(
                              padding: const EdgeInsets.only(left: 2.0),
                              child: Text(
                                destinationName,
                                style: const TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Gabriola',
                                  color: Color.fromARGB(195, 18, 83, 96),
                                ),
                              ),
                            ),
                          if (!displayInSameRow)
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(125, 255, 255, 255),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Gabriola',
                                  color: Color.fromARGB(195, 18, 83, 96),
                                ),
                              ),
                            ),
                          SizedBox(height: totalLength <= 32 ? 10 : 20),
                          Text(
                            displayInSameRow
                                ? widget.destinationDetails['About']
                                    .split('\n')
                                    .take(2)
                                    .join('\n')
                                : widget.destinationDetails['About']
                                    .split('\n')
                                    .take(3)
                                    .join('\n'),
                            maxLines: displayInSameRow ? 3 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 31,
                              fontFamily: 'Gabriola',
                              color: Color.fromARGB(255, 23, 103, 120),
                            ),
                          ),
                          // Button to show the full text in a dialog.
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  backgroundColor: const Color(0xFF1E889E),
                                  textStyle: const TextStyle(
                                    fontSize: 22,
                                    fontFamily: 'Zilla',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('About $destinationName',
                                            style: const TextStyle(
                                                color: Color.fromARGB(
                                                    255, 11, 57, 66))),
                                        content: Scrollbar(
                                          thickness: 5,
                                          trackVisibility: true,
                                          thumbVisibility: true,
                                          child: SizedBox(
                                            height: 350,
                                            child: SingleChildScrollView(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10.0),
                                                child: Text(
                                                  widget.destinationDetails[
                                                      'About'],
                                                  style: const TextStyle(
                                                    fontSize: 27,
                                                    fontFamily: 'Gabriola',
                                                    color: Color.fromARGB(
                                                        255, 23, 103, 120),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              'Close',
                                              style: TextStyle(
                                                fontSize: 22.0,
                                                fontFamily: 'Zilla',
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 200, 50, 27),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: const Text('Read More'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String getBudgetLevel(String budgetLevel) {
    if (budgetLevel.toLowerCase() == "midrange") {
      return "Mid-Range";
    } else if (budgetLevel.toLowerCase() == "budgetfriendly") {
      return "Budget-Friendly";
    } else {
      return "Luxurious";
    }
  }

  Widget _buildDescriptionTab() {
    ScrollController scrollController = ScrollController();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          ScrollbarTheme(
            data: ScrollbarThemeData(
              thumbColor: MaterialStateProperty.all(
                  const Color.fromARGB(125, 23, 102, 118)),
              radius: const Radius.circular(10),
            ),
            child: Scrollbar(
              controller: scrollController,
              trackVisibility: true,
              thumbVisibility: true,
              thickness: 10,
              child: Container(
                height: 295,
                width: 400,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(33, 20, 89, 121),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 13.0, right: 20),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: const Color(0xFF1E889E),
                            ),
                            width: 174.0,
                            height: 65.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const FaIcon(
                                  FontAwesomeIcons.cloudSunRain,
                                  color: Colors.white,
                                  size: 38,
                                ),
                                const SizedBox(width: 25.0),
                                Text(
                                  '${widget.destinationDetails['Weather'][0]}°C',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Time New Roman',
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: const Color(0xFF1E889E),
                            ),
                            width: 174.0,
                            height: 65.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const FaIcon(
                                  FontAwesomeIcons.rankingStar,
                                  color: Colors.white,
                                  size: 38,
                                ),
                                const SizedBox(width: 25.0),
                                Text(
                                  widget.destinationDetails['Rating'] != null
                                      ? '${widget.destinationDetails['Rating']}'
                                      : '0.0',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Time New Roman',
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: const Color(0xFF1E889E),
                        ),
                        width: 370.0,
                        height: 60.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 30.0),
                              child: FaIcon(
                                FontAwesomeIcons.cloudSun,
                                color: Colors.white,
                                size: 38,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 30.0),
                              child: Text(
                                widget.destinationDetails['WeatherDescription']
                                    [0],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Time New Roman',
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: const Color(0xFF1E889E),
                        ),
                        width: 370.0,
                        height: 60.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.clock,
                              color: Colors.white,
                              size: 38,
                            ),
                            const SizedBox(width: 0.0),
                            Text(
                              '${widget.destinationDetails['OpeningTime']} - ${widget.destinationDetails['ClosingTime']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Time New Roman',
                                fontSize: 25,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      GestureDetector(
                        onTap: () {
                          showWDDialog(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: const Color(0xFF1E889E),
                          ),
                          width: 370.0,
                          height: 60.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 30.0),
                                child: FaIcon(
                                  FontAwesomeIcons.calendar,
                                  color: Colors.white,
                                  size: 38,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 30.0),
                                child: Text(
                                  getFormattedDays(widget.destinationDetails[
                                                  'WorkingDays'])
                                              .length <=
                                          20
                                      ? getFormattedDays(widget
                                          .destinationDetails['WorkingDays'])
                                      : "Workings Days",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Time New Roman',
                                    fontSize: 25,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: const Color(0xFF1E889E),
                        ),
                        width: 370.0,
                        height: 60.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 30.0),
                              child: FaIcon(
                                FontAwesomeIcons.dollarSign,
                                color: Colors.white,
                                size: 38,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 30.0),
                              child: Text(
                                getBudgetLevel(
                                    widget.destinationDetails['CostLevel']),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Time New Roman',
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: const Color(0xFF1E889E),
                        ),
                        width: 370.0,
                        height: 60.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 30.0),
                              child: FaIcon(
                                FontAwesomeIcons.personShelter,
                                color: Colors.white,
                                size: 38,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 30.0),
                              child: Text(
                                widget.destinationDetails['sheltered']
                                            .toLowerCase() ==
                                        ("true")
                                    ? 'Sheltered'
                                    : 'Unsheltered',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Time New Roman',
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: const Color(0xFF1E889E),
                        ),
                        width: 370.0,
                        height: 60.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 30.0),
                              child: FaIcon(
                                FontAwesomeIcons.hourglass,
                                color: Colors.white,
                                size: 38,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 30.0),
                              child: Text(
                                '${widget.destinationDetails['EstimatedTime']} ${widget.destinationDetails['EstimatedTime'] == 1 ? 'hour' : 'hours'}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Time New Roman',
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ServiceDescription getServiceDescription(String serviceName) {
    if (serviceName.toLowerCase() == "restrooms") {
      return ServiceDescription(
          "Public restrooms are available", FontAwesomeIcons.restroom);
    } else if (serviceName.toLowerCase() == "wheelchairramps") {
      return ServiceDescription("Wheelchair ramps for enhanced accessibility",
          FontAwesomeIcons.wheelchair);
    } else if (serviceName.toLowerCase() == "photographers") {
      return ServiceDescription(
          "Photographic services are accessible", FontAwesomeIcons.cameraRetro);
    } else if (serviceName.toLowerCase() == "healthcenters") {
      return ServiceDescription("Accessible health care centers are available",
          FontAwesomeIcons.suitcaseMedical);
    } else if (serviceName.toLowerCase() == "parking") {
      return ServiceDescription("Convenient access to a parking garage",
          FontAwesomeIcons.squareParking);
    } else if (serviceName.toLowerCase() == "kidsarea") {
      return ServiceDescription(
          "Play areas for children are available", FontAwesomeIcons.child);
    } else if (serviceName.toLowerCase() == "gasstations") {
      return ServiceDescription(
          "There are nearby gas stations", FontAwesomeIcons.gasPump);
    } else if (serviceName.toLowerCase() == "restaurants") {
      return ServiceDescription(
          "Nearby restaurants for dining options", FontAwesomeIcons.utensils);
    } else {
      return ServiceDescription(serviceName, FontAwesomeIcons.circleCheck);
    }
  }

  Widget _buildServicesTab() {
    ScrollController scrollController = ScrollController();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          ScrollbarTheme(
            data: ScrollbarThemeData(
              thumbColor: MaterialStateProperty.all(
                  const Color.fromARGB(125, 23, 102, 118)),
              radius: const Radius.circular(10),
            ),
            child: Scrollbar(
              controller: scrollController,
              trackVisibility: true,
              thumbVisibility: true,
              thickness: 10,
              child: Container(
                height: 295,
                width: 400,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(33, 20, 89, 121),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 13.0, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vertical scrollable list of services.
                      SizedBox(
                        height: 295,
                        child: ListView.builder(
                          controller: scrollController,
                          scrollDirection: Axis.vertical,
                          itemCount:
                              widget.destinationDetails['Services'].length,
                          itemBuilder: (context, index) {
                            String serviceName = widget
                                .destinationDetails['Services'][index]['name'];
                            ServiceDescription serviceDescription =
                                getServiceDescription(serviceName);

                            return Container(
                              margin: (index ==
                                      widget.destinationDetails['Services']
                                              .length -
                                          1)
                                  ? const EdgeInsets.only(bottom: 20)
                                  : const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: const Color.fromARGB(162, 30, 137, 158),
                              ),
                              height: 100,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Icon for the service, using the corresponding icon from the list
                                    Icon(
                                      serviceDescription.icon,
                                      color: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      size: 35,
                                    ),
                                    // Text description for the service
                                    const SizedBox(
                                      width: 30,
                                    ),
                                    Expanded(
                                      child: Text(
                                        serviceDescription.description,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Times New Roman',
                                          fontSize: 23,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationsTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Container(
            height: 295,
            width: 400,
            decoration: BoxDecoration(
              color: const Color.fromARGB(33, 20, 89, 121),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 10, left: 13.0, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add distance and estimated time labels with icons.
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: const Color(0xFF1E889E),
                        ),
                        width: 370.0,
                        height: 55.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 30.0),
                              child: FaIcon(
                                FontAwesomeIcons.locationDot,
                                color: Colors.white,
                                size: 35,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 30.0),
                              child: Text(
                                isRouteFetched
                                    ? '${distanceFromTo.toStringAsFixed(2)} km away'
                                    : '_ _    km away',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Time New Roman',
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: const Color(0xFF1E889E),
                        ),
                        width: 370.0,
                        height: 55.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 30.0),
                              child: FaIcon(
                                FontAwesomeIcons.clock,
                                color: Colors.white,
                                size: 35,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 30.0),
                              child: Text(
                                isRouteFetched
                                    ? '${timeFromToH > 0 ? '$timeFromToH h' : ''}${timeFromToH > 0 && timeFromToMin > 0 ? ', ' : ''}${timeFromToMin > 0 ? '$timeFromToMin min' : ''}${timeFromToH == 0 && timeFromToMin == 0 ? 'Just moments' : ''} away'
                                    : '_ _       h away',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Time New Roman',
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: const Color(0xFF1E889E),
                        ),
                        width: 370.0,
                        height: 55.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 30.0),
                              child: FaIcon(
                                FontAwesomeIcons.leftRight,
                                color: Colors.white,
                                size: 35,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 30.0),
                              child: Text(
                                isRouteFetched
                                    ? '${airDistance.toStringAsFixed(2)} km away'
                                    : '_ _       h away',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Time New Roman',
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Buttons for getting distance and time, and getting directions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          fetchRouteClicked();
                          if (isRouteFetched) {
                            setState(() {});
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          backgroundColor: const Color(0xFF1E889E),
                          textStyle: const TextStyle(
                            fontSize: 30,
                            fontFamily: 'Zilla',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.route,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Text('Fetch Route'),
                          ],
                        ),
                      ),
                      FloatingActionButton(
                        heroTag: 'Get Directions',
                        backgroundColor: const Color(0xFF1E889E),
                        onPressed: () async {
                          try {
                            await _getCurrentPosition();
                            // ignore: use_build_context_synchronously
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LocationLiveTracking(
                                  srcLat: _currentPosition!.latitude,
                                  scrLng: _currentPosition!.longitude,
                                  dstLat: destLat,
                                  dstLng: destLng,
                                ),
                              ),
                            );
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          } catch (e) {
                            print('An error occurred: $e');
                          }
                        },
                        child: const FaIcon(FontAwesomeIcons.diamondTurnRight),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int getStarCount(String ratingKey) {
    switch (ratingKey) {
      case 'oneStar':
        return 1;
      case 'twoStars':
        return 2;
      case 'threeStars':
        return 3;
      case 'fourStars':
        return 4;
      case 'fiveStars':
        return 5;
      default:
        return 0;
    }
  }

  Widget _buildReviewsTab() {
    int reviewsCount =
        widget.ratings.values.fold<int>(0, (sum, value) => sum + value);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Container(
            height: 295,
            width: 400,
            decoration: BoxDecoration(
              color: const Color.fromARGB(33, 20, 89, 121),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 10, left: 13.0, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (reviewsCount == 0)
                    const Text(
                      'Share and be the first to write a review about this destination!',
                      style: TextStyle(
                        fontSize: 35,
                        fontFamily: 'Gabriola',
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 23, 103, 120),
                      ),
                    ),
                  if (reviewsCount == 0) const SizedBox(height: 30),
                  if (reviewsCount > 0)
                    SizedBox(
                      height: 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.ratings.entries.map((entry) {
                          final String ratingKey = entry.key;
                          final int count = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Star icons.
                                Row(
                                  children: List.generate(
                                    getStarCount(ratingKey),
                                    (index) => const Row(
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.solidStar,
                                          color:
                                              Color.fromARGB(255, 211, 171, 12),
                                          size: 18,
                                        ),
                                        SizedBox(width: 5),
                                      ],
                                    ),
                                  ),
                                ),
                                // Dynamic filled bars.
                                Container(
                                  width: 200,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(59, 30, 137, 158),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: count /
                                        widget.ratings.values.fold<int>(
                                            0, (sum, value) => sum + value),
                                    child: Container(
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            167, 30, 137, 158),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  // Number of ratings.
                  const SizedBox(height: 8),
                  Text(
                    'Total Ratings: ${widget.ratings.values.fold<int>(0, (sum, value) => sum + value)}',
                    style: const TextStyle(
                      color: Color(0xFF1E889E),
                      fontFamily: 'Gabriola',
                      fontSize: 35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Buttons
                  // const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await getAllReviews();
                          // ignore: use_build_context_synchronously
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AllReviewsPage(reviews: reviews),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 10,
                          ),
                          backgroundColor: const Color(0xFF1E889E),
                          textStyle: const TextStyle(
                            fontSize: 30,
                            fontFamily: 'Zilla',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text('See All'),
                      ),
                      FloatingActionButton(
                        heroTag: 'Add Review',
                        backgroundColor: const Color(0xFF1E889E),
                        onPressed: () async {
                          await getReviewData();
                        },
                        child: const FaIcon(FontAwesomeIcons.plus),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintsTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                double additionalMargin = 0;
                if (constraints.maxHeight > 295) {
                  additionalMargin = 10.0;
                }
                return Padding(
                  padding: EdgeInsets.only(bottom: 5.0 + additionalMargin),
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: 295,
                    ),
                    width: 400,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(33, 20, 89, 121),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 13.0, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Do you have any complaints? Feel free to inform us, and we will follow the necessary procedures.',
                            style: TextStyle(
                              fontSize: 35,
                              fontFamily: 'Gabriola',
                              fontWeight: FontWeight.w500,
                              color: Color.fromARGB(255, 23, 103, 120),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  await fetchUserComplaints();
                                  // ignore: use_build_context_synchronously
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ComplaintsListPage(
                                              token: widget.token,
                                              complaints: complaints,
                                            )),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 50,
                                    vertical: 10,
                                  ),
                                  backgroundColor: const Color(0xFF1E889E),
                                  textStyle: const TextStyle(
                                    fontSize: 30,
                                    fontFamily: 'Zilla',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child: const Text('View All'),
                              ),
                              FloatingActionButton(
                                heroTag: 'Add Complaint',
                                backgroundColor: const Color(0xFF1E889E),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AddingComplaintsPage(
                                              token: widget.token,
                                              destinationName:
                                                  widget.destination['name'],
                                            )),
                                  );
                                },
                                child: const FaIcon(FontAwesomeIcons.plus),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesUplaodTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                double additionalMargin = 0;
                if (constraints.maxHeight > 295) {
                  additionalMargin = 10.0;
                }
                return Padding(
                  padding: EdgeInsets.only(bottom: 5.0 + additionalMargin),
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: 295,
                    ),
                    width: 400,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(33, 20, 89, 121),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 13.0, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Capture the beauty of  ${widget.destination['name']} through your lens and share it with us!',
                            style: const TextStyle(
                              fontSize: 35,
                              fontFamily: 'Gabriola',
                              fontWeight: FontWeight.w500,
                              color: Color.fromARGB(255, 23, 103, 120),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  await fetchUploadedImages();
                                  // ignore: use_build_context_synchronously
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UploadedImagesPage(
                                          token: widget.token,
                                          destinationName:
                                              widget.destination['name'],
                                          uploadedImages: uploadedImages),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 10,
                                  ),
                                  backgroundColor: const Color(0xFF1E889E),
                                  textStyle: const TextStyle(
                                    fontSize: 28,
                                    fontFamily: 'Zilla',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child: const Text('My Uplaods'),
                              ),
                              FloatingActionButton(
                                heroTag: 'Upload Images',
                                backgroundColor: const Color(0xFF1E889E),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            UploadingImagesPage(
                                              token: widget.token,
                                              destinationName:
                                                  widget.destination['name'],
                                            )),
                                  );
                                },
                                child: const FaIcon(FontAwesomeIcons.plus),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVirtualTourTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                double additionalMargin = 0;
                if (constraints.maxHeight > 295) {
                  additionalMargin = 10.0;
                }
                return Padding(
                  padding: EdgeInsets.only(bottom: 5.0 + additionalMargin),
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: 295,
                    ),
                    width: 400,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(33, 20, 89, 121),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: SizedBox(
                      height: 295,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 13.0, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Discover ${widget.destination['name']} with a virtual tour for a real experience!',
                              style: const TextStyle(
                                fontSize: 35,
                                fontFamily: 'Gabriola',
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 23, 103, 120),
                              ),
                            ),
                            const Spacer(),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: ElevatedButton(
                                onPressed: () {
                                  final websiteURI = Uri.parse(widget
                                      .destinationDetails['virtualTourLink']);
                                  launchTourURL(websiteURI);
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 90,
                                    vertical: 10,
                                  ),
                                  backgroundColor: const Color(0xFF1E889E),
                                  textStyle: const TextStyle(
                                    fontSize: 28,
                                    fontFamily: 'Zilla',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Start Tour'),
                                    SizedBox(width: 20),
                                    FaIcon(
                                      FontAwesomeIcons.vrCardboard,
                                      size: 28,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void launchTourURL(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.inAppWebView);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class ServiceDescription {
  final String description;
  final IconData icon;

  ServiceDescription(this.description, this.icon);
}
