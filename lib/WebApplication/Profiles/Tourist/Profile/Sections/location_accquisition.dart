import 'package:touristine/WebApplication/Notifications/snack_bar.dart';
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
              bottomMargin: 0);
        }
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('error')) {
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, "An error has occured",
              bottomMargin: 0);
        }
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, "An error has occurred", bottomMargin: 0);
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
          bottomMargin: 0);
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, "Location permissions are denied",
            bottomMargin: 0);
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Location permissions are permanently denied, we cannot request permissions,
      // ignore: use_build_context_synchronously
      showCustomSnackBar(context, "Location permissions permanently denied",
          bottomMargin: 0);

      return false;
    }
    // ignore: use_build_context_synchronously
    showCustomSnackBar(context, "Please wait for a moment", bottomMargin: 0);
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 30),
                Image.asset(
                  'assets/Images/Profiles/Tourist/Address.gif',
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 80),

                // Address Information.
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 100),
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Color(0xFF1E889E),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Determine Your Location',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Gabriola',
                            color: Color.fromARGB(255, 39, 51, 57),
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
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Location:',
                      style: TextStyle(
                        fontSize: 20,
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
                        fontSize: 18,
                        fontFamily: 'Times New Roman',
                        color: Color.fromARGB(255, 35, 154, 178),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    _getCurrentPosition(); // Trigger obtaining the current location.
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 100,
                      vertical: 20,
                    ),
                    backgroundColor: const Color(0xFF1E889E),
                    textStyle: const TextStyle(
                      fontSize: 22,
                      fontFamily: 'Zilla',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  child: const Text('Get Location'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
