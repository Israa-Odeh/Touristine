import 'package:touristine/WebApplication/Notifications/snack_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'dart:convert';

import 'package:uuid/uuid.dart';

class UploadingImagesPage extends StatefulWidget {
  final String token;
  final String destinationName;

  const UploadingImagesPage(
      {super.key, required this.token, required this.destinationName});

  @override
  _UploadingImagesPageState createState() => _UploadingImagesPageState();
}

class _UploadingImagesPageState extends State<UploadingImagesPage> {
  List<Uint8List> selectedImages = []; // List to store selected images.
  List<String> selectedKeywords = []; // List to store selected keywords.

  // Function to validate the form.
  bool validateForm() {
    if (selectedImages.isEmpty) {
      showCustomSnackBar(context, 'Please add at least one image',
          bottomMargin: 0);
      return false;
    }
    if (selectedKeywords.isEmpty) {
      showCustomSnackBar(context, 'Please select at least one category',
          bottomMargin: 0);
      return false;
    }
    if (selectedKeywords.contains('Cracks') && selectedKeywords.length > 1) {
      showCustomSnackBar(context,
          'Select only the cracks category for analysis purposes, without adding others',
          bottomMargin: 0);
      return false;
    }
    return true;
  }

  // A function to send uploaded images data to the backend.
  Future<void> uploadImages() async {
    String currentDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    final url = Uri.parse('https://touristine.onrender.com/upload-images');

    // Create a multi-part request.
    final request = http.MultipartRequest('POST', url);

    // Add headers to the request.
    request.headers['Content-Type'] = 'multipart/form-data';
    request.headers['Authorization'] = 'Bearer ${widget.token}';

    // Add some data to the request.
    request.fields['date'] = currentDate;
    request.fields['destinationName'] = widget.destinationName;

    // Add keywords to the request.
    request.fields['keywords'] = selectedKeywords.join(', ');

    const uuid = Uuid();
    // Add images to the request.
    for (int i = 0; i < selectedImages.length; i++) {
      Uint8List imageBytes = selectedImages[i];
      String fileName = 'UploadedImage_${uuid.v4()}.jpg';

      final image = http.MultipartFile.fromBytes(
        'images',
        imageBytes,
        filename: fileName,
      );
      request.files.add(image);
    }

    // Send the request.
    try {
      final response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Thanks for sharing these images!',
            bottomMargin: 0);
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('error')) {
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
        } else {
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, responseData['message'], bottomMargin: 0);
        }
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Failed to upload the images',
            bottomMargin: 0);
      }
    } catch (error) {
      print('Error uploading images: $error');
    }
  }

  // Function to open image picker.
  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      var image = await pickedFile.readAsBytes();
      setState(() {
        selectedImages.add(image);
      });
    }
  }

  // Function to delete selected image.
  void deleteImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  // Function to handle keywords selection.
  void onChipSelected(String keyword) {
    setState(() {
      if (selectedKeywords.contains(keyword)) {
        selectedKeywords.remove(keyword);
      } else {
        selectedKeywords.add(keyword);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    const List<String> availableKeywords = ['General', 'Services', 'Cracks'];

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Center(
                    child: Image.asset(
                        'assets/Images/Profiles/Tourist/ImagesUpload.gif',
                        fit: BoxFit.cover),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Wrap(
                      children: availableKeywords.map((keyword) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 4.0, right: 4),
                          child: FilterChip(
                            label: Text(
                              keyword,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 15),
                            ),
                            selected: selectedKeywords.contains(keyword),
                            onSelected: (_) => onChipSelected(keyword),
                            selectedColor:
                                const Color.fromARGB(31, 151, 151, 151),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  color: Color(0xFF1E889E)), // Border color
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (selectedImages.isNotEmpty)
                    SizedBox(
                      height: 200,
                      child: selectedImages.length >= 3
                          ? Scrollbar(
                              trackVisibility: true,
                              thumbVisibility: true,
                              thickness: 5,
                              controller: scrollController,
                              child: ListView.builder(
                                controller: scrollController,
                                scrollDirection: Axis.horizontal,
                                itemCount: selectedImages.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Stack(
                                      children: [
                                        Image.memory(
                                          selectedImages[index],
                                          width: 195,
                                          height: 195,
                                          fit: BoxFit.cover,
                                        ),
                                        Positioned(
                                          top: -5,
                                          right: -5,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color.fromARGB(
                                                          255, 20, 94, 108)
                                                      .withOpacity(1),
                                                  blurRadius: 1,
                                                  spreadRadius: -10,
                                                  offset: const Offset(0, 0),
                                                ),
                                              ],
                                            ),
                                            child: IconButton(
                                              icon: const FaIcon(
                                                FontAwesomeIcons.xmark,
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                                size: 20.0,
                                              ),
                                              onPressed: () =>
                                                  deleteImage(index),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: selectedImages.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Stack(
                                    children: [
                                      Image.memory(
                                        selectedImages[index],
                                        width: 195,
                                        height: 195,
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        top: -5,
                                        right: -5,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color.fromARGB(
                                                        255, 20, 94, 108)
                                                    .withOpacity(1),
                                                blurRadius: 1,
                                                spreadRadius: -10,
                                                offset: const Offset(0, 0),
                                              ),
                                            ],
                                          ),
                                          child: IconButton(
                                            icon: const FaIcon(
                                              FontAwesomeIcons.xmark,
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              size: 20.0,
                                            ),
                                            onPressed: () => deleteImage(index),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  const SizedBox(height: 10),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 14.0, left: 6),
                      child: ElevatedButton(
                        onPressed: pickImage,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 20,
                          ),
                          backgroundColor: const Color(0xFF1E889E),
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontFamily: 'Zilla',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.photoFilm,
                              size: 25,
                            ),
                            SizedBox(width: 20),
                            Text('Add Image'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
            ElevatedButton(
              onPressed: () async {
                if (validateForm()) {
                  await uploadImages();
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 20,
                ),
                backgroundColor: const Color(0xFF1E889E),
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontFamily: 'Zilla',
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Upload Images'),
            ),
          ],
        ),
      ],
    );
  }
}
