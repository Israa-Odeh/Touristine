import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:touristine/Notifications/SnackBar.dart';
import 'package:touristine/components/customField.dart';
import 'package:touristine/UserData/userProvider.dart';

class AccountPage extends StatefulWidget {
  final String token;

  const AccountPage({
    super.key,
    required this.token,
  });

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  // Textfields Controllers.
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isImageChanged = false;

  File? _image;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Move the context-dependent code here.
      firstNameController.text = context.read<UserProvider>().firstName;
      lastNameController.text = context.read<UserProvider>().lastName;
      passwordController.text = context.read<UserProvider>().password;
    });
  }

  void updateIsImageChanged(bool isChanged) {
    setState(() {
      isImageChanged = isChanged;
    });
  }

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
    final url = Uri.parse('https://touristine.onrender.com/edit-account');
    final request = http.MultipartRequest('POST', url);

    // Add headers to the request.
    request.headers['Content-Type'] = 'multipart/form-data';
    request.headers['Authorization'] = 'Bearer ${widget.token}';

    // Add the image to the request if it exists.
    if (_image != null) {
      List<int> imageBytes = _image!.readAsBytesSync(); // Read file as bytes.
      String fileName = _image!.path.split('/').last; // Extract file name.
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
        final responseJson = await response.stream.bytesToString();
        final parsedResponse = json.decode(responseJson);
        if (parsedResponse['message'] == 'updated') {
          // Handle success, possibly update UI or show a success message
          if (parsedResponse.containsKey('imageUrl')) {
            setState(() {
              updateIsImageChanged(false);
            });
            String? imageUrl = parsedResponse['imageUrl'];
            print("Image: $imageUrl");
            // ignore: use_build_context_synchronously
            context.read<UserProvider>().updateImage(
                  newImageURL: imageUrl,
                );
          }
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, "Your information has been edited",
              bottomMargin: 457);
          // ignore: use_build_context_synchronously
          context.read<UserProvider>().updateData(
                newFirstName: firstNameController.text,
                newLastName: lastNameController.text,
                newPassword: passwordController.text,
              );
        }
      } else if (response.statusCode == 500) {
        final responseJson = await response.stream.bytesToString();
        final parsedResponse = json.decode(responseJson);
        if (parsedResponse.containsKey('message') &&
            parsedResponse['message'] == 'Unable to upload') {
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, "Unable to upload the image",
              bottomMargin: 457);
        } else {
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, "An error has occurred",
              bottomMargin: 457);
        }
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Failed to update, please try again',
            bottomMargin: 457);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void editProfileInfo() {
    // Check if any data has changed.
    bool isDataChanged =
        context.read<UserProvider>().firstName != firstNameController.text ||
            context.read<UserProvider>().lastName != lastNameController.text ||
            context.read<UserProvider>().password != passwordController.text ||
            isImageChanged == true;

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
                    'assets/Images/Profiles/Admin/AccountPage/AccountBackground.png'),
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
                  ProfileImage(
                    image: _image,
                    onImageChanged: (File? newImage) {
                      setState(() {
                        _image = newImage;
                        // Update the isImageChanged value when the image changes.
                        updateIsImageChanged(true);
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

class ProfileImage extends StatefulWidget {
  final File? image;
  final void Function(File? newImage) onImageChanged;

  const ProfileImage({super.key, this.image, required this.onImageChanged});

  @override
  _ProfileImageState createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  Future<void> _getImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final newImage = File(pickedFile.path);
      widget.onImageChanged(newImage);
    }
  }

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
                color: const Color.fromARGB(255, 0, 0, 0),
                width: 0.0,
              ),
            ),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: (context.watch<UserProvider>().imageURL !=
                          null &&
                      context.watch<UserProvider>().imageURL != "" &&
                      widget.image == null)
                  ? NetworkImage(context.watch<UserProvider>().imageURL!)
                  : widget.image != null
                      ? Image.file(widget.image!).image
                      : const AssetImage(
                          "assets/Images/Profiles/Admin/AccountPage/DefaultProfileImage.png"),
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
                  // When the camera icon is pressed, open the image picker.
                  _getImage();
                },
                child: Image.asset(
                  "assets/Images/Profiles/Admin/AccountPage/camera.png",
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
}
