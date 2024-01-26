import 'package:touristine/WebApplication/Notifications/snack_bar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class CracksViewerPage extends StatefulWidget {
  final String token;
  final String cityName;

  const CracksViewerPage(
      {super.key, required this.token, required this.cityName});

  @override
  _CracksViewerPageState createState() => _CracksViewerPageState();
}

class _CracksViewerPageState extends State<CracksViewerPage> {
  List<ScrollController> imageScrollControllers = [];
  List<Map<String, dynamic>> uploadedImages = [];
  bool isLoading = false;

  // A Function to fetch destination cracks from the backend.
  Future<void> getDestinationUploads() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('https://touristineapp.onrender.com/get-city-cracks');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {
          'cityName': widget.cityName,
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        // Jenan, I need to retrieve a List<Map> of the uploaded
        // cracks for the given destination name.
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<Map<String, dynamic>> fetchedUploads =
            List<Map<String, dynamic>>.from(responseBody['uploadedImages']);
        setState(() {
          uploadedImages = fetchedUploads;
        });
        print(uploadedImages);
        initializeScrollers();
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(
            context, 'Error retrieving destination uploaded cracks',
            bottomMargin: 0);
      }
    } catch (error) {
      if (mounted) {
        print('Error fetching uploads: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void initializeScrollers() {
    for (int i = 0; i < uploadedImages.length; i++) {
      imageScrollControllers.add(ScrollController());
    }
  }

  @override
  void initState() {
    super.initState();
    getDestinationUploads();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image:
                AssetImage("assets/Images/Profiles/Admin/mainBackground.jpg"),
            fit: BoxFit.fill,
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E889E)),
                ),
              )
            : uploadedImages.isEmpty
                ? Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 10,
                          child: Image.asset(
                            'assets/Images/Profiles/Tourist/emptyListTransparent.gif',
                            fit: BoxFit.fill,
                          ),
                        ),
                        const Positioned(
                          top: 440,
                          child: Text(
                            'No cracks found',
                            style: TextStyle(
                              fontSize: 40,
                              fontFamily: 'Gabriola',
                              color: Color.fromARGB(255, 23, 99, 114),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding:
                        const EdgeInsets.only(top: 10, right: 16, left: 16),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 16.0,
                              mainAxisSpacing: 16.0,
                              mainAxisExtent: 327),
                      itemCount: uploadedImages.length,
                      itemBuilder: (context, index) {
                        final imageInfo = uploadedImages[index];
                        final String destinationName =
                            imageInfo['destinationName'];
                        final String uploadingDate = imageInfo['date'];
                        final List<String> imageUrls =
                            List<String>.from(imageInfo['images']);

                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 0,
                                blurRadius: 10,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          child: Card(
                            color: Colors.white,
                            elevation: 5,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    destinationName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w100,
                                      fontFamily: 'Zilla',
                                      color: Color.fromARGB(255, 14, 63, 73),
                                    ),
                                  ),
                                  const Divider(
                                    color: Color.fromARGB(126, 14, 63, 73),
                                    thickness: 1,
                                  ),
                                  SizedBox(
                                      height: 200,
                                      child: Scrollbar(
                                        trackVisibility: imageUrls.length != 1
                                            ? true
                                            : false,
                                        thumbVisibility: imageUrls.length != 1
                                            ? true
                                            : false,
                                        controller:
                                            imageScrollControllers[index],
                                        child: ListView.builder(
                                          controller:
                                              imageScrollControllers[index],
                                          scrollDirection: Axis.horizontal,
                                          itemCount: imageUrls.length,
                                          itemBuilder: (context, imageIndex) {
                                            return Column(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    showImageDialog(context,
                                                        imageUrls[imageIndex]);
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12.0),
                                                      child: Stack(
                                                        children: [
                                                          Image.network(
                                                            imageUrls[
                                                                imageIndex],
                                                            width: 360,
                                                            height: 180,
                                                            fit: BoxFit.fill,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      )),
                                  const Divider(
                                    color: Color.fromARGB(126, 14, 63, 73),
                                    thickness: 1,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        uploadingDate,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Time New Roman',
                                          color:
                                              Color.fromARGB(255, 14, 63, 73),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }

  void showImageDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: SizedBox(
            width: 800,
            height: 500,
            child: Column(
              children: [
                SizedBox(
                  width: 800,
                  height: 436,
                  child: Image.network(
                    imagePath,
                    fit: BoxFit.fill,
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                          backgroundColor: const Color(0xFF1E889E),
                          textStyle: const TextStyle(
                            fontSize: 16.0,
                            fontFamily: 'Zilla',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
