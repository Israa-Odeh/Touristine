import 'package:touristine/WebApplication/Notifications/snack_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class CracksMapViewer extends StatefulWidget {
  final String token;

  const CracksMapViewer({super.key, required this.token});

  @override
  _CracksMapViewerState createState() => _CracksMapViewerState();
}

class _CracksMapViewerState extends State<CracksMapViewer> {
  // List to maintain state for each marker
  List<bool> isMarkerTappedList = [false, false, false, false];
  bool isLoading = true;

  Map<String, dynamic> cracksCounts = {
    'Nablus': 20,
    'Ramallah': 20,
    'Jerusalem': 50,
    'Bethlehem': 10,
  };

  final List<Color> cityTilesColors = [
    const Color(0xFFCCCCCC),
    const Color(0xFF8CA9B9),
    const Color(0xFF9AB7C2),
    const Color(0xFF1E889E)
  ];

  final List<String> polygonsRGBStrings = [
    "rgb(163, 162, 162)", // 0xFFA3A2A2
    "rgb(204, 204, 204)", // 0xFFCCCCCC
    "rgb(212, 212, 212)", // 0xFFD4D4D4
    "rgb(178, 181, 178)", // 0xFFB2B5B2
    "rgb(30, 136, 158)", // 0xFF1E889E
    "rgb(154, 183, 194)", // 0xFF9AB7C2
    "rgb(187, 187, 191)", // 0xFFBBBBBF
    "rgb(125, 165, 188)", // 0xFF7DA5BC
    "rgb(140, 169, 185)", // 0xFF8CA9B9
  ];

  ScrollController controller = ScrollController();

