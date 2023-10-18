// onboarding_example.dart

import 'package:flutter/material.dart';
import 'package:touristine/onBoarding/Page_Screen/onboardingPage.dart';

class TouristOnBoardingPage extends StatefulWidget {
  @override
  _TouristOnBoardingPageState createState() => _TouristOnBoardingPageState();
}

class _TouristOnBoardingPageState extends State<TouristOnBoardingPage> {
  @override
  Widget build(BuildContext context) {
    return const OnBoardingPage(
      title: [
        'Destinations Discovery',
        'Destinations Rating',
        'Trip Planning',
        'Community Share',
        'Chatting',
        'GPS Navigation',
      ],
      imageAsset: [
        'assets/Images/onBoardingPage/Tourist/Search.gif',
        'assets/Images/onBoardingPage/Tourist/Feedback.gif',
        'assets/Images/onBoardingPage/Tourist/Planner.gif',
        'assets/Images/onBoardingPage/Tourist/ImageUpload.gif',
        'assets/Images/onBoardingPage/Tourist/Chatting.gif',
        'assets/Images/onBoardingPage/Tourist/Navigation.gif',
      ],
      firstText: [
        'Search destinations and explore',
        'Browse ratings for destinations',
        'Generate customized itineraries',
        'Share images of destinations,',
        'In case of any issues, contact the',
        'Utilize GPS services to navigate',
      ],
      secondText: [
        'their available services',
        'and services, and share yours',
        'based on your preferences',
        'including building cracks',
        'visited destination admin',
        'to your selected destination',
      ],
      titleSize: 50, // Set your desired title size to be 50.
      numOfPages: 6, // The number of pages in the onboarding Page.
      profileType: 0, // 0 for tourist profile, 1 for admin profile.
    );
  }
}