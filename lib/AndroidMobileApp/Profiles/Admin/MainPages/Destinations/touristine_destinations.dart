import 'package:touristine/AndroidMobileApp/Profiles/Admin/MainPages/Destinations/destination_view.dart';
import 'package:touristine/AndroidMobileApp/Profiles/Tourist/MainPages/planMaker/custom_bottom_sheet.dart';
import 'package:touristine/AndroidMobileApp/Notifications/snack_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class TouristineDestinations extends StatefulWidget {
  final String token;

  const TouristineDestinations({super.key, required this.token});

  @override
  _TouristineDestinationsState createState() => _TouristineDestinationsState();
}

class _TouristineDestinationsState extends State<TouristineDestinations> {
  bool isLoading = true;
  List<Map<String, dynamic>> destinationsList = [];

  @override
  void initState() {
    super.initState();
    fetchAddedDestinations();
  }

  void fetchAddedDestinations() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    final url =
        Uri.parse('https://touristineapp.onrender.com/get-added-destinations');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {
          'filter': selectedFilter == "Select a Filter"
              ? 'all'
              : selectedFilter.toLowerCase().replaceAll(" ", ""),
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        // Jenan, here I need to retrieve a List<Map> of destinations
        // similar to the format shown at line 19.
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        List<dynamic> destinationsData = jsonResponse['destinationsList'];
        destinationsList = List<Map<String, dynamic>>.from(destinationsData);
        print(destinationsList);
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Error retrieving the destinations',
            bottomMargin: 0);
      }
    } catch (error) {
      if (mounted) {
        print('Error fetching the destinations: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> deleteDestination(String destinationId) async {
    bool? confirmDeletion = await showConfirmationDialog(context);

    if (confirmDeletion == true) {
      if (!mounted) return;
      final url = Uri.parse(
          'https://touristineapp.onrender.com/delete-added-destination/$destinationId');

      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Bearer ${widget.token}'
          },
        );

        if (!mounted) return;

        if (response.statusCode == 200) {
          setState(() {
            destinationsList.removeWhere(
                (destination) => destination['id'] == destinationId);
          });
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, 'The destination has been deleted',
              bottomMargin: 0);
        } else if (response.statusCode == 500) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
        } else {
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, 'Error deleting the destination',
              bottomMargin: 0);
        }
      } catch (error) {
        print('Error deleting destination: $error');
      }
    }
  }

  Future<void> getDestinationInfo(String destinationId) async {
    if (!mounted) return;
    final url =
        Uri.parse('https://touristineapp.onrender.com/get-destination-info');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {
          'destinationId': destinationId,
        },
      );
      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final Map<String, dynamic> destinationInfo =
            responseData['destinationMap'];
        print(destinationInfo);

        // Handle all these stuff in the dest generator *O*.
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Error retrieving the destination',
            bottomMargin: 0);
      }
    } catch (error) {
      throw Exception('Error fetching destination details: $error');
    }
  }

  Map<String, dynamic> destinationDetails = {};
  List<Map<String, dynamic>> destinationImages = [];
  // A function to retrieve all of the destination details.
  Future<void> getDestinationDetails(Map<String, dynamic> destination) async {
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
          'destinationName': destination['name'],
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

        print('Destination Images: $destinationImages');
        print('Destination Details: $destinationDetails');

        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DestinationDetails(
              destination: destination,
              token: widget.token,
              destinationDetails: destinationDetails,
              destinationImages: destinationImages,
            ),
          ),
        );
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

  Future<bool?> showConfirmationDialog(
    BuildContext context, {
    String dialogMessage = 'Are you sure you want to delete this destination?',
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion',
              style: TextStyle(
                  fontFamily: 'Zilla Slab Light',
                  fontWeight: FontWeight.bold,
                  fontSize: 25)),
          content: Text(
            dialogMessage,
            style: const TextStyle(fontFamily: 'Andalus', fontSize: 25),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 22.0,
                  fontFamily: 'Zilla',
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                "Delete",
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

  Widget buildCard(String destinationId, String destinationName,
      String imagePath, String city, String category) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  imagePath,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.fill,
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: ClipOval(
                  child: Material(
                    color: Colors.transparent,
                    child: Ink(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(69, 0, 0, 0),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          FontAwesomeIcons.penToSquare,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () async {
                          await getDestinationInfo(destinationId);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.8),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        destinationName,
                        style: const TextStyle(
                          fontFamily: 'Andalus',
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const Divider(
                        thickness: 3,
                        color: Color.fromARGB(80, 19, 83, 96),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            city,
                            style: const TextStyle(
                              fontFamily: 'Zilla',
                              fontSize: 18,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Text(
                            getPlaceCategory(category),
                            style: const TextStyle(
                              fontFamily: 'Zilla',
                              fontSize: 18,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                buildButton(
                  () async {
                    await deleteDestination(destinationId);
                  },
                  () async {
                    Map<String, dynamic> destination = {
                      'name': destinationName,
                      'image': imagePath
                    };
                    await getDestinationDetails(destination);
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> filteringList = [
    'All',
    'Jerusalem',
    'Nablus',
    'Ramallah',
    'Bethlehem',
    'Coastal Areas',
    'Mountains',
    'National Parks',
    'Major Cities',
    'Countryside',
    'Historical Sites',
    'Religious Landmarks',
    'Aquariums',
    'Zoos',
    'Others'
  ];

  String selectedFilter = 'Select a Filter';

  void showFiltersBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return CustomBottomSheet(itemsList: filteringList, height: 400);
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          selectedFilter = value;
        });
        fetchAddedDestinations();
      }
    });
  }

  Widget buildButton(
    VoidCallback onTrashPressed,
    VoidCallback onViewPressed,
  ) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 231, 231, 231),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15.0),
            bottomRight: Radius.circular(15.0),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const FaIcon(
                  FontAwesomeIcons.solidTrashCan,
                  size: 24,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                onPressed: onTrashPressed,
              ),
              IconButton(
                icon: const Icon(
                  FontAwesomeIcons.anglesRight,
                  size: 24,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                onPressed: onViewPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/Images/Profiles/Admin/mainBackground.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isLoading)
                Padding(
                  padding: const EdgeInsets.only(
                      right: 20, left: 20.0, top: 15, bottom: 10),
                  child: ElevatedButton(
                    onPressed: showFiltersBottomSheet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 231, 231, 231),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Text(
                              selectedFilter,
                              style: const TextStyle(
                                color: Color.fromARGB(163, 0, 0, 0),
                                fontSize: 22,
                              ),
                            ),
                          ),
                          const FaIcon(
                            FontAwesomeIcons.list,
                            color: Color.fromARGB(100, 0, 0, 0),
                            size: 25,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF1E889E)),
                        ),
                      )
                    : destinationsList.isEmpty
                        ? Center(
                            child: Column(
                              children: [
                                const SizedBox(height: 40),
                                Image.asset(
                                  'assets/Images/Profiles/Tourist/emptyListTransparent.gif',
                                  fit: BoxFit.cover,
                                ),
                                const Text(
                                  'No destinations found',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Gabriola',
                                    color: Color.fromARGB(255, 23, 99, 114),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 16),
                            children: destinationsList.map((destinationData) {
                              final destinationId = destinationData['id'];
                              final destinationName = destinationData['name'];
                              final imagePath = destinationData['image'];
                              final city = destinationData['city'];
                              final category = destinationData['category'];
                              return Column(
                                children: [
                                  buildCard(destinationId, destinationName,
                                      imagePath, city, category),
                                  const SizedBox(height: 10),
                                ],
                              );
                            }).toList(),
                          ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
