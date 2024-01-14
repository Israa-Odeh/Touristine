import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class PlanPaths extends StatefulWidget {
  final double sourceLat;
  final double sourceLng;
  final List<LatLng> destinationsLatsLngs;

  const PlanPaths({
    super.key,
    required this.sourceLat,
    required this.sourceLng,
    required this.destinationsLatsLngs,
  });

  @override
  State<PlanPaths> createState() => _PlanPathsState();
}

class _PlanPathsState extends State<PlanPaths> {
  bool _isMounted = false;

  List<Color> polyLineColors = [
    const Color.fromARGB(255, 233, 128, 128),
    const Color.fromARGB(255, 220, 113, 149),
    const Color.fromARGB(255, 146, 139, 147),
    const Color.fromARGB(255, 125, 203, 129),
    const Color.fromARGB(226, 74, 86, 90),
    const Color.fromARGB(255, 104, 149, 194),
    const Color.fromARGB(255, 152, 93, 93),
    const Color.fromARGB(255, 111, 177, 186),
    const Color.fromARGB(255, 104, 202, 192),
    const Color.fromARGB(255, 113, 160, 115),
    const Color.fromARGB(255, 209, 241, 171),
    const Color.fromARGB(255, 146, 107, 95),
    const Color.fromARGB(255, 116, 125, 35),
    const Color.fromARGB(255, 207, 188, 126),
    const Color.fromARGB(255, 72, 62, 47),
    const Color(0xFFA1887F),
    const Color(0xFF90A4AE),
    const Color(0xFFB0BEC5),
    const Color(0xFFE57373),
    const Color.fromARGB(255, 163, 120, 134),
    const Color(0xFFBA68C8),
    const Color(0xFF9575CD),
    const Color(0xFF7986CB),
    const Color(0xFF64B5F6),
    const Color.fromARGB(255, 115, 194, 136),
    const Color.fromARGB(255, 95, 106, 107),
    const Color.fromARGB(82, 86, 212, 199),
    const Color(0xFF81C784),
    const Color(0xFFAED581),
  ];
  GoogleMapController? googleMapController;
  late LatLng sourceLatLng;
  late CameraPosition cameraPosition;
  List<Marker> markers = [];
  Set<Polyline> polylines = <Polyline>{};

  // Function to add a polyline using the given coordinates and color.
  void addPolyline(List<LatLng> coordinates, Color color) {
    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId("polylineId${polylines.length}"),
        color: color,
        points: coordinates,
        width: 5,
      );
      polylines.add(polyline);
    });
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
    _isMounted = true;

    sourceLatLng = LatLng(widget.sourceLat, widget.sourceLng);
    cameraPosition = CameraPosition(target: sourceLatLng, zoom: 9.2);

    Future.forEach(widget.destinationsLatsLngs, (LatLng destination) async {
      if (_isMounted) {
        List<LatLng> coordinates =
            await getDirections(sourceLatLng, destination);
        setState(() {
          addPolyline(coordinates, polyLineColors[polylines.length]);
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    markers.add(Marker(
      markerId: const MarkerId("SourceLocation"),
      position: sourceLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: const InfoWindow(title: "Your Location"),
    ));

    for (int i = 0; i < widget.destinationsLatsLngs.length; i++) {
      markers.add(Marker(
        markerId: MarkerId("DestinationLocation$i"),
        position: widget.destinationsLatsLngs[i],
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: "Destination $i"),
      ));
    }

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            polylines: polylines,
            markers: markers.toSet(),
            initialCameraPosition: cameraPosition,
            mapType: MapType.normal,
            onMapCreated: (mapcontroller) {
              googleMapController = mapcontroller;
            },
          ),
          Positioned(
            top: 10.0,
            left: 5.0,
            child: FloatingActionButton(
              heroTag: 'BackToPlanPlaces',
              onPressed: () {
                Navigator.of(context).pop();
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Icon(
                FontAwesomeIcons.arrowLeft,
                color: Color.fromARGB(255, 14, 65, 75),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
