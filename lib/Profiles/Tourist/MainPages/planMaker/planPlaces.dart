import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:touristine/Notifications/SnackBar.dart';
import 'package:touristine/Profiles/Tourist/MainPages/PlanMaker/planPaths.dart';

class PlanPlacesPage extends StatefulWidget {
  final List<Map<String, dynamic>> planContents;

  const PlanPlacesPage({super.key, required this.planContents});
  @override
  _PlanPlacesPageState createState() => _PlanPlacesPageState();
}

class _PlanPlacesPageState extends State<PlanPlacesPage> {
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
    if (!isLocDetermined) {
      // ignore: use_build_context_synchronously
      showCustomSnackBar(context, "Please wait for a moment",
          bottomMargin: 310);
    }
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
                child: PlanPlacesCards(places: widget.planContents),
              ),
            ),
            Positioned(
              bottom: 26.0,
              left: 230.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: ElevatedButton(
                  onPressed: () {
                    getCurrentPosition();
                    if (isLocDetermined) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PlanPaths(
                            sourceLat: _currentPosition!.latitude,
                            sourceLng: _currentPosition!.longitude,
                            destinationsLatsLngs: const [
                              // These will be passed dynamically.
                              LatLng(32.0846676, 35.3296158), // Qusra
                              LatLng(32.3194102, 35.0239948), // Tulkarem
                              LatLng(32.0494, 34.7584), // Yaffa
                              LatLng(31.8611, 35.4618), // Jericoh
                              LatLng(32.2227, 35.2621), // Nablus
                              LatLng(32.3211, 35.3700), // Tubas
                              LatLng(31.7054, 35.2024), // Bethlehem
                              LatLng(31.5799, 35.0999), // Hebron
                            ],
                          ),
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
  final List<Map<String, dynamic>> places;

  const PlanPlacesCards({super.key, required this.places});

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
              return PlaceCard(details: widget.places[index]);
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

class PlaceCard extends StatelessWidget {
  final Map<String, dynamic> details;

  const PlaceCard({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();

    List<Map<String, dynamic>> activityList = details['activityList'];

    return Card(
      margin: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: const Color(0xFF1E889E),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    details['placeName'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 23.0,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${details['startTime']} - ${details['endTime']}',
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
                      child: Image.asset(
                        details['imagePath'],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: ElevatedButton.icon(
                      onPressed: () {},
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
