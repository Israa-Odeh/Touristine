import 'package:touristine/WebApplication/Notifications/snack_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class LocationPage extends StatefulWidget {
  final String token;

  const LocationPage({super.key, required this.token});

  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  String? _currentAddress;
  Position? _currentPosition;
  bool isLocDetermined = false;

  // A function that sends a request to the server to retrieve the saved location.
  Future<void> fetchSavedLocation() async {
    final url = Uri.parse(
        'https://touristine.onrender.com/get-location'); // Replace with your API endpoint

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        setState(() {
          _currentAddress = responseData['address'];
          double latitude = double.parse(responseData['latitude']);
          double longitude = double.parse(responseData['longitude']);

          _currentPosition = Position(
            latitude: latitude,
            longitude: longitude,
            timestamp: DateTime.now(),
            accuracy: 0.0,
            altitude: 0.0,
            altitudeAccuracy: 0.0,
            heading: 0.0,
            headingAccuracy: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
          );
          isLocDetermined = true;
        });
        // print(_currentAddress);
        // print(_currentPosition!.latitude);
        // print(_currentPosition!.longitude);
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('error')) {
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
        }
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, "Failed to fetch your location",
            bottomMargin: 0);
        print(response.statusCode);
      }
    } catch (error) {
      print('Failed to fetch location: $error');
    }
  }

  Future<void> sendAndSaveLocation() async {
    final url = Uri.parse(
        'https://touristine.onrender.com/location-accquistion'); // Replace this with your Node.js server URL.

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {
          'latitude': _currentPosition!.latitude.toString(), // Double Value.
          'longitude': _currentPosition!.longitude.toString(), // Double Value.
          'address': _currentAddress!, // String Value.
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('message') &&
            responseData['message'] == 'updated') {
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, "Your location has been updated",
              bottomMargin: 310);
        }
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('error')) {
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, "An error has occured",
              bottomMargin: 310);
        }
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, "An error has occurred", bottomMargin: 310);
      }
    } catch (error) {
      // Catch block to handle any errors during the request.
      print('Failed to save the location. Error: $error');
    }
  }

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
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress = '${place.locality}';
        isLocDetermined = true;
      });
      // Call sendAndSaveLocation once the address is determined.
      sendAndSaveLocation();
    }).catchError((e) {
      debugPrint(e);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchSavedLocation(); // Fetch location details when the page initializes.
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -24,
          bottom: 0,
          left: -100,
          right: -100,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/Images/Profiles/Tourist/locationBackground.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 120),
                  Image.asset('assets/Images/Profiles/Tourist/Address.gif'),

                  const SizedBox(height: 15),

                  // Address Information.
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          spreadRadius: 8,
                          blurRadius: 20,
                          offset: const Offset(0, 0),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Location:',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Times New Roman',
                            color: Color.fromARGB(255, 61, 80, 89),
                          ),
                        ),
                        Text(
                          isLocDetermined
                              ? ' ${_currentAddress ?? ""}'
                              : " Undetermined",
                          style: const TextStyle(
                            fontSize: 30,
                            fontFamily: 'Times New Roman',
                            color: Color.fromARGB(255, 35, 154, 178),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () {
                      _getCurrentPosition(); // Trigger obtaining the current location.
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 13,
                      ),
                      backgroundColor: const Color(0xFF1E889E),
                      textStyle: const TextStyle(
                        fontSize: 30,
                        fontFamily: 'Zilla',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    child: const Text('Get Location'),
                  ),
                  // const SizedBox(height: 50),
                  const SizedBox(height: 65),
                  Padding(
                    padding: const EdgeInsets.only(right: 320.0),
                    child: IconButton(
                      icon: const FaIcon(
                        FontAwesomeIcons.arrowLeft,
                        color: Color(0xFF1E889E),
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
