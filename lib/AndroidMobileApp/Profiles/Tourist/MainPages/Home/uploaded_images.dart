import 'package:touristine/AndroidMobileApp/Notifications/snack_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

// ignore: must_be_immutable
class UploadedImagesPage extends StatefulWidget {
  final String token;
  final String destinationName;
  List<Map<String, dynamic>> uploadedImages;
  final int minImagesToShowScrollbar = 3;

  UploadedImagesPage(
      {super.key,
      required this.token,
      required this.destinationName,
      required this.uploadedImages});

  @override
  _UploadedImagesPageState createState() => _UploadedImagesPageState();
}

class _UploadedImagesPageState extends State<UploadedImagesPage> {
  List<ScrollController> imageScrollControllers = [];

  // A function to delete a specific upload.
  Future<void> deleteUploadedImages(String uploadId, int index) async {
    final url =
        Uri.parse('https://touristine.onrender.com/delete-uploads/$uploadId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {
          'destinationName': widget.destinationName,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('message')) {
          setState(() {
            widget.uploadedImages.removeAt(index);
          });
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, "The upload has been deleted",
              bottomMargin: 320);
        } else {
          print('No message keyword found in the response');
        }
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, responseData['error'], bottomMargin: 320);
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Error deleting your upload',
            bottomMargin: 320);
      }
    } catch (error) {
      print('Error deleting the upload: $error');
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize the imageScrollControllers list with a controller for each card
    for (int i = 0; i < widget.uploadedImages.length; i++) {
      imageScrollControllers.add(ScrollController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding:
            EdgeInsets.only(top: widget.uploadedImages.isNotEmpty ? 0.0 : 24),
        child: Container(
          decoration: BoxDecoration(
            image: widget.uploadedImages.isNotEmpty
                ? const DecorationImage(
                    image: AssetImage(
                        "assets/Images/Profiles/Tourist/homeBackground.jpg"),
                    fit: BoxFit.cover,
                  )
                : const DecorationImage(
                    image: AssetImage(
                        "assets/Images/Profiles/Tourist/emptyListBackground.png"),
                    fit: BoxFit.cover,
                  ),
          ),
          child: widget.uploadedImages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/Images/Profiles/Tourist/emptyList.gif',
                        fit: BoxFit.cover,
                      ),
                      const Text(
                        'No uploads found',
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
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: widget.uploadedImages.length,
                    itemBuilder: (context, index) {
                      final imageInfo = widget.uploadedImages[index];
                      final List<String> keywords =
                          List<String>.from(imageInfo['keywords']);
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
                          color: const Color.fromARGB(68, 30, 137, 158),
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (keywords.length <= 2)
                                  Row(
                                    children: [
                                      const Text(
                                        'Categories: ',
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w100,
                                            fontFamily: 'Zilla',
                                            color: Color.fromARGB(
                                                255, 14, 63, 73)),
                                      ),
                                      Text(
                                        keywords.join(', '),
                                        style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w100,
                                            fontFamily: 'Zilla',
                                            color: Color.fromARGB(
                                                255, 14, 63, 73)),
                                      ),
                                    ],
                                  ),
                                if (keywords.length > 2)
                                  const Text(
                                    'Categories: ',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w100,
                                        fontFamily: 'Zilla',
                                        color: Color.fromARGB(255, 14, 63, 73)),
                                  ),
                                if (keywords.length > 2)
                                  const SizedBox(height: 10),
                                if (keywords.length > 2)
                                  Text(
                                    keywords.join(', '),
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w100,
                                        fontFamily: 'Zilla',
                                        color: Color.fromARGB(255, 14, 63, 73)),
                                  ),
                                const Divider(
                                  color: Color.fromARGB(126, 14, 63, 73),
                                  thickness: 2,
                                ),
                                SizedBox(
                                  height: 200,
                                  child: imageUrls.length >=
                                          widget.minImagesToShowScrollbar
                                      ? Scrollbar(
                                          trackVisibility: true,
                                          thumbVisibility: true,
                                          controller:
                                              imageScrollControllers[index],
                                          child: ListView.builder(
                                            controller:
                                                imageScrollControllers[index],
                                            scrollDirection: Axis.horizontal,
                                            itemCount: imageUrls.length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8.0,
                                                    left: 8.0,
                                                    top: 8.0,
                                                    bottom: 15.0),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                  child: Image.network(
                                                    imageUrls[index],
                                                    width: 160,
                                                    height: 110,
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      : ListView.builder(
                                          controller:
                                              imageScrollControllers[index],
                                          scrollDirection: Axis.horizontal,
                                          itemCount: imageUrls.length,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                                child: Image.network(
                                                  imageUrls[index],
                                                  width: 160,
                                                  height: 110,
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                ),
                                const Divider(
                                  color: Color.fromARGB(126, 14, 63, 73),
                                  thickness: 2,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      uploadingDate,
                                      style: const TextStyle(
                                          fontSize: 19.5,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Time New Roman',
                                          color:
                                              Color.fromARGB(255, 14, 63, 73)),
                                    ),
                                    Text(
                                      imageInfo['status'],
                                      style: const TextStyle(
                                          fontSize: 19.5,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Time New Roman',
                                          color:
                                              Color.fromARGB(255, 14, 63, 73)),
                                    ),
                                  ],
                                ),
                                Visibility(
                                  visible: imageInfo['status'].toLowerCase() ==
                                          'approved'
                                      ? false
                                      : true,
                                  child: const Divider(
                                    color: Color.fromARGB(126, 14, 63, 73),
                                    thickness: 2,
                                  ),
                                ),
                                Visibility(
                                  visible: imageInfo['status'].toLowerCase() ==
                                          'approved'
                                      ? false
                                      : true,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        color: const Color(0xFF1E889E),
                                        icon: const FaIcon(
                                            FontAwesomeIcons.trash),
                                        onPressed: () async {
                                          print(widget.uploadedImages[index]
                                              ['_id']);
                                          await deleteUploadedImages(
                                              widget.uploadedImages[index]
                                                  ['_id'],
                                              index);
                                        },
                                      ),
                                    ],
                                  ),
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
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
            bottom: widget.uploadedImages.isNotEmpty ? 0.0 : 10.0),
        child: FloatingActionButton(
          heroTag: 'GoBack',
          onPressed: () {
            Navigator.of(context).pop();
          },
          backgroundColor: widget.uploadedImages.isNotEmpty
              ? const Color.fromARGB(129, 30, 137, 158)
              : const Color(0xFF1E889E),
          elevation: 0,
          child: const Icon(FontAwesomeIcons.arrowLeft),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
