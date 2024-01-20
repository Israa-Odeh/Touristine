import 'package:touristine/WebApplication/Notifications/snack_bar.dart';
import 'package:touristine/WebApplication/components/custom_field.dart';
import 'package:touristine/WebApplication/UserData/user_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';

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

  Uint8List? _image;

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
      String fileName = 'file_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imageFile = http.MultipartFile.fromBytes(
        'profileImage',
        _image!,
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
              bottomMargin: 0);
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
              bottomMargin: 0);
        } else {
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, "An error has occurred",
              bottomMargin: 0);
        }
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Failed to update, please try again',
            bottomMargin: 0);
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
            bottomMargin: 0);
      } else if (!isNameValid(firstNameController.text)) {
        showCustomSnackBar(context, 'Invalid first name: 2-20 characters only',
            bottomMargin: 0);
      } else if (!isNameValid(lastNameController.text)) {
        showCustomSnackBar(context, 'Invalid last name: 2-20 characters only',
            bottomMargin: 0);
      } else if (!isPasswordValid(passwordController.text)) {
        showCustomSnackBar(context, 'Password must contain 8-30 chars',
            bottomMargin: 0);
      } else {
        sendAndSaveData();
      }
    } else {
      showCustomSnackBar(context, 'No modifications detected',
          bottomMargin: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -50,
          bottom: -50,
          left: 0,
          right: 0,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/Images/Profiles/Tourist/WebAccountBackground.png'),
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
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const SizedBox(height: 50),
                        ProfileImage(
                          image: _image,
                          onImageChanged: (Uint8List? newImage) {
                            setState(() {
                              _image = newImage;
                              // Update the isImageChanged value when the image changes.
                              updateIsImageChanged(true);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 120),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 70.0),
                          child: CustomField(
                            controller: firstNameController,
                            hintText: 'First Name',
                            obscureText: false,
                            fieldPrefixIcon: const FaIcon(
                              FontAwesomeIcons.user,
                              size: 30,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 70.0),
                          child: CustomField(
                            controller: lastNameController,
                            hintText: 'Last Name',
                            obscureText: false,
                            fieldPrefixIcon: const FaIcon(
                              FontAwesomeIcons.user,
                              size: 30,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 70.0),
                          child: CustomField(
                            controller: passwordController,
                            hintText: 'Password',
                            obscureText: true,
                            fieldPrefixIcon: const FaIcon(
                              FontAwesomeIcons.lock,
                              size: 30,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: editProfileInfo,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 20,
                            ),
                            backgroundColor: const Color(0xFF1E889E),
                            textStyle: const TextStyle(
                              fontSize: 22,
                              fontFamily: 'Zilla',
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          child: const Text('Save Changes'),
                        ),
                        const SizedBox(height: 50),
                      ],
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
  final Uint8List? image;
  final void Function(Uint8List? newImage) onImageChanged;

  const ProfileImage({super.key, this.image, required this.onImageChanged});

  @override
  _ProfileImageState createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  Future<void> _getImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      var newImage = await pickedFile.readAsBytes();
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
                      ? Image.memory(widget.image!).image
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
