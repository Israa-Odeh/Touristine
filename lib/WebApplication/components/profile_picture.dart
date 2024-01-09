import 'package:touristine/WebApplication/UserData/user_provider.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class ProfilePicture extends StatefulWidget {
  final String token;

  const ProfilePicture({
    super.key,
    required this.token,
  });

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
    // var touristProvider = context.read<UserProvider>();

    return Column(
      children: [
        SizedBox(
          height: 150,
          width: 150,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: (context.watch<UserProvider>().imageURL != null &&
                    context.watch<UserProvider>().imageURL != "")
                ? NetworkImage(context.watch<UserProvider>().imageURL!)
                : Image.asset(
                        "assets/Images/Profiles/Tourist/DefaultProfileImage.png")
                    .image,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Text(
              context.watch<UserProvider>().firstName,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            Text(
              " ${context.watch<UserProvider>().lastName}",
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
