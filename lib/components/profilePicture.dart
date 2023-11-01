import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';

class ProfilePicture extends StatefulWidget {
  final String token;

  const ProfilePicture({super.key, required this.token});

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
    firstName = decodedToken['firstName'];
    lastName = decodedToken['lastName'];
    email = decodedToken['email'];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 150,
          width: 150,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: AssetImage(
                "assets/Images/Profiles/Tourist/DefaultProfileImage.png"),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Text(
              firstName,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            Text(
              " $lastName",
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
