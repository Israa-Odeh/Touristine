import 'package:touristine/AndroidMobileApp/Profiles/Admin/MainPages/Cracks/uploaded_cracks.dart';
import 'package:touristine/AndroidMobileApp/Notifications/snack_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CracksAnalysisPage extends StatefulWidget {
  final String token;

  const CracksAnalysisPage({super.key, required this.token});

  @override
  _CracksAnalysisPageState createState() => _CracksAnalysisPageState();
}

class _CracksAnalysisPageState extends State<CracksAnalysisPage> {
  bool isLoading = false;

  List<Map<String, dynamic>> destinations = [];

  @override
  void initState() {
    super.initState();
    isLoading = true;
    fetchDestinations();
  }

  // Retrieve destinations that have cracks.
  void fetchDestinations() async {
    if (!mounted) return;
    final url = Uri.parse(
        'https://touristine.onrender.com/get-destinations-with-cracks');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // Extract the 'destinations' data.
        List<Map<String, dynamic>> destinationsData =
            List<Map<String, dynamic>>.from(responseData['destinations']);
        setState(() {
          destinations = destinationsData;
        });
        print(destinations);
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Error retrieving destinations with cracks',
            bottomMargin: 0);
      }
    } catch (error) {
      if (mounted) {
        print('Failed to fetch destinations with cracks: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
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
                          const SizedBox(height: 98),
                          Image.asset(
                            'assets/Images/Profiles/Tourist/emptyListTransparent.gif',
                            fit: BoxFit.cover,
                          ),
                          const Text(
                            'No cracks found',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Gabriola',
                              color: Color.fromARGB(255, 23, 99, 114),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: destinations.map((destination) {
                        final id = destination['id'];
                        final destinationName = destination['name'];
                        final imagePath = destination['image'];
                        final numberOfUploads = destination['numberOfUploads'];

                        return Column(
                          children: [
                            _buildCard(destinationName, imagePath, id,
                                numberOfUploads),
                            const SizedBox(height: 10),
                          ],
                        );
                      }).toList(),
                    ),
        ],
      ),
    );
  }

  // A function to reject all uploads for a specific destination - from the admin side.
  Future<void> deleteDestination(String destinationId) async {
    bool? confirmDeletion = await showConfirmationDialog(
      context,
      dialogMessage: 'Are you sure you want to reject all the uploaded cracks?',
    );

    if (confirmDeletion == true) {
      if (!mounted) return;
      try {
        final url = Uri.parse(
            'https://touristine.onrender.com/delete-destinations-with-cracks');

        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Bearer ${widget.token}',
          },
          body: {'destinationId': destinationId},
        );
        if (response.statusCode == 200) {
          // Jenan, delete all the uploaded cracks for the passed destination (entirely).
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, 'The cracks have been rejected',
              bottomMargin: 0);
          removeDestination(destinationId);
        } else {
          final Map<String, dynamic> responseData = json.decode(response.body);
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
        }
      } catch (error) {
        print('Error rejecting the uploaded cracks: $error');
      }
    }
  }

  Future<bool?> showConfirmationDialog(
    BuildContext context, {
    String dialogMessage = 'Are you sure you want to reject this upload?',
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Rejection',
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
                'Reject',
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

  void removeDestination(String destinationId) {
    setState(() {
      destinations
          .removeWhere((destination) => destination['id'] == destinationId);
    });
  }

  Widget _buildCard(String destinationName, String imagePath,
      String currentCardIndex, int numOfUploads) {
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
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.fill,
                ),
              ),
              Positioned(
                top: 7.0,
                child: ElevatedButton(
                  onPressed: () async {
                    showCracksDialog(destinationName, numOfUploads);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    shape: const CircleBorder(),
                  ),
                  child: Material(
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
                          FontAwesomeIcons.circleInfo,
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
                          'View Cracks',
                          FontAwesomeIcons.faceAngry,
                          80,
                          const Color.fromARGB(255, 231, 231, 231),
                          const Color.fromARGB(255, 0, 0, 0), () {
                        // Handle the function here.....
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UploadedCracksPage(
                                token: widget.token,
                                destinationId: currentCardIndex,
                                destinationName: destinationName),
                          ),
                        );
                      }),
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: IconButton(
                          icon: const FaIcon(
                            FontAwesomeIcons.trash,
                            color: Color.fromARGB(210, 32, 32, 32),
                            size: 28,
                          ),
                          onPressed: () {
                            deleteDestination(currentCardIndex);
                          },
                        ),
                      ),
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

  void showCracksDialog(String destinationName, int numberOfUploads) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Uploads Number',
              style: TextStyle(
                  fontFamily: 'Zilla Slab Light',
                  fontWeight: FontWeight.bold,
                  fontSize: 22)),
          content: Text(
            '$destinationName has $numberOfUploads ${(numberOfUploads > 1) ? "uploads, each containing cracks." : "upload containing cracks."}',
            style: const TextStyle(fontFamily: 'Andalus', fontSize: 24),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 22.0,
                  fontFamily: 'Zilla',
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
          ],
        );
      },
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
}
