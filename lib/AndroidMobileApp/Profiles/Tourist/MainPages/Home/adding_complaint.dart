import 'package:touristine/AndroidMobileApp/Notifications/snack_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';

class AddingComplaintsPage extends StatefulWidget {
  final String token;
  final String destinationName;

  const AddingComplaintsPage({
    super.key,
    required this.token,
    required this.destinationName,
  });

  @override
  _AddingComplaintsPageState createState() => _AddingComplaintsPageState();
}

class _AddingComplaintsPageState extends State<AddingComplaintsPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  List<File> selectedImages = []; // List to store selected images

  // Function to validate the form.
  bool validateForm() {
    if (titleController.text.isEmpty) {
      showCustomSnackBar(context, 'Please enter the complaint title',
          bottomMargin: 410);
      return false;
    }

    if (contentController.text.isEmpty) {
      showCustomSnackBar(context, 'Please enter the complaint content',
          bottomMargin: 410);
      return false;
    }

    if (titleController.text.length < 5) {
      showCustomSnackBar(context, 'Title must have at least 5 characters',
          bottomMargin: 410);
      return false;
    }

    if (contentController.text.length < 20) {
      showCustomSnackBar(context, 'Content must have at least 20 chars',
          bottomMargin: 410);
      return false;
    }
    // Form is valid.
    return true;
  }

  // A function to send complaint data to the backend.
  Future<void> sendComplaint() async {
    String currentDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    final url = Uri.parse('https://touristineapp.onrender.com/send-complaint');

    // Create a multi-part request.
    final request = http.MultipartRequest('POST', url);

    // Add headers to the request.
    request.headers['Authorization'] = 'Bearer ${widget.token}';

    // Add complaint data to the request.
    request.fields['title'] = titleController.text;
    request.fields['content'] = contentController.text;
    request.fields['date'] = currentDate;
    request.fields['destinationName'] = widget.destinationName;

    // Add images to the request.
    if (selectedImages.isNotEmpty) {
      for (int i = 0; i < selectedImages.length; i++) {
        List<int> imageBytes = selectedImages[i].readAsBytesSync();
        String fileName = selectedImages[i].path.split('/').last;
        final image = http.MultipartFile.fromBytes(
          'images',
          imageBytes,
          filename: fileName,
        );
        request.files.add(image);
      }
    } else {
      // If no images, add an empty list.
      request.fields['images'] = '[]';
    }

    // Send the request.
    try {
      final response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        // Success.
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Thanks for sharing your complaint',
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
        showCustomSnackBar(context, 'Error storing your complaint',
            bottomMargin: 0);
      }
    } catch (error) {
      print('Error sending complaint: $error');
    }
  }

  // Function to open image picker
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImages.add(File(pickedFile.path));
      });
    }
  }

  // Function to delete selected image
  void _deleteImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: !selectedImages.isNotEmpty ? 50 : 30),
              Center(
                child: Image.asset(
                  'assets/Images/Profiles/Tourist/AddComplaints.gif',
                  height: !selectedImages.isNotEmpty ? 250 : 150,
                  width: !selectedImages.isNotEmpty ? 250 : 150,
                  // fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: !selectedImages.isNotEmpty ? 60 : 20),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Complaint Title',
                  labelStyle: TextStyle(
                    fontSize: 25,
                    color: Color(0xFF1E889E),
                    fontWeight: FontWeight.bold,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF1E889E)),
                  ),
                ),
                maxLength: 34,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Complaint Content',
                  labelStyle: TextStyle(
                    fontSize: 25,
                    color: Color(0xFF1E889E),
                    fontWeight: FontWeight.bold,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF1E889E)),
                  ),
                ),
                minLines: 1,
                maxLines: !selectedImages.isNotEmpty ? 7 : 4,
                maxLength: 1000,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              // Display selected images.
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
                                    Image.file(
                                      selectedImages[index],
                                      width: 174,
                                      height: 174,
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
                                          onPressed: () => _deleteImage(index),
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
                                  Image.file(
                                    selectedImages[index],
                                    width: 174,
                                    height: 174,
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
                                        onPressed: () => _deleteImage(index),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                ),
              Visibility(
                  visible: selectedImages.length >= 3,
                  child: const SizedBox(
                    height: 10,
                  )),
              Center(
                  child: ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  backgroundColor: const Color(0xFF1E889E),
                  textStyle: const TextStyle(
                    fontSize: 25,
                    fontFamily: 'Zilla',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.photoFilm,
                      size: 30,
                    ),
                    SizedBox(width: 20),
                    Text('Add Image'),
                  ],
                ),
              )),
            ],
          ),
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
                  size: 30,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (validateForm()) {
                  // print('Title: ${titleController.text}');
                  // print('Content: ${contentController.text}');
                  // print('Selected Images: $selectedImages');
                  await sendComplaint();
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                backgroundColor: const Color(0xFF1E889E),
                textStyle: const TextStyle(
                  fontSize: 25,
                  fontFamily: 'Zilla',
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Add Complaint'),
            ),
          ],
        ),
      ],
    );
  }
}
