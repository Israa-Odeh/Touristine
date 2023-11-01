import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:touristine/Notifications/SnackBar.dart';

// Import the http package.
import 'package:http/http.dart' as http;

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

  Future<void> sendAndSaveLocation() async {
    final url = Uri.parse(
        'http://your-nodejs-server-url/location-accquistion'); // Replace this with your Node.js server URL.

    try {
      final response = await http.post(
        url,
        body: {
          'latitude': _currentPosition!.latitude.toString(), // Double Value.
          'longitude': _currentPosition!.longitude.toString(), // Double Value.
          'address': _currentAddress!,  // String Value.
        },
      );

      if (response.statusCode == 200) {
        // Successful request.
        print('Data sent and saved successfully');
      } else {
        // Request failed
        // showCustomSnackBar(context, 'Failed to sign up, please try again');
        print('Failed to send and save data. Error: ${response.reasonPhrase}');
      }
    } catch (error) {
      // Catch block to handle any errors during the request.
      print('Failed to send and save data. Error: $error');
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showCustomSnackBar(
          context, "Location services are disabled. Please enable the services",
          bottomMargin: 310);
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showCustomSnackBar(context, "Location permissions are denied",
            bottomMargin: 310);
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      showCustomSnackBar(context,
          "Location permissions are permanently denied, we cannot request permissions",
          bottomMargin: 310);

      return false;
    }
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
    }).catchError((e) {
      debugPrint(e);
    });
  }

  @override
  void initState() {
    super.initState();
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
                      sendAndSaveLocation(); // Send and save data to the backend.
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
