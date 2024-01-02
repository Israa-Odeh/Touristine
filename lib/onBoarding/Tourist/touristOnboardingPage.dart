import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:provider/provider.dart';
import 'package:touristine/Profiles/Tourist/MainPages/Chatting/chattingFunctions.dart';
import 'package:touristine/UserData/userProvider.dart';
import 'package:touristine/onBoarding/Page_Screen/onboardingPage.dart';

class TouristOnBoardingPage extends StatefulWidget {
  final String token;
  final bool googleAccount;

  const TouristOnBoardingPage(
      {super.key,
      required this.token,
      this.googleAccount = false // Set default value to false.
      });

  @override
  _TouristOnBoardingPageState createState() => _TouristOnBoardingPageState();
}

class _TouristOnBoardingPageState extends State<TouristOnBoardingPage> {
  @override
  void initState() {
    super.initState();
    // Extract the user email from the token.
    Map<String, dynamic> decodedToken = Jwt.parseJwt(widget.token);
    String userEmail = decodedToken['email'];

    // Retrieve the UserProvider from the context.
    final UserProvider userProvider = context.read<UserProvider>();

    // Initiate a chatting document for the user.
    final User user = User(
        email: userEmail,
        firstName: userProvider.firstName,
        lastName: userProvider.lastName,
        imagePath: userProvider.imageURL ?? "",
        chats: {});
    addUserToFirebase(user);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // To prevent going back, simply return false
          return false;
        },
        child: OnBoardingPage(
          token: widget.token,
          googleAccount: widget.googleAccount,
          title: const [
            'Destinations Discovery',
            'Destinations Rating',
            'Trip Planning',
            'Community Share',
            'Chatting',
            'GPS Navigation',
          ],
          imageAsset: const [
            'assets/Images/onBoardingPage/Tourist/Search.gif',
            'assets/Images/onBoardingPage/Tourist/Feedback.gif',
            'assets/Images/onBoardingPage/Tourist/Planner.gif',
            'assets/Images/onBoardingPage/Tourist/ImageUpload.gif',
            'assets/Images/onBoardingPage/Tourist/Chatting.gif',
            'assets/Images/onBoardingPage/Tourist/Navigation.gif',
          ],
          firstText: const [
            'Search destinations and explore',
            'Browse ratings for destinations',
            'Generate customized itineraries',
            'Share images of destinations,',
            'In case of any issues, contact the',
            'Utilize GPS services to navigate',
          ],
          secondText: const [
            'their available services',
            'and services, and share yours',
            'based on your preferences',
            'including building cracks',
            'visited destination admin',
            'to your selected destination',
          ],
          titleSize: 50, // Set your desired title size to be 50.
          numOfPages: 6, // The number of pages in the onboarding Page.
          profileType: 100, // 100 for tourist profile.
        ));
  }
}