  void fetchCracksCounts() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    final url =
        Uri.parse('https://touristineapp.onrender.com/get-cracks-counts');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        // Jenan, here I need to retrieve a Map of the cracks counts for each city,
        // (If the city doesn't have cracks return 0 count for the city), the format
        // will be exactly as follows (with the same order of cities please:
        // (Nablus, Ramallah, Jerusalem, then  finally Bethlehem):
        /*
        Map<String, dynamic> citiesList = {
          'Nablus': 0,
          'Ramallah': 20,
          'Jerusalem': 50,
          'Bethlehem': 10,
        };
        */
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Error retrieving the cracks counts',
            bottomMargin: 0);
      }
    } catch (error) {
      if (mounted) {
        print('Error fetching the cracks counts: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCracksCounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E889E)),
              ),
            )
          : cracksCounts.isEmpty
              ? Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 40,
                        child: Image.asset(
                          'assets/Images/Profiles/Tourist/emptyListTransparent.gif',
                          fit: BoxFit.fill,
                        ),
                      ),
                      const Positioned(
                        top: 460,
                        child: Text(
                          'No cracks found',
                          style: TextStyle(
                            fontSize: 40,
                            fontFamily: 'Gabriola',
                            color: Color.fromARGB(255, 23, 99, 114),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Stack(children: [
                  // Background image
                  // Positioned.fill(
                  //   child: Image.asset(
                  //     'assets/Images/Profiles/Admin/mainBackground.jpg', // Replace with your image path
                  //     fit: BoxFit.fill,
                  //   ),
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 180.0, left: 200.0),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 310,
                              height: 200,
                              child: Scrollbar(
                                controller: controller,
                                trackVisibility: true,
                                thumbVisibility: true,
                                child: SingleChildScrollView(
                                  controller: controller,
                                  scrollDirection: Axis.vertical,
                                  child: Wrap(
                                    spacing: 8.0,
                                    runSpacing: 10.0,
                                    children: cracksCounts.keys.map((city) {
                                      return Container(
                                        width: 300,
                                        height: 40,
                                        color: cityTilesColors[cracksCounts.keys
                                            .toList()
                                            .indexOf(city)],
                                        child: Row(
                                          children: [
                                            const Padding(
                                              padding:
                                                  EdgeInsets.only(left: 20.0),
                                              child: FaIcon(
                                                FontAwesomeIcons.locationDot,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20.0),
                                              child: Center(
                                                child: Text(
                                                  city,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 280),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: 50),
                              Center(
                                child: Stack(
                                  children: [
                                    GestureDetector(
                                      onTapUp: (TapUpDetails details) {
                                        handleTap(details.localPosition);
                                      },
                                      child: SvgPicture.string(
                                        '''
                                          <svg height="850" width="490">
                                            <!-- جنين -->
                                            <polygon points="213,165,207,166,201,168,195,166,190,162,183,163,177,170,173,165,168,168,170,173,166,177,166,183,169,189,164,192,159,195,163,200,167,205,168,213,170,220,176,224,181,227,186,230,192,233,198,229,203,233,209,228,210,220,213,214,219,216,223,212,228,208,228,202,234,201,232,194,229,187,223,184,219,179,214,174" fill="${polygonsRGBStrings[0]}" />
                            
                                            <!-- نابلس -->
                                            <polygon points="198,230,192,232,186,228,175,226,174,232,176,237,175,243,177,250,175,256,173,263,176,269,183,272,188,275,190,280,187,286,193,290,201,291,208,294,214,297,223,302,223,293,225,286,231,282,236,275,235,267,237,256,233,248,236,242,232,236,225,231,218,228,209,234" fill="${polygonsRGBStrings[1]}" />
                            
                                            <!-- أريحا -->
                                            <polygon points="252,242,255,249,255,256,252,262,252,270,251,277,249,284,247,291,249,298,250,306,250,315,250,322,251,328,252,338,252,345,253,353,247,355,241,359,236,365,233,371,232,381,227,377,221,372,214,372,207,370,206,363,207,356,210,349,213,342,214,335,218,328,220,321,222,314,224,308,223,301,224,292,225,285,231,282,236,275,235,267,237,255,233,247,235,243" fill="${polygonsRGBStrings[2]}" />
                            
                                            <!-- الخليل -->
                                            <polygon points="146,370,141,367,133,367,134,360,132,353,124,360,124,365,118,365,112,365,114,371,116,378,115,385,105,388,110,391,114,398,119,404,118,409,115,414,117,421,116,428,119,436,123,441,130,441,134,446,135,453,137,462,145,466,152,472,163,474,171,478,182,478,195,478,208,480,219,478,219,470,222,463,224,455,221,447,222,440,221,431,215,429,209,424,204,419,198,416,192,414,183,411,174,404,163,402,156,402,149,398,148,391,154,387,156,379,157,372,151,366" fill="${polygonsRGBStrings[0]}" />
                            
                                            <!-- بئر السبع - النقب -->
                                            <polygon points="79,426,75,430,67,433,62,437,54,437,48,434,40,434,34,436,30,442,24,448,24,454,30,454,34,458,31,462,34,467,28,468,19,470,14,474,10,479,6,482,8,488,10,493,13,501,17,511,20,521,23,531,29,543,34,555,43,568,50,580,51,591,54,604,58,610,62,614,64,620,65,628,68,634,73,639,78,644,81,651,85,660,88,666,93,674,95,683,99,690,100,700,100,708,101,716,104,724,108,734,113,742,114,749,120,756,124,766,128,776,134,786,138,792,142,798,146,791,151,784,154,766,156,752,160,740,162,729,162,720,168,711,178,699,181,694,176,680,177,669,178,659,184,653,178,644,177,636,182,628,185,617,185,608,191,603,198,592,202,584,204,575,208,568,212,562,212,554,217,548,223,542,225,534,223,524,230,518,224,508,222,498,218,487,216,480,209,479,201,478,190,478,177,478,167,475,160,473,152,473,140,466,136,459,132,448,124,441,118,433,116,424,114,414,118,408,114,399,106,398,93,401,88,409,88,427" fill="${polygonsRGBStrings[3]}" />
                            
                                            <!-- صفد -->
                                            <polygon points="250,0,245,6,243,12,242,19,242,27,242,34,240,39,226,47,220,50,214,52,208,58,206,65,213,66,220,65,223,77,220,82,228,90,233,94,240,93,246,92,252,92,258,93,262,85,260,71,262,64,264,55,266,45,266,36,267,26,268,18,267,8,258,8" fill="${polygonsRGBStrings[4]}" />
                            
                                            <!-- عكا -->
                                            <polygon points="210,51,204,47,198,43,192,45,184,44,176,45,169,45,163,47,162,55,161,62,158,70,158,77,158,85,162,88,165,93,166,100,172,104,178,108,184,109,188,104,195,104,199,111,201,117,207,115,213,112,219,114,218,106,216,96,219,90,221,84,221,76,218,66,206,63" fill="${polygonsRGBStrings[5]}" />
                            
                                            <!-- طبريا -->
                                            <polygon points="247,90,242,93,236,95,230,93,222,89,216,98,218,105,218,111,221,118,218,123,214,129,218,133,222,139,224,145,228,149,234,149,240,149,246,152,252,156,256,152,260,145,266,141,265,131,265,122,265,113,264,104,260,95,252,93" fill="${polygonsRGBStrings[1]}" />
                            
                                            <!-- الناصرة -->
                                            <polygon points="214,127,217,121,220,115,214,111,203,117,198,109,190,103,187,109,186,115,186,121,184,128,182,133,178,137,174,143,172,150,176,154,181,155,186,158,191,161,195,165,202,167,215,165,221,161,220,151,224,147,223,139,218,132" fill="${polygonsRGBStrings[4]}" />
                            
                                            <!-- حيفا -->
                                            <polygon points="158,86,158,91,158,97,157,102,153,109,147,107,139,104,137,110,138,115,138,121,136,127,135,132,134,139,133,146,132,152,130,158,130,165,129,173,127,181,126,189,125,197,124,205,123,211,129,208,136,208,139,202,145,200,151,197,159,192,165,191,168,185,164,180,171,172,169,166,176,170,180,164,189,163,185,158,179,156,173,152,173,146,176,139,181,132,185,124,188,116,184,110,178,108,171,105,166,100,166,93" fill="${polygonsRGBStrings[2]}" />
                            
                                            <!-- بيسان -->
                                            <polygon points="220,150,223,163,217,165,212,168,213,174,218,179,223,183,229,187,232,193,233,201,237,206,242,212,245,207,251,207,250,200,253,195,252,187,250,180,253,173,252,166,253,158,247,153,239,150,231,151,225,147" fill="${polygonsRGBStrings[7]}" />
                            
                                            <!-- طوباس -->
                                            <polygon points="241,211,236,205,230,202,227,207,223,211,221,218,213,214,210,220,208,227,210,232,218,229,224,231,229,234,233,238,236,243,243,242,252,242,253,233,252,226,251,219,254,214,250,206" fill="${polygonsRGBStrings[6]}" />
                            
                                            <!-- طولكرم -->
                                            <polygon points="159,193,152,194,146,198,138,201,134,208,126,208,121,215,120,223,118,231,116,240,114,257,120,260,127,257,132,259,138,254,143,251,150,249,156,246,160,250,164,247,168,242,174,241,174,234,173,227,179,225,171,220,167,212,166,205,162,199" fill="${polygonsRGBStrings[4]}" />
                            
                                            <!-- قلقيلية -->
                                            <polygon points="174,242,168,242,164,246,160,250,154,247,147,250,139,255,134,257,131,263,132,268,132,274,135,277,143,275,151,274,156,272,165,273,170,269,173,267,174,257,176,250" fill="${polygonsRGBStrings[6]}" />
                            
                                            <!-- سلفيت -->
                                            <polygon points="173,265,169,269,163,272,156,272,150,273,142,275,136,275,132,279,133,284,132,289,138,290,143,292,145,293,154,293,161,292,164,292,168,288,173,288,178,290,188,288,190,279,188,276,179,271,190,279" fill="${polygonsRGBStrings[0]}" />
                            
                                            <!-- يافا -->
                                            <polygon points="115,308,117,316,127,303,134,309,136,299,136,291,133,280,132,271,133,259,126,257,120,259,114,254,112,261,110,270,107,279,104,287,102,294,101,304,107,310,116,309,115,309" fill="${polygonsRGBStrings[5]}" />
                            
                                            <!-- رام الله -->
                                            <polygon points="189,288,182,289,175,289,168,288,164,292,156,292,155,299,156,304,160,309,162,315,159,320,155,327,156,333,160,341,165,333,174,334,184,337,182,331,188,331,198,333,203,330,208,334,214,336,217,328,220,320,222,312,223,303,216,298,208,294,198,290" fill="${polygonsRGBStrings[8]}" />
                                
                                            <!-- اللد -->
                                            <polygon points="155,292,148,292,141,290,135,290,136,302,134,309,128,304,130,314,134,320,136,327,140,332,142,339,148,348,158,347,162,343,158,336,155,330,156,324,161,314,157,305,154,298" fill="${polygonsRGBStrings[6]}" />
                            
                                            <!-- الرملة -->
                                            <polygon points="127,303,123,307,118,316,115,307,107,310,101,303,99,309,96,316,93,323,87,336,93,342,98,352,106,351,113,355,113,365,122,366,126,359,132,352,138,351,142,354,148,353,147,346,143,339,140,331,136,325,133,318,129,310" fill="${polygonsRGBStrings[2]}" />
                            
                                            <!-- القدس -->
                                            <polygon points="202,331,195,333,182,331,184,337,177,336,171,333,164,333,161,338,160,345,152,346,146,347,147,353,141,354,133,351,132,357,133,368,141,367,148,369,151,365,156,371,165,371,172,375,180,376,190,373,201,372,206,371,204,362,207,353,211,344,212,337" fill="${polygonsRGBStrings[5]}" />
                            
                                            <!-- بيت لحم -->
                                            <polygon points="206,371,192,372,183,376,174,376,168,373,158,371,156,377,154,385,148,391,149,398,158,404,168,403,177,406,183,412,190,414,203,418,210,425,217,430,222,426,222,418,224,409,225,403,224,391,231,380,221,373" fill="${polygonsRGBStrings[4]}" />
                            
                                            <!-- غزّة العزّة-->
                                            <polygon points="87,335,83,343,78,355,71,372,61,387,53,396,47,405,41,412,36,419,30,427,24,437,19,445,9,456,0,463,6,482,12,479,16,469,25,470,32,470,30,463,34,457,22,456,28,446,32,445,31,438,38,434,46,435,54,436,60,440,67,435,75,432,80,425,87,431,90,429,87,422,87,415,88,407,92,403,103,400,115,398,111,393,105,389,111,386,116,381,115,374,110,367,114,366,113,359,110,353,104,351,98,351,93,343" fill="${polygonsRGBStrings[4]}" />
                            
                                            <!-- البحر الميت -->
                                            <polygon points="253,353,247,354,243,358,238,361,234,367,233,375,232,380,228,385,225,391,225,397,225,407,222,412,223,419,223,426,221,432,223,440,221,447,225,454,223,459,220,466,220,475,218,484,220,491,223,498,224,505,227,512,232,516,240,514,245,509,248,501,253,495,249,489,248,482,242,480,235,475,231,469,235,462,241,458,241,455,246,450,245,464,252,459,254,453,254,445,254,439,257,433,258,427,258,420,254,414,254,406,254,398,256,391,258,383,259,376,261,369,261,362,258,356" fill="${polygonsRGBStrings[8]}" />               
                                          </svg>
                                        ''',
                                      ),
                                    ),

                                    // Nablus Marker.
                                    buildMarker(250, 200, 0),

                                    // Ramallah Marker.
                                    buildMarker(302, 182, 1),

                                    // Jerusalem Marker.
                                    buildMarker(347, 172, 2),

                                    // Bethlehem Marker.
                                    buildMarker(385, 188, 3),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ]),
    );
  }

  Widget buildMarker(double top, double left, int index) {
    final cityName = cracksCounts.keys.elementAt(index);
    final cracksNumber = cracksCounts.values.elementAt(index);

    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: () {
          setState(() {
            // Toggle marker tap state.
            isMarkerTappedList[index] = !isMarkerTappedList[index];
          });
          // Reset marker color for all other markers.
          onTapMarker(index);
          // Handle marker tap.
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Cracks Count',
                    style: TextStyle(
                        fontFamily: 'Zilla Slab Light',
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                content: Text(
                  '$cityName has $cracksNumber cracks in various locations.',
                  style: const TextStyle(fontFamily: 'Andalus', fontSize: 16),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      resetMarkerSelection();
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontFamily: 'Zilla',
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Add functionality to navigate to the view page
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => CracksViewPage(cityName: cityName)),
                      // );
                    },
                    child: const Text(
                      'View Cracks',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontFamily: 'Zilla',
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
        child: AnimatedContainer(
          height: 20,
          width: 20,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isMarkerTappedList[index]
                ? const Color.fromARGB(255, 255, 255, 255)
                : const Color.fromARGB(0, 192, 175, 175),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: FaIcon(
              FontAwesomeIcons.locationDot,
              color: isMarkerTappedList[index]
                  ? const Color(0xFF1E889E)
                  : const Color.fromARGB(255, 255, 255, 255),
              size: 15,
            ),
          ),
        ),
      ),
    );
  }

  void onTapMarker(int tappedIndex) {
    setState(() {
      // Reset isMarkerTappedList for all markers.
      for (int i = 0; i < isMarkerTappedList.length; i++) {
        if (i != tappedIndex) {
          isMarkerTappedList[i] = false;
        }
      }
    });
  }

  void resetMarkerSelection() {
    setState(() {
      isMarkerTappedList = List<bool>.generate(4, (index) => false);
    });
  }

  void handleTap(Offset localPosition) {
    // Check which area was tapped based on the localPosition
    print('Tapped at: $localPosition');
    // Add your logic to handle the tap for specific areas
  }
}
