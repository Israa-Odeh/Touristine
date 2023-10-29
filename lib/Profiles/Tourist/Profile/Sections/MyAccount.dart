import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// Import the http package.
import 'package:http/http.dart' as http;
import 'package:touristine/Notifications/SnackBar.dart';
import 'package:touristine/components/CustomField.dart';

class AccountPage extends StatefulWidget {
  final String? firstName;
  final String? lastName;
  final String? password;
  final File? profileImage;

  AccountPage({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.password,
    this.profileImage,
  }) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  // Textfields Controllers.
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final passwordController = TextEditingController();

  File? _image;

  @override
  void initState() {
    super.initState();
    // Set received data to the corresponding text fields and profile image.
    firstNameController.text = widget.firstName!;
    lastNameController.text = widget.lastName!;
    passwordController.text = widget.password!;
    setState(() {
      _image = widget.profileImage;
    });
  }

  // Functions Section.
  bool isInputEmpty() {
    return firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        passwordController.text.isEmpty;
  }

  bool isPasswordValid(String password) {
    return password.length >= 8 && password.length <= 30;
  }

  bool isNameValid(String name) {
    final nameLengthRange = RegExp(r'^[A-Za-z]{2,20}$');
    return nameLengthRange.hasMatch(name);
  }

  Future<void> sendAndSaveData() async {
    final url = Uri.parse('http://your-nodejs-server-url/edit-account');
    final request = http.MultipartRequest('POST', url);

// Add the image to the request if it exists.
    if (_image != null) {
      List<int> imageBytes = _image!.readAsBytesSync(); // Read file as bytes.
      String fileName = _image!.path.split('/').last; // Extract file name

      final imageFile = http.MultipartFile.fromBytes(
        'profileImage', // Field name for the image on the server.
        imageBytes,
        filename: fileName,
      );
      request.files.add(imageFile);
    }

    // Add other form data.
    request.fields['firstName'] = firstNameController.text;
    request.fields['lastName'] = lastNameController.text;
    request.fields['password'] = passwordController.text;

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        // Handle a successful response.
      } else {
        showCustomSnackBar(context, 'Failed to update, please try again',
            bottomMargin: 457);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void editProfileInfo() {
    // Check if any data has changed
    bool isDataChanged = widget.firstName != firstNameController.text ||
        widget.lastName != lastNameController.text ||
        widget.password != passwordController.text ||
        widget.profileImage != _image;

    if (isDataChanged) {
      if (isInputEmpty()) {
        showCustomSnackBar(context, 'Please fill in all the fields',
            bottomMargin: 457);
      } else if (!isNameValid(firstNameController.text)) {
        showCustomSnackBar(context, 'Invalid first name: 2-20 characters only',
            bottomMargin: 457);
      } else if (!isNameValid(lastNameController.text)) {
        showCustomSnackBar(context, 'Invalid last name: 2-20 characters only',
            bottomMargin: 457);
      } else if (!isPasswordValid(passwordController.text)) {
        showCustomSnackBar(context, 'Password must contain 8-30 chars',
            bottomMargin: 457);
      } else {
        sendAndSaveData();
      }
    } else {
      showCustomSnackBar(context, 'No modifications detected',
          bottomMargin: 457);
    }
  }

  Future<void> _getImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -110,
          bottom: 0,
          left: -110,
          right: -110,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/Images/Profiles/Tourist/AccountBackground.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),
                  ProfilePicture(
                    image: _image,
                    onImageChanged: (File? newImage) {
                      setState(() {
                        _image = newImage;
                      });
                    },
                  ),
                  const SizedBox(height: 65),
                  CustomField(
                    controller: firstNameController,
                    hintText: 'First Name',
                    obscureText: false,
                    fieldPrefixIcon: const FaIcon(
                      FontAwesomeIcons.user,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 15),
                  CustomField(
                    controller: lastNameController,
                    hintText: 'Last Name',
                    obscureText: false,
                    fieldPrefixIcon: const FaIcon(
                      FontAwesomeIcons.user,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 15),
                  CustomField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                    fieldPrefixIcon: const FaIcon(
                      FontAwesomeIcons.lock,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: editProfileInfo,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 13,
                      ),
                      backgroundColor: const Color(0xFF1E889E),
                      textStyle: const TextStyle(
                        fontSize: 30,
                        fontFamily: 'Zilla',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    child: const Text('Save Changes'),
                  ),
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.only(right: 320.0),
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
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ProfilePicture extends StatefulWidget {
  final File? image;
  final void Function(File? newImage) onImageChanged;

  const ProfilePicture({
    Key? key,
    required this.image,
    required this.onImageChanged,
  }) : super(key: key);

  @override
  _ProfilePictureState createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      width: 250,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color.fromARGB(255, 0, 0, 0), // Border color
                width: 0.0, // Border width
              ),
            ),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: widget.image != null
                  ? Image.file(widget.image!).image
                  : const AssetImage(
                      "assets/Images/Profiles/Tourist/DefaultProfileImage.png"),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 0,
            child: SizedBox(
              height: 60,
              width: 60,
              child: FloatingActionButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                  side: const BorderSide(color: Colors.white),
                ),
                backgroundColor: const Color(0xFFF5F6F9),
                onPressed: () {
                  // When the camera icon is pressed, open the image picker
                  _getImage();
                },
                child: Image.asset(
                  "assets/Images/Profiles/Tourist/camera.png", // Use your custom icon image here
                  width: 40,
                  height: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final newImage = File(pickedFile.path);
      widget.onImageChanged(newImage);
    }
  }
}
