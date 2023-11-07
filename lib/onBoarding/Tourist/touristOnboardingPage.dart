// onboarding_example.dart

import 'package:flutter/material.dart';
import 'package:touristine/onBoarding/Page_Screen/onboardingPage.dart';

class TouristOnBoardingPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String token;
  final String password;
  final String? profileImage;
  final bool googleAccount;

  const TouristOnBoardingPage(
      {super.key,
      required this.firstName,
      required this.lastName,
      required this.token,
      required this.password,
      this.profileImage,
      this.googleAccount = false // Set default value to false.
      });

  @override
  _TouristOnBoardingPageState createState() => _TouristOnBoardingPageState();
}

class _TouristOnBoardingPageState extends State<TouristOnBoardingPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // To prevent going back, simply return false
          return false;
        },
        child: OnBoardingPage(
          firstName: widget.firstName,
          lastName: widget.lastName,
          token: widget.token,
          password: widget.password,
          profileImage: widget.profileImage,
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
