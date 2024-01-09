import 'package:touristine/AndroidMobileApp/Profiles/Tourist/MainPages/Home/destination_view.dart';
import 'package:touristine/AndroidMobileApp/Profiles/Tourist/MainPages/planMaker/plan_paths.dart';
import 'package:touristine/AndroidMobileApp/Notifications/snack_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class PlanPlacesPage extends StatefulWidget {
  final String token;
  final List<Map<String, dynamic>> planContents;

  const PlanPlacesPage(
      {super.key, required this.token, required this.planContents});
  @override
  _PlanPlacesPageState createState() => _PlanPlacesPageState();
}

class _PlanPlacesPageState extends State<PlanPlacesPage> {
  @override
  void initState() {
    super.initState();
  }

  Position? _currentPosition;
  bool isLocDetermined = false;
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
    // ignore: use_build_context_synchronously
    // showCustomSnackBar(context, "Please wait for a moment",
    //     bottomMargin: 310);
    return true;
  }

  Future<void> getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        isLocDetermined = true;
        // print(_currentPosition);
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            Container(
              // margin: const EdgeInsets.only(top: 24),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/Images/Profiles/Tourist/homeBackground.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: PlanPlacesCards(
                  places: widget.planContents,
                  token: widget.token,
                ),
              ),
            ),
            Positioned(
              bottom: 26.0,
              left: 230.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: ElevatedButton(
                  onPressed: () async {
                    await getCurrentPosition();
                    if (isLocDetermined) {
                      List<LatLng> destinationsLatLng = [];

                      for (var place in widget.planContents) {
                        double latitude = double.parse(place['latitude']);
                        double longitude = double.parse(place['longitude']);
                        destinationsLatLng.add(LatLng(latitude, longitude));
                      }
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PlanPaths(
                              sourceLat: _currentPosition!.latitude,
                              sourceLng: _currentPosition!.longitude,
                              destinationsLatsLngs: destinationsLatLng),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 13,
                    ),
                    backgroundColor: const Color.fromARGB(203, 30, 137, 158),
                    textStyle: const TextStyle(
                      fontSize: 25,
                      fontFamily: 'Zilla',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  child: const Text('Show Paths'),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(10.0),
          child: FloatingActionButton(
            heroTag: 'ReturnBack',
            onPressed: () {
              Navigator.of(context).pop();
            },
            backgroundColor: const Color.fromARGB(203, 30, 137, 158),
            elevation: 0,
            child: const Icon(FontAwesomeIcons.arrowLeft),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }
}

class PlanPlacesCards extends StatefulWidget {
  final String token;
  final List<Map<String, dynamic>> places;

  const PlanPlacesCards({super.key, required this.token, required this.places});

  @override
  _PlanPlacesCardsState createState() => _PlanPlacesCardsState();
}

class _PlanPlacesCardsState extends State<PlanPlacesCards> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: widget.places.isNotEmpty
              ? (widget.places[_currentPage]['activityList'] as List).length ==
                      1
                  ? 380
                  : 500
              : 0,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.places.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return PlaceCard(
                  details: widget.places[index], token: widget.token);
            },
          ),
        ),
        if (widget.places.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 150),
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: ElevatedButton(
                  onPressed: _currentPage > 0
                      ? () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 13,
                    ),
                    backgroundColor: const Color(0xFF1E889E),
                    textStyle: const TextStyle(
                      fontSize: 22,
                      fontFamily: 'Zilla',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const FaIcon(FontAwesomeIcons.arrowLeft),
                ),
              ),
              const SizedBox(width: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: ElevatedButton(
                  onPressed: _currentPage < widget.places.length - 1
                      ? () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 13,
                    ),
                    backgroundColor: const Color(0xFF1E889E),
                    textStyle: const TextStyle(
                      fontSize: 22,
                      fontFamily: 'Zilla',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const FaIcon(FontAwesomeIcons.arrowRight),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class PlaceCard extends StatefulWidget {
  final String token;
  final Map<String, dynamic> details;

  const PlaceCard({super.key, required this.token, required this.details});

  @override
  _PlaceCardState createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard> {
  Map<String, dynamic> destinationDetails = {};
  List<Map<String, dynamic>> destinationImages = [];
  Map<String, int> ratings = {};

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
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();

    List<Map<String, dynamic>> activityList =
        List<Map<String, dynamic>>.from(widget.details['activityList']);

    return Card(
      margin: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.details['placeName'].length <= 20)
            Container(
              color: const Color(0xFF1E889E),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.details['placeName'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 23.0,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${widget.details['startTime']} - ${widget.details['endTime']}',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 19,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (widget.details['placeName'].length > 20)
            Container(
              color: const Color(0xFF1E889E),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.details['placeName'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 23.0,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      '${widget.details['startTime']} - ${widget.details['endTime']}',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 19,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: ScrollbarTheme(
                data: ScrollbarThemeData(
                  thumbColor:
                      MaterialStateProperty.all(const Color(0xFF1E889E)),
                  trackColor: MaterialStateProperty.all(
                      const Color(0xFF1E889E).withOpacity(0.5)),
                ),
                child: Scrollbar(
                  controller: scrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  thickness: 6.0,
                  radius: const Radius.circular(20.0),
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            var data = activityList[index];
                            return Container(
                              margin: EdgeInsets.only(
                                bottom: index == activityList.length - 1 &&
                                        activityList.length >= 3
                                    ? 50.0
                                    : (activityList.length == 2 &&
                                                widget.details['placeName']
                                                        .length >
                                                    20) &&
                                            index == activityList.length - 1
                                        ? 50
                                        : 0,
                              ),
                              child: TimelineTile(
                                alignment: TimelineAlign.manual,
                                lineXY: 0.08,
                                isFirst: data == activityList.first,
                                indicatorStyle: const IndicatorStyle(
                                  width: 20,
                                  color: Color(0xFF1E889E),
                                  padding: EdgeInsets.all(0),
                                ),
                                beforeLineStyle: const LineStyle(
                                  color: Colors.grey,
                                  thickness: 3.5,
                                ),
                                endChild: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8.0,
                                    right: 40.0,
                                    top: 50,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        data['title']!,
                                        style: const TextStyle(
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Times New Roman',
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      SizedBox(
                                        height: 46.0,
                                        child: SingleChildScrollView(
                                          child: Text(
                                            data['description']!,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontFamily: 'Time New Roman',
                                              color: Color.fromARGB(
                                                  255, 91, 91, 91),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: activityList.length,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 80.0,
                    width: 130.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        widget.details['imagePath'],
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await getDestinationDetails(
                            widget.details['placeName']);

                        Map<String, dynamic> destination = {
                          'name': widget.details['placeName'],
                          'image': widget.details['imagePath']
                        };

                        // ignore: use_build_context_synchronously
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DestinationDetails(
                              destination: destination,
                              token: widget.token,
                              destinationDetails: destinationDetails,
                              destinationImages: destinationImages,
                              ratings: ratings,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 13,
                        ),
                        backgroundColor: const Color(0xFF1E889E),
                        textStyle: const TextStyle(
                          fontSize: 25,
                          fontFamily: 'Zilla',
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      icon: const FaIcon(FontAwesomeIcons.folderOpen),
                      label: const Text('View'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
