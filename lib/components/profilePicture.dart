import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';

class ProfilePicture extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String token;
  final String? imagePath; // New variable for the image path

  const ProfilePicture(
      {super.key,
      required this.firstName,
      required this.lastName,
      required this.token, 
      this.imagePath});

  @override
  _ProfilePictureState createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  late String email;
  late String firstName;
  late String lastName;
  @override
  void initState() {
    super.initState();

    Map<String, dynamic> decodedToken = Jwt.parseJwt(widget.token);
    email = decodedToken['email'];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          width: 150,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: (widget.imagePath != null)
                ? AssetImage(widget.imagePath!)
                : const AssetImage(
                    "assets/Images/Profiles/Tourist/DefaultProfileImage.png"),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Text(
              widget.firstName,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            Text(
              " ${widget.lastName}",
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          email,
          style: const TextStyle(fontSize: 20),
        ),
      ],
    );
  }
}
