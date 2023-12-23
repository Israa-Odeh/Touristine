import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:touristine/Notifications/SnackBar.dart';
import 'package:http/http.dart' as http;
import 'package:touristine/Profiles/Admin/MainPages/UserInteractions/complaints.dart';

class UserInteractionsPage extends StatefulWidget {
  final String token;

  const UserInteractionsPage({super.key, required this.token});

  @override
  _UserInteractionsPageState createState() => _UserInteractionsPageState();
}

class _UserInteractionsPageState extends State<UserInteractionsPage> {
  List<Map<String, dynamic>> reviews = [];
  List<bool> isLoadingList = [];
  bool isLoading = true;

  Map<String, String> destinations = {
    'Al-Aqsa Mousqe': 'assets/Images/Profiles/Admin/T1.jpg',
    'Bethlehem': 'assets/Images/Profiles/Admin/T2.jpg',
    'Old City of Yaffa': 'assets/Images/Profiles/Admin/3T.jpg',
    'Gaza': 'assets/Images/Profiles/Admin/4T.jpg',
  };

  @override
  void initState() {
    super.initState();
    isLoading = true;
    fetchDestinations();

    // This must be placed inside the fetchDestinations function.
    isLoadingList = List.generate(destinations.length, (index) => false);
  }

  // Retrieve destinations that have uploads, reviews, or images.
  void fetchDestinations() async {
    if (!mounted) return;
    final url = Uri.parse('https://touristine.onrender.com/get-destinations');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        // Jenan, the retreived map will be of the following format:
        /*
            Map<String, String> destinations = {
              'Al-Aqsa Mousqe': 'assets/Images/Profiles/Admin/T1.jpg',
              'Bethlehem': 'assets/Images/Profiles/Admin/T2.jpg',
              'Old City of Yaffa': 'assets/Images/Profiles/Admin/3T.jpg',
              'Gaza': 'assets/Images/Profiles/Admin/4T.jpg',
        };
        */
        // final Map<String, String> destinationsData =
        //     Map<String, String>.from(json.decode(response.body));
        // setState(() {
        //   destinations = destinationsData;
        // });
      } else {
        // Israa, handle other error cases.
        print('Error: Failed to fetch destinations');
      }
    } catch (error) {
      print('Error: $error');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> getDestinationReviews(
      String destinationName, int currentCardIndex) async {
    if (!mounted) return;

    print("getDestinationReviews for $destinationName");

    setState(() {
      isLoadingList[currentCardIndex] = true;
    });

    final url =
        Uri.parse('https://touristine.onrender.com/get-destination-reviews');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {
          'destinationName': destinationName,
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        // Jenan, the retreived list<map> will be of the following format:
        // List<Map<String, dynamic>> reviews with fields like the ones below.
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('reviews')) {
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
          showCustomSnackBar(context, 'Reviews are not available',
              bottomMargin: 0);
        } else {
          showCustomSnackBar(context, responseData['error'], bottomMargin: 310);
        }
      } else {
        showCustomSnackBar(context, 'Error retrieving destination reviews',
            bottomMargin: 0);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          isLoadingList[currentCardIndex] = false;
        });
      }
      print('Failed to fetch destination reviews: $error');
    } finally {
      if (mounted) {
        setState(() {
          isLoadingList[currentCardIndex] = false;
        });
      }
    }
  }

  Widget _buildCard(
      String destinationName, String imagePath, int currentCardIndex) {
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
                child: Image.asset(
                  imagePath,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.fill,
                ),
              ),
              Positioned(
                top: 7.0,
                child: ElevatedButton(
                  onPressed: () async {
                    await getDestinationReviews(
                        destinationName, currentCardIndex);
                    print('Star icon clicked for card $currentCardIndex!');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    shape: const CircleBorder(),
                  ),
                  child: isLoadingList[currentCardIndex]
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color.fromARGB(255, 255, 255, 255)))
                      : Material(
                          shape: const CircleBorder(),
                          color: Colors.transparent,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 5,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Icon(
                                FontAwesomeIcons.solidStar,
                                color: Color.fromARGB(239, 255, 255, 255),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16),
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  destinationName,
                  style: const TextStyle(
                    fontFamily: 'Andalus',
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Divider(
                  thickness: 3,
                  color: Color.fromARGB(80, 19, 83, 96),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildButton(
                          'Complaints',
                          FontAwesomeIcons.faceAngry,
                          20,
                          const Color.fromARGB(255, 231, 231, 231),
                          const Color.fromARGB(255, 0, 0, 0), () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ComplaintsListPage(
                                  token: widget.token,
                                  destinationName: destinationName)),
                        );
                      }),
                      _buildButton(
                          'Uploads',
                          FontAwesomeIcons.photoFilm,
                          40,
                          const Color(0xFF1E889E),
                          const Color.fromARGB(255, 255, 255, 255), () {
                        print('Uploads Button tapped!');
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
      String buttonText,
      IconData buttonIcon,
      double horizontalHeight,
      Color btnColor,
      Color btnTxtColor,
      VoidCallback onPressedFunction) {
    return ElevatedButton(
      onPressed: onPressedFunction,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalHeight,
          vertical: 10,
        ),
        backgroundColor: btnColor,
        textStyle: const TextStyle(
          fontSize: 22,
          fontFamily: 'Zilla',
          fontWeight: FontWeight.w300,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
      child: Text(
        buttonText,
        style: TextStyle(color: btnTxtColor),
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
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF1E889E)),
                  ),
                )
              : destinations.isEmpty
                  ? Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 80),
                          Image.asset(
                            'assets/Images/Profiles/Tourist/emptyListTransparent.gif',
                            fit: BoxFit.cover,
                          ),
                          const Text(
                            'No Interactions found',
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
                      padding: const EdgeInsets.all(16),
                      children: destinations.entries.map((entry) {
                        final destinationName = entry.key;
                        final imagePath = entry.value;
                        final currentCardIndex =
                            destinations.keys.toList().indexOf(destinationName);
                        return Column(
                          children: [
                            _buildCard(
                                destinationName, imagePath, currentCardIndex),
                            const SizedBox(height: 10),
                          ],
                        );
                      }).toList(),
                    ),
        ],
      ),
    );
  }
}
