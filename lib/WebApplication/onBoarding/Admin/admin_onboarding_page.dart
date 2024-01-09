import 'package:touristine/WebApplication/onBoarding/Page_Screen/onboarding_page.dart';
import 'package:flutter/material.dart';

class AdminOnBoardingPage extends StatefulWidget {
  final String token;

  const AdminOnBoardingPage({super.key, required this.token});

  @override
  _AdminOnBoardingPageState createState() => _AdminOnBoardingPageState();
}

class _AdminOnBoardingPageState extends State<AdminOnBoardingPage> {
  @override
  Widget build(BuildContext context) {
    return OnBoardingPage(
      token: widget.token,
      title: const [
        'Managing destinations',
        'Content Approval',
        'Crack Analysis',
        'Map View',
        'Reports Generation',
      ],
      imageAsset: const [
        'assets/Images/onBoardingPage/Admin/DestinationManaging.gif',
        'assets/Images/onBoardingPage/Admin/ContentApproval.gif',
        'assets/Images/onBoardingPage/Admin/Cracks1.gif',
        'assets/Images/onBoardingPage/Admin/Map.gif',
        'assets/Images/onBoardingPage/Admin/Report.gif',
      ],
      firstText: const [
        'Add and update destination',
        'Review and approve tourist-',
        'Use machine learning to analyze',
        'A map distribution of jeopardy',
        'Display visitor statistics, tourist',
      ],
      secondText: const [
        'details and services',
        'submitted destination photos',
        'cracks in building images',
        'levels based on crack analysis',
        'feedback, and crack analysis',
      ],
      titleSize: 50, // Set your desired title size to be 50.
      numOfPages: 5, // The number of pages in the onboarding Page.
      profileType: 200, // 200 for admin profile.
    );
  }
}
