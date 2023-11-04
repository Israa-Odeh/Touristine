import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:touristine/LoginAndRegistration/MainPages/SplashScreen.dart';
import 'package:touristine/Profiles/Tourist/MainPages/tourist.dart';
import 'package:touristine/onBoarding/Admin/adminProfile.dart';
import 'package:touristine/onBoarding/Page_Screen/onboardingScreen.dart';

class OnBoardingPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String token;
  final String password;
  final List<String> title;
  final List<String> imageAsset;
  final List<String> firstText;
  final List<String> secondText;
  final double titleSize;
  final int numOfPages;
  final int
      profileType; // 0: Indicates tourist Profile, 1: Indicates admin profile.
  // There might be 2 for the stuff profiles, this will be decided later on.

  const OnBoardingPage(
      {Key? key,
      required this.title,
      required this.imageAsset,
      required this.firstText,
      required this.secondText,
      required this.titleSize,
      required this.numOfPages,
      required this.profileType,
      required this.firstName,
      required this.lastName,
      required this.token,
      required this.password})
      : super(key: key);

  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  // This controller keeps track of what page we are on.
  PageController _controller = PageController();

  // Keeps track if we are on the last page or not.
  bool onLastPage = false;

  List<Widget> buildOnboardingScreens() {
    List<Widget> screens = [];
    for (int i = 0; i < widget.numOfPages; i++) {
      screens.add(
        OnboardingScreen(
          title: widget.title[i],
          imageAsset: widget.imageAsset[i],
          firstText: widget.firstText[i],
          secondText: widget.secondText[i],
          titleSize: widget.titleSize,
        ),
      );
    }
    return screens;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> onboardingScreens = buildOnboardingScreens();

    return Scaffold(
      body: Stack(
        children: [
          // Page view to create a scrollable list of pages.
          PageView(
            controller:
                _controller, // Keeps track of what page we are on right now.
            // PageIndex: This value tells what page we are currently on.
            onPageChanged: (pageIndex) {
              setState(() {
                // If the pageIndex is numOfPages - 1, then we are in the last page.
                onLastPage = (pageIndex == (widget.numOfPages - 1));
              });
            },

            // The list of scrollable pages inside the page view.
            children: onboardingScreens,
          ),

          // Dot Indicator with skip and next buttons.
          Container(
            alignment: const Alignment(0, 0.9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // A skip button.
                Visibility(
                  visible:
                      !onLastPage, // Show the skip button as long as it isn't the last page.
                  child: ElevatedButton(
                    onPressed: () {
                      _controller.jumpToPage(widget.numOfPages - 1);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E889E),
                      minimumSize: const Size(90, 50),
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontFamily: 'Zilla',
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                  ),
                ),

                // The dot indicator.
                SmoothPageIndicator(
                  controller: _controller,
                  count: widget.numOfPages,
                  effect: const WormEffect(
                    activeDotColor: Color(0xFF1E889E),
                    dotColor: Color(0xFFe0e0e0),
                  ),
                ),

                // Ternary conditional operator.
                // Next-ArrowIcon in the first pages, Done Button in the last page.
                onLastPage
                    ?
                    // The code portion that will be executed if the condition is true.
                    // The tourist is in the last page of the page view.
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return widget.profileType == 100
                                ? SplashScreen(
                                    profileType: TouristProfile(
                                    firstName: widget.firstName,
                                    lastName: widget.lastName,
                                    token: widget.token,
                                    password: widget.password,
                                  ))
                                : const AdminProfile();
                          }));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E889E),
                          minimumSize: const Size(170, 50),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontFamily: 'Zilla',
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                      )

                    // The code portion that will be executed if the condition is false.
                    // The tourist isn't in the last page of the page view.
                    : ElevatedButton(
                        onPressed: () {
                          _controller.nextPage(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeIn);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E889E),
                          minimumSize: const Size(90, 50),
                        ),
                        child: const FaIcon(
                          FontAwesomeIcons.arrowRight,
                          size: 30,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
