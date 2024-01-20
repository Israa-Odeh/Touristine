import 'package:touristine/WebApplication/onBoarding/Page_Screen/onboarding_page.dart';
import 'package:flutter/material.dart';

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
          titleSize: 30, // Set the desired title size to be 50.
          numOfPages: 6, // The number of pages in the onboarding Page.
          profileType: 100, // 100 is for the tourist profile.
        ));
  }
}
