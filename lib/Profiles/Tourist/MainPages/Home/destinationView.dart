import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:touristine/Notifications/SnackBar.dart';
import 'package:touristine/Profiles/Tourist/MainPages/Home/addingReview.dart';
import 'package:touristine/Profiles/Tourist/MainPages/Home/addingComplaint.dart';
import 'package:touristine/Profiles/Tourist/MainPages/Home/complaints.dart';
import 'package:touristine/Profiles/Tourist/MainPages/Home/imagesList.dart';
import 'package:touristine/Profiles/Tourist/MainPages/Home/locationTracking.dart';
import 'package:touristine/Profiles/Tourist/MainPages/Home/reviews.dart';
import 'package:http/http.dart' as http;
import 'package:touristine/Profiles/Tourist/MainPages/Home/uploadedImages.dart';
import 'package:touristine/Profiles/Tourist/MainPages/Home/uploadingImages.dart';

class DestinationDetails extends StatefulWidget {
  final String token;
  final Map<String, dynamic> destination;

  const DestinationDetails(
      {Key? key, required this.destination, required this.token})
      : super(key: key);

  @override
  _DestinationDetailsState createState() => _DestinationDetailsState();
}

class _DestinationDetailsState extends State<DestinationDetails> {
  late String selectedImage;
  double destLat = 32.2226667;
  double destLng = 35.262145;
  Position? _currentPosition;
  double airDistance = 0;
  bool isRouteFetched = false;
  double distanceFromTo = 0;
  double timeFromTo = 0;

  // List<Map<String, dynamic>> complaints = [];

  final List<Map<String, dynamic>> destinationImages = [
    {'name': 'Hebron', 'imagePath': 'assets/Images/Profiles/Tourist/9T.jpg'},
    {'name': 'Dead Sea', 'imagePath': 'assets/Images/Profiles/Tourist/10T.jpg'},
    {
      'name': 'Garden Cafe',
      'imagePath': 'assets/Images/Profiles/Tourist/11T.jpg'
    },
    {
      'name': 'Sufi Cafe',
      'imagePath': 'assets/Images/Profiles/Tourist/12T.jpg'
    },
  ];

  final Map<String, dynamic> destinationDetails = {
    'About':
        'Nablus, a Palestinian enclave, breathes history through its ancient streets and vibrant markets, embodying resilience and rich heritage.',
    'Category': 'Historical Site',
    'Opening Time': '09:00',
    'Closing Time': '23:00',
    'Working Days': [
      'Saturday',
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday'
    ],
    'Weather': '23°C',
    'Rating': '4.5',
    'Cost Level': 'Budget Friendly',
    'Sheltered': 'Yes', // No
    'Estimated Time': '2',
    'Services': [
      'Public restrooms are available',
      'Convenient access to a paid parking garage',
      'There are nearby gas stations',
      'Wheelchair ramps for enhanced accessibility',
      'Play areas for children are available',
      'Nearby restaurants for dining options',
      'Accessible health care centers are available',
      'Additional services are also provided'

      /// Additional services as needed
    ],
  };

  @override
  void initState() {
    super.initState();
    selectedImage = widget.destination['imagePath'];
  }

  @override
  void dispose() {
    super.dispose();
  }

  // A function to retrieve all of the destination details.
  Future<void> getDestinationDetails() async {
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
          'destinationName': widget.destination['name'],
        },
      );

      if (response.statusCode == 200) {
        // Success.
        // Jenan, here I need to retrieve three list-maps about the destination info, like the
        // format of the ones in my code called "destinationImages", "destinationDetails" and "ratings",
        // please refer to lines 22, 35, and 772 resoectively to see their format.
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

  // A function to retrieve the users review data.
  Future<void> getAllReviews() async {
    final url = Uri.parse('https://touristine.onrender.com/getAllReviews');

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
        // Jenan, I want to retrieve a list (map) in this format from your side - containing these info.
        /* final List<Map<String, dynamic>> reviews = [
          {
            'firstName': 'Israa',
            'lastName': 'Odeh',
            'stars': 5,
            'commentTitle': 'Amazing Experience',
            'commentContent':
                'The place is breathtaking, and the staff is incredibly friendly. I highly recommend it!',
          },
          {
            ///second user........
          },
          ////............................... other users' reviews in a similar way.
        ]; */
      } else if (response.statusCode == 500) {
        // Failed.
      } else {
        // ignore: use_build_context_synchronously
        // showCustomSnackBar(context, "Failed to fetch recommendations",
        //     bottomMargin: 0);
      }
    } catch (error) {
      print('Failed to fetch your review: $error');
    }
  }

  // A function to retrieve the destination latitude and longitude.
  Future<void> getDestinationLatLng() async {
    final url =
        Uri.parse('https://touristine.onrender.com/getDestinationLatLng');

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
      } else if (response.statusCode == 500) {
        // Failed.
      } else {
        // ignore: use_build_context_synchronously
        // showCustomSnackBar(context, "Failed to fetch recommendations",
        //     bottomMargin: 0);
      }
    } catch (error) {
      print('Failed to fetch the destination lat and lng: $error');
    }
  }

  List<Map<String, dynamic>> complaints = [
    {
      'title': 'Slow Service',
      'content': 'The service at the restaurant was incredibly slow.',
      'date': '25/10/2019',
      // There are images.
      'images': [
        {
          'url':
              'https://cdn.britannica.com/84/73184-050-05ED59CB/Sunflower-field-Fargo-North-Dakota.jpg'
        },
        {
          'url':
              'https://cdn.britannica.com/89/131089-050-A4773446/flowers-garden-petunia.jpg'
        },
        {
          'url':
              'https://cdn.britannica.com/89/131089-050-A4773446/flowers-garden-petunia.jpg'
        },
        {
          'url':
              'https://cdn.britannica.com/89/131089-050-A4773446/flowers-garden-petunia.jpg'
        },
      ],
      'status': 'Seen'
    },
    {
      'title': 'Dirty Room',
      'content': 'The hotel room was not clean upon arrival.',
      'date': '15/05/2020',
      // There are images.
      'images': [
        {
          'url':
              'https://www.petalrepublic.com/wp-content/uploads/2023/07/Heather.jpeg.webp'
        },
        {
          'url':
              'https://cdn.britannica.com/89/131089-050-A4773446/flowers-garden-petunia.jpg'
        },
      ],
      'status': 'Unseen'
    },
    {
      'title': 'Dirty Room',
      'content': 'The hotel room was not clean upon arrival.',
      'date': '20/11/2022',
      // There are no images attached to this complaint.
      'status': 'Unseen'
    },
    {
      'title': 'Noisy Environment',
      'content': 'The neighborhood was too noisy during the night.',
      'date': '17/09/2023',
      // There are no images attached to this complaint.
      'status': 'Seen'
    },
  ];

  // A Function to fetch user complaints from the backend.
  Future<void> fetchUserComplaints() async {
    final url = Uri.parse('https://touristine.onrender.com/get-complaints');

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
        // Retrieve the necessary elements for a complaint, including the required title,
        // content, and date, along with any accompanying images (if provided).

        // setState(() {
        //   complaints =
        //       List<Map<String, dynamic>>.from(json.decode(response.body));
        // });
      } else {
        print(
            'Failed to fetch complaints. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching complaints: $error');
    }
  }

  // A Function to fetch user images-uploads from the backend.
  Future<void> fetchUploadedImages() async {
    final url =
        Uri.parse('https://touristine.onrender.com/get-uploaded-images');

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
        // The format of the retreived data is as follows:
        /*
        List<Map<String, dynamic>> uploadedImages = [
          {
            'uploadID': 1,
            'keywords': 'General, Services',
            'date': '29/11/2023',
            'imageUrls': [
              'https://www.travelanddestinations.com/wp-content/uploads/2019/03/Switzerland-Landscapes-1170x780.jpg',
              'https://www.travelanddestinations.com/wp-content/uploads/2019/03/Zermatt-at-night.jpeg',
            ],
            'status': 'Approved'
          },
          {
            'uploadID': 2,
            'keywords': 'Buildings, Cracks',
            'date': '28/11/2023',
            'imageUrls': [
              'https://www.travelanddestinations.com/wp-content/uploads/2019/03/Colorful-summer-view-of-Lauterbrunnen-village.jpeg',
              'https://www.travelanddestinations.com/wp-content/uploads/2019/03/Lucerne-skyline.jpeg',
              'https://www.travelanddestinations.com/wp-content/uploads/2019/03/Chillion-Castle.jpeg',
              'https://www.travelanddestinations.com/wp-content/uploads/2019/03/Murren-landscapes.jpeg',
            ],
            'status': 'Rejected'
          },
          {
            'uploadID': 3,
            'keywords': 'General',
            'date': '07/10/2023',
            'imageUrls': [
              'https://www.travelanddestinations.com/wp-content/uploads/2019/03/Gruyeres.jpeg',
              'https://www.travelanddestinations.com/wp-content/uploads/2019/03/Geneva-fountain.jpeg',
              'https://www.travelanddestinations.com/wp-content/uploads/2018/04/Views-from-Grossmu%CC%88nster-Zurich.jpg',
              'https://www.petalrepublic.com/wp-content/uploads/2023/07/Heather.jpeg.webp',
              'https://www.petalrepublic.com/wp-content/uploads/2023/07/Heather.jpeg.webp',
            ],
            'status': 'Pending'
          },
          // Add more uploads as needed....
        ];
        */
      } else {
        print('Failed to fetch uploads. Status code: ${response.statusCode}');
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

  String _getFormattedDays(List<String> days) {
    return days.length >= 3 && days.length <= 7
        ? '${days.first} - ${days.last}'
        : days.join(', ');
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
        airDistance = Geolocator.distanceBetween(_currentPosition!.latitude,
                _currentPosition!.longitude, destLat, destLng) /
            1000;
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

          isRouteFetched = true;
          return {
            'distance': distance / 1000.0, // Convert meters to kilometers.
            'duration': duration / 3600, // Duration in hours.
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

  void fetchRouteClicked() async {
    try {
      await _getCurrentPosition();
      // Ensure that _getCurrentPosition has successfully obtained the position.
      if (_currentPosition != null) {
        final directions = await getDirections(_currentPosition!.latitude,
            _currentPosition!.longitude, destLat, destLng);

        if (directions['distance'] != -1.0) {
          distanceFromTo = directions['distance'];
          timeFromTo = directions['duration'];
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

  String formatDuration(int durationInSeconds) {
    Duration duration = Duration(seconds: durationInSeconds);
    int hours = duration.inHours;
    int minutes = (duration.inMinutes % 60);

    if (hours > 0 && minutes > 0) {
      return '$hours hours and $minutes minutes';
    } else if (hours > 0) {
      return '$hours hours';
    } else {
      return '$minutes minutes';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
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
                  Image.asset(
                    selectedImage,
                    width: 500,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 8),
                  ImagesList(
                    listOfImages: destinationImages,
                    onImageSelected: updateSelectedImage,
                  ),
                  const SizedBox(height: 8),
                  const TabBar(
                    isScrollable: true,
                    indicatorColor: Color(0xFF1E889E),
                    indicatorPadding: EdgeInsets.symmetric(horizontal: 15),
                    indicatorWeight: 3,
                    labelColor: Color(0xFF1E889E),
                    unselectedLabelColor: Color.fromARGB(182, 30, 137, 158),
                    labelStyle: TextStyle(fontSize: 30.0, fontFamily: 'Zilla'),
                    unselectedLabelStyle:
                        TextStyle(fontSize: 25.0, fontFamily: 'Zilla'),
                    tabs: [
                      Tab(text: 'About'),
                      Tab(text: 'Description'),
                      Tab(text: 'Services'),
                      Tab(text: 'Location'),
                      Tab(text: 'Reviews'),
                      Tab(text: 'Complaints'),
                      Tab(text: 'Images'),
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
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 2.0),
                                  child: Text(
                                    '${widget.destination['name']}',
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(125, 255, 255, 255),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Text(
                                  '${destinationDetails['Category']}',
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Gabriola',
                                    color: Color.fromARGB(195, 18, 83, 96),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${destinationDetails['About']}',
                            style: const TextStyle(
                              fontSize: 31,
                              fontFamily: 'Gabriola',
                              color: Color.fromARGB(255, 23, 103, 120),
                            ),
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
                                  '${destinationDetails['Weather']}',
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
                                  '${destinationDetails['Rating']}',
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
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.clock,
                              color: Colors.white,
                              size: 38,
                            ),
                            const SizedBox(width: 0.0),
                            Text(
                              '${destinationDetails['Opening Time']} - ${destinationDetails['Closing Time']}',
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
                                FontAwesomeIcons.calendar,
                                color: Colors.white,
                                size: 38,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 30.0),
                              child: Text(
                                _getFormattedDays(
                                    destinationDetails['Working Days']),
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
                                FontAwesomeIcons.dollarSign,
                                color: Colors.white,
                                size: 38,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 30.0),
                              child: Text(
                                destinationDetails['Cost Level'],
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
                                destinationDetails['Sheltered'] == ("Yes")
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
                                '${destinationDetails['Estimated Time']} hours',
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

  Widget _buildServicesTab() {
    ScrollController scrollController = ScrollController();

    // Define a list of icons for each service.
    List<IconData> serviceIcons = [
      FontAwesomeIcons.restroom,
      FontAwesomeIcons.squareParking,
      FontAwesomeIcons.gasPump,
      FontAwesomeIcons.wheelchair,
      FontAwesomeIcons.child,
      FontAwesomeIcons.utensils,
      // FontAwesomeIcons.paw,
      // FontAwesomeIcons.handHoldingHeart,
      FontAwesomeIcons.suitcaseMedical,
      FontAwesomeIcons.circleCheck
    ];

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
                          itemCount: destinationDetails['Services'].length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: (index ==
                                      destinationDetails['Services'].length - 1)
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
                                      index >= 8
                                          ? serviceIcons[7]
                                          : serviceIcons[index],
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
                                        '${destinationDetails['Services'][index]}',
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
                                    ? '0${timeFromTo.toStringAsFixed(2)} h away'
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
                            setState(() {
                              /////////////////////////////////////////////////////////////////////////
                            });
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
                                  dstLat: 32.2226667,
                                  dstLng: 35.262145,
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

  Widget _buildReviewsTab() {
    // Sample data for reviews.
    final List<Map<String, dynamic>> ratings = [
      {'stars': 5, 'count': 120},
      {'stars': 4, 'count': 80},
      {'stars': 3, 'count': 40},
      {'stars': 2, 'count': 20},
      {'stars': 1, 'count': 10},
    ];

    final List<Map<String, dynamic>> reviews = [
      {
        'firstName': 'Mohamed',
        'lastName': 'Ali',
        'stars': 5,
        'commentTitle': 'Amazing Experience',
        'commentContent':
            'The place is breathtaking, and the staff is incredibly friendly. I highly recommend it!',
        'date': '26/05/2001'
      },
      {
        'firstName': 'Fatima',
        'lastName': 'Khaled',
        'stars': 4,
        'commentTitle': 'Great Place',
        'commentContent':
            'A wonderful atmosphere and delicious food. I enjoyed every moment of my visit.',
        'date': '07/07/2007'
      },
      {
        'firstName': 'Yousef',
        'lastName': 'Saleh',
        'stars': 3,
        'commentTitle': 'Excellent Experience',
        'commentContent':
            'The inspiration here is amazing, and I love it. Looking forward to coming back!',
        'date': '15/05/2021'
      },
      {
        'firstName': 'Layla',
        'lastName': 'Mohamed',
        'stars': 4,
        'commentTitle': 'Beautiful Place',
        'commentContent':
            'You\'ll find success everywhere you go. The ambiance is truly remarkable.',
        'date': '12/08/2023'
      },
      {
        'firstName': 'Ali',
        'lastName': 'Noor',
        'stars': 2,
        'commentTitle': 'Needs Improvement',
        'commentContent':
            'Service was slow, and the place needs some improvements. Hope to see changes.',
        'date': '26/05/2023'
      },
      {
        'firstName': 'Nourhan',
        'lastName': 'Mustafa',
        'stars': 5,
        'commentTitle': 'Unique Experience',
        'commentContent':
            "I'm very happy with my experience here. Thank you for providing such a unique experience!",
        'date': '09/11/2022'
      },
      {
        'firstName': 'Hussein',
        'lastName': 'Ali',
        'stars': 3,
        'commentTitle': 'Good Place',
        'commentContent':
            "Not bad, but there are some aspects that could be improved. Overall, it's a decent place.",
        'date': '10/04/2011'
      },
      {
        'firstName': 'Sara',
        'lastName': 'Ahmed',
        'stars': 4,
        'commentTitle': 'Great View',
        'commentContent':
            'I love the stunning view and the peaceful atmosphere. It was a refreshing experience.',
        'date': '22/08/2021'
      },
      {
        'firstName': 'Omar',
        'lastName': 'Salah',
        'stars': 5,
        'commentTitle': 'Fantastic Experience',
        'commentContent':
            'The best experience I ever had! The service, ambiance, and everything exceeded my expectations.',
        'date': '16/05/2022'
      },
      {
        'firstName': 'Hala',
        'lastName': 'Hassan',
        'stars': 4,
        'commentTitle': 'Very Good',
        'commentContent':
            'A very good experience, I will definitely come back for another visit.',
        'date': '26/10/2021'
      },
    ];

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
                  SizedBox(
                    height: 150,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: ratings.map((rating) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Star icons.
                              Row(
                                children: List.generate(
                                  rating['stars'],
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
                                  color: const Color.fromARGB(59, 30, 137, 158),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: rating['count'] /
                                      ratings.fold<int>(
                                          0,
                                          (int sum, review) =>
                                              sum + (review['count'] as int)),

                                  // rating['count'] / ratings[0]['count'],
                                  child: Container(
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          167, 30, 137, 158),
                                      borderRadius: BorderRadius.circular(10.0),
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
                    'Total Ratings: ${ratings.fold<int>(0, (int sum, review) => sum + (review['count'] as int))}',
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
                        onPressed: () {
                          getAllReviews();
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddingReviewPage(
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
                                onPressed: () {
                                  fetchUserComplaints();
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
                                onPressed: () {
                                  fetchUploadedImages();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UploadedImagesPage(
                                        token: widget.token,
                                        destinationName:
                                            widget.destination['name'],
                                        // Dummy list of uploaded images (replace it with your actual data)
                                        uploadedImages: const [
                                          {
                                            'uploadID': 1,
                                            'keywords': 'General, Services',
                                            'date': '29/11/2023',
                                            'imageUrls': [
                                              'https://www.travelanddestinations.com/wp-content/uploads/2019/03/Switzerland-Landscapes-1170x780.jpg',
                                              'https://www.travelanddestinations.com/wp-content/uploads/2019/03/Zermatt-at-night.jpeg',
                                            ],
                                            'status': 'Pending'
                                          },
                                          {
                                            'uploadID': 2,
                                            'keywords': 'Buildings, Cracks',
                                            'date': '28/11/2023',
                                            'imageUrls': [
                                              'https://www.travelanddestinations.com/wp-content/uploads/2019/03/Colorful-summer-view-of-Lauterbrunnen-village.jpeg',
                                              'https://www.travelanddestinations.com/wp-content/uploads/2019/03/Lucerne-skyline.jpeg',
                                              'https://www.travelanddestinations.com/wp-content/uploads/2019/03/Chillion-Castle.jpeg',
                                              'https://www.travelanddestinations.com/wp-content/uploads/2019/03/Murren-landscapes.jpeg',
                                            ],
                                            'status': 'Approved'
                                          },
                                          {
                                            'uploadID': 3,
                                            'keywords': 'General',
                                            'date': '07/10/2023',
                                            'imageUrls': [
                                              'https://www.travelanddestinations.com/wp-content/uploads/2019/03/Gruyeres.jpeg',
                                              'https://www.travelanddestinations.com/wp-content/uploads/2019/03/Geneva-fountain.jpeg',
                                              'https://www.travelanddestinations.com/wp-content/uploads/2018/04/Views-from-Grossmu%CC%88nster-Zurich.jpg',
                                              'https://www.petalrepublic.com/wp-content/uploads/2023/07/Heather.jpeg.webp',
                                              'https://www.petalrepublic.com/wp-content/uploads/2023/07/Heather.jpeg.webp',
                                            ],
                                            'status': 'Rejected'
                                          },
                                          // Add more entries as needed
                                        ],
                                      ),
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
}
