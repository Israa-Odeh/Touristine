import 'package:touristine/AndroidMobileApp/Notifications/snack_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class UploadedCracksPage extends StatefulWidget {
  final String token;
  final String destinationId;
  final String destinationName;

  const UploadedCracksPage(
      {super.key,
      required this.token,
      required this.destinationId,
      required this.destinationName});

  @override
  _UploadedCracksPageState createState() => _UploadedCracksPageState();
}

class _UploadedCracksPageState extends State<UploadedCracksPage> {
  List<ScrollController> imageScrollControllers = [];
  List<List<bool>> selectedImages = [];
  bool isLoading = false;

  List<Map<String, dynamic>> uploadedImages = [];

  // A Function to fetch destination uploads from the backend.
  Future<void> getDestinationUploads() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    final url =
        Uri.parse('https://touristine.onrender.com/get-destination-cracks');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {
          'destinationId': widget.destinationId,
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        // Jenan, I need to retrieve a List<Map> of the uploaded
        // cracks for the given destination id, the format will
        // be as the one at line 247.
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
      selectedImages
          .add(List<bool>.filled(uploadedImages[i]['images'].length, false));
    }
  }

  void approveAnUpload(int index) async {
    List<String> selectedUrls = [];
    // Collect selected image URLs.
    for (int i = 0; i < selectedImages[index].length; i++) {
      if (selectedImages[index][i]) {
        selectedUrls.add(uploadedImages[index]['images'][i]);
      }
    }

    // Check if any images are selected
    if (selectedUrls.isEmpty) {
      showCustomSnackBar(context, "Please pick the approved images",
          bottomMargin: 0);
      return;
    }

    print("The upload ID: ${uploadedImages[index]['id']}");
    print("The selected Images URLs: $selectedUrls");

    if (!mounted) return;
    try {
      final url =
          Uri.parse('https://touristine.onrender.com/approve-uploaded-crack');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {
          'uploadId': uploadedImages[index]['id'],
          'approvedImages': jsonEncode(selectedUrls),
          'destinationId': widget.destinationId,
        },
      );
      if (!mounted) return;

      if (response.statusCode == 200) {
        // Jenan, in case of success the upload status must be updated to "Approved",
        // and the upload will be counted as a crack.
        setState(() {
          uploadedImages.removeWhere(
              (upload) => upload['id'] == uploadedImages[index]['id']);
        });

        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, "The Images have been approved",
            bottomMargin: 0);
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
      }
    } catch (error) {
      print('Error approving the upload: $error');
    }
  }

  void rejectAnUpload(String uploadId) async {
    bool? confirmDeletion = await showConfirmationDialog(context);
    if (confirmDeletion == true) {
      print(uploadId);
      if (!mounted) return;
      try {
        final url =
            Uri.parse('https://touristine.onrender.com/reject-uploaded-crack');

        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Bearer ${widget.token}',
          },
          body: {
            'uploadId': uploadId,
            'destinationName': widget.destinationName,
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            uploadedImages.removeWhere((upload) => upload['id'] == uploadId);
          });
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, "The upload has been rejected",
              bottomMargin: 0);
        } else {
          final Map<String, dynamic> responseData = json.decode(response.body);
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
        }
      } catch (error) {
        print('Error rejecting the upload: $error');
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

  @override
  void initState() {
    super.initState();
    getDestinationUploads();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: uploadedImages.isNotEmpty ? 0.0 : 24),
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image:
                  AssetImage("assets/Images/Profiles/Admin/mainBackground.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF1E889E)),
                  ),
                )
              : uploadedImages.isEmpty
                  ? Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 140),
                          Image.asset(
                            'assets/Images/Profiles/Tourist/emptyListTransparent.gif',
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
                      padding:
                          const EdgeInsets.only(top: 10, right: 16, left: 16),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                        ),
                        itemCount: uploadedImages.length,
                        itemBuilder: (context, index) {
                          final imageInfo = uploadedImages[index];
                          final List<String> keywords =
                              List<String>.from(imageInfo['keywords']);
                          final String uploadingDate = imageInfo['date'];
                          final List<String> imageUrls =
                              List<String>.from(imageInfo['images']);
                          final String status = imageInfo['status'];

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
                                    if (keywords.length <= 2)
                                      Row(
                                        children: [
                                          const Text(
                                            'Category: ',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w100,
                                              fontFamily: 'Zilla',
                                              color: Color.fromARGB(
                                                  255, 14, 63, 73),
                                            ),
                                          ),
                                          Text(
                                            keywords.join(', '),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w100,
                                              fontFamily: 'Zilla',
                                              color: Color.fromARGB(
                                                  255, 14, 63, 73),
                                            ),
                                          ),
                                        ],
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
                                                      showImageDialog(
                                                          context,
                                                          imageUrls[
                                                              imageIndex]);
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12.0),
                                                        child: Stack(
                                                          children: [
                                                            Image.network(
                                                              imageUrls[
                                                                  imageIndex],
                                                              width: 360,
                                                              height: 180,
                                                              fit: BoxFit.fill,
                                                            ),
                                                            Positioned(
                                                              top: 0,
                                                              right: 0,
                                                              child: Checkbox(
                                                                value: selectedImages[
                                                                        index][
                                                                    imageIndex],
                                                                onChanged:
                                                                    (value) {
                                                                  setState(() {
                                                                    selectedImages[index]
                                                                            [
                                                                            imageIndex] =
                                                                        value!;
                                                                  });
                                                                },
                                                                activeColor:
                                                                    const Color(
                                                                        0xFF1E889E),
                                                              ),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                        Text(
                                          status,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Time New Roman',
                                            color:
                                                Color.fromARGB(255, 14, 63, 73),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(
                                      color: Color.fromARGB(126, 14, 63, 73),
                                      thickness: 2,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            // Reject Button.
                                            ElevatedButton(
                                              onPressed: () {
                                                rejectAnUpload(
                                                    uploadedImages[index]
                                                        ['id']);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                  vertical: 20,
                                                ),
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 231, 231, 231),
                                                textStyle: const TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: 'Zilla',
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              child: const Text(
                                                'Reject Upload',
                                                style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 0, 0, 0)),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            // Approve Button.
                                            ElevatedButton(
                                              onPressed: () {
                                                approveAnUpload(index);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                  vertical: 20,
                                                ),
                                                backgroundColor:
                                                    const Color(0xFF1E889E),
                                                textStyle: const TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: 'Zilla',
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              child: const Text('Approve'),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Checkbox(
                                              value: selectedImages[index]
                                                  .every(
                                                      (selected) => selected),
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedImages[index]
                                                      .fillRange(
                                                          0,
                                                          selectedImages[index]
                                                              .length,
                                                          value ?? false);
                                                });
                                              },
                                              activeColor:
                                                  const Color(0xFF1E889E),
                                            ),
                                            const Text(''),
                                          ],
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      persistentFooterButtons: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: IconButton(
                icon: const FaIcon(
                  FontAwesomeIcons.arrowLeft,
                  color: Color(0xFF1E889E),
                  size: 20,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void showImageDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: SizedBox(
            width: 500,
            height: 324,
            child: Column(
              children: [
                SizedBox(
                  width: 500,
                  height: 260,
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
                            vertical: 10,
                          ),
                          backgroundColor: const Color(0xFF1E889E),
                          textStyle: const TextStyle(
                            fontSize: 22.0,
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
