import 'package:touristine/WebApplication/Notifications/snack_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class LocationLiveTracking extends StatefulWidget {
  final double srcLat;
  final double scrLng;
  final double dstLat;
  final double dstLng;

  const LocationLiveTracking(
      {super.key,
      required this.srcLat,
      required this.scrLng,
      required this.dstLat,
      required this.dstLng});

  @override
  State<LocationLiveTracking> createState() => _LocationLiveTrackingState();
}

class _LocationLiveTrackingState extends State<LocationLiveTracking> {
  GoogleMapController? googleMapController;

  late LatLng sourceLatLng;
  late LatLng destinationLatLng;

  CameraPosition cameraPosition =
      const CameraPosition(target: LatLng(31.9037633, 35.2034183), zoom: 10.2);

  List<LatLng> routeCoordinates = [];

  List<Marker> markers = [];

  StreamSubscription<Position>? positionStream;

  Set<Polyline> polylines = Set<Polyline>();

  // Function to add a polyline using the given coordinates
  void addPolyline(List<LatLng> coordinates, Color color) {
    setState(() {
      // Clear the previous polylines
      polylines.clear();

      Polyline polyline = Polyline(
        polylineId: const PolylineId("polylineId"),
        color: color,
        points: coordinates,
        width: 5,
      );

      // Add the new polyline to the set of polylines
      polylines.add(polyline);
    });
  }

  // A function to continuously get the user current location.
  initializePositionStream() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // ignore: use_build_context_synchronously
      showCustomSnackBar(context, "Location services are disabled",
          bottomMargin: 0);
      return;
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
    }
    if (permission == LocationPermission.whileInUse) {
      positionStream =
          Geolocator.getPositionStream().listen((Position? position) {
        markers.add(Marker(
            markerId: const MarkerId("MyCurrentLocation"),
            position: LatLng(position!.latitude, position.longitude)));
        // continuously refresh the marker position on the map UI.
        googleMapController!.animateCamera(CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude)));
        setState(() {});
      });
    }
  }

  Future<List<LatLng>> getDirections(LatLng origin, LatLng destination) async {
    String apiKey = "AIzaSyACRpyMRSxrAcO00IGbMzYI0N4zKxUPWg4";
    String apiUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=driving&key=$apiKey";

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      List<LatLng> points = [];

      if (decoded["routes"].isNotEmpty) {
        List<dynamic> steps = decoded["routes"][0]["legs"][0]["steps"];
        for (var step in steps) {
          points.add(LatLng(
            step["start_location"]["lat"],
            step["start_location"]["lng"],
          ));

          if (step["polyline"] != null && step["polyline"]["points"] != null) {
            List<LatLng> decodedPoints =
                decodePolyline(step["polyline"]["points"]);
            points.addAll(decodedPoints);
          }

          points.add(LatLng(
            step["end_location"]["lat"],
            step["end_location"]["lng"],
          ));
        }
      }

      return points;
    } else {
      throw Exception('Failed to load directions');
    }
  }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }

  @override
  void initState() {
    sourceLatLng = LatLng(widget.srcLat, widget.scrLng);
    destinationLatLng = LatLng(widget.dstLat, widget.dstLng);

    getDirections(sourceLatLng, destinationLatLng)
        .then((List<LatLng> coordinates) {
      setState(() {
        routeCoordinates = coordinates;
        addPolyline(routeCoordinates, const Color.fromARGB(255, 158, 62, 30));
      });
    });
    initializePositionStream();
    super.initState();
  }

  @override
  void dispose() {
    positionStream!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    markers.add(Marker(
      markerId: const MarkerId("SourceLocation"),
      position: sourceLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: const InfoWindow(title: "Start Point"),
    ));

    markers.add(Marker(
      markerId: const MarkerId("DestinationLocation"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: const InfoWindow(title: "End Point"),
    ));

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 22.0),
            child: GoogleMap(
              polylines: polylines,
              markers: markers.toSet(),
              initialCameraPosition: cameraPosition,
              mapType: MapType.normal,
              onMapCreated: (mapcontroller) {
                googleMapController = mapcontroller;
              },
            ),
          ),
          Positioned(
            top: 26.0,
            left: 5.0,
            child: FloatingActionButton(
              heroTag: 'BackToDestinationView',
              onPressed: () {
                positionStream!.cancel();
                Navigator.of(context).pop();
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Icon(FontAwesomeIcons.arrowLeft,
                  color: Color.fromARGB(255, 158, 62, 30)),
            ),
          ),
        ],
      ),
    );
  }
}
