import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:touristine/Profiles/Tourist/MainPages/Home/addingReview.dart';
import 'package:touristine/Profiles/Tourist/MainPages/Home/imagesList.dart';
import 'package:touristine/Profiles/Tourist/MainPages/Home/reviews.dart';
import 'package:http/http.dart' as http;

class DestinationDetails extends StatefulWidget {
  final String token;
  final Map<String, dynamic> destination;

  const DestinationDetails({Key? key, required this.destination, required this.token})
      : super(key: key);

  @override
  _DestinationDetailsState createState() => _DestinationDetailsState();
}

class _DestinationDetailsState extends State<DestinationDetails> {
  late String selectedImage;

  final List<Map<String, dynamic>> destinationImages = [
    {'name': 'Hebron', 'imagePath': 'assets/Images/Profiles/Tourist/9T.jpg'},
    {'name': 'Dead Sea', 'imagePath': 'assets/Images/Profiles/Tourist/10T.jpg'},
    {
      'name': 'Garden Cafe',
      'imagePath': 'assets/Images/Profiles/Tourist/11T.jpg'
    },
    {
      'name': 'Sufi Cafe',
      'imagePath': 'assets/Images/Profiles/Tourist/12T.jpg'
    },
  ];

  final Map<String, dynamic> destinationDetails = {
    'About':
        'Nablus, a Palestinian enclave, breathes history through its ancient streets and vibrant markets, embodying resilience and rich heritage.',
    'Category': 'Historical Site',
    'Opening Time': '09:00',
    'Closing Time': '23:00',
    'Working Days': [
      'Saturday',
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday'
    ],
    'Weather': '23°C',
    'Rating': '4.5',
    'Cost Level': 'Budget Friendly',
    'Services': [
      'Public restrooms are available',
      'Convenient access to a paid parking garage',
      'There are nearby gas stations',
      'Wheelchair ramps for enhanced accessibility',
      'Play areas for children are available',
      'Nearby restaurants for dining options',
      'Accessible health care centers are available',
      'Additional services are also provided'

      /// Additional services as needed
    ],
  };

  @override
  void initState() {
    super.initState();
    selectedImage = widget.destination['imagePath'];
  }

  // A function to retrieve all of the destination details.
  Future<void> getDestinationDetails() async {
    final url =
        Uri.parse('https://touristine.onrender.com/getDestinationDetails');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          // 'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        // Success.
        // Jenan, here I need to retrieve three list-maps about the destination info, like the
        // format of the ones in my code called "destinationImages", "destinationDetails" and "ratings",
        // please refer to lines 21, 34, and 756 resoectively to see their format.
      } else if (response.statusCode == 500) {
        // Failed.
      } else {
        // ignore: use_build_context_synchronously
        // showCustomSnackBar(context, "Failed to fetch recommendations",
        //     bottomMargin: 0);
      }
    } catch (error) {
      print('Failed to fetch recommendations: $error');
    }
  }

  // A function to retrieve the users review data.
  Future<void> getAllReviews() async {
    final url = Uri.parse('https://touristine.onrender.com/getAllReviews');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      if (response.statusCode == 200) {
        // Success.
        // Jenan, I want to retrieve a list (map) in this format from your side - containing these info.
        /* final List<Map<String, dynamic>> reviews = [
          {
            'firstName': 'Israa',
            'lastName': 'Odeh',
            'stars': 5,
            'commentTitle': 'Amazing Experience',
            'commentContent':
                'The place is breathtaking, and the staff is incredibly friendly. I highly recommend it!',
          },
          {
            ///second user........
          },
          ////............................... other users' reviews in a similar way.
        ]; */
      } else if (response.statusCode == 500) {
        // Failed.
      } else {
        // ignore: use_build_context_synchronously
        // showCustomSnackBar(context, "Failed to fetch recommendations",
        //     bottomMargin: 0);
      }
    } catch (error) {
      print('Failed to fetch your review: $error');
    }
  }

  void updateSelectedImage(String imagePath) {
    setState(() {
      selectedImage = imagePath;
    });
  }

  String _getFormattedDays(List<String> days) {
    return days.length >= 3 && days.length <= 7
        ? '${days.first} - ${days.last}'
        : days.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        body: Stack(
          children: [
            Image.asset(
              "assets/Images/Profiles/Tourist/homeBackground.jpg",
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top),
                  Image.asset(
                    selectedImage,
                    width: 500,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 8),
                  ImagesList(
                    listOfImages: destinationImages,
                    onImageSelected: updateSelectedImage,
                  ),
                  const SizedBox(height: 8),
                  const TabBar(
                    isScrollable: true,
                    indicatorColor: Color(0xFF1E889E),
                    indicatorPadding: EdgeInsets.symmetric(horizontal: 15),
                    indicatorWeight: 3,
                    labelColor: Color(0xFF1E889E),
                    unselectedLabelColor: Color.fromARGB(182, 30, 137, 158),
                    labelStyle: TextStyle(fontSize: 30.0, fontFamily: 'Zilla'),
                    unselectedLabelStyle:
                        TextStyle(fontSize: 25.0, fontFamily: 'Zilla'),
                    tabs: [
                      Tab(text: 'About'),
                      Tab(text: 'Description'),
                      Tab(text: 'Services'),
                      Tab(text: 'Location'),
                      Tab(text: 'Reviews'),
                    ],
                  ),
                  SizedBox(
                    height: 320,
                    child: TabBarView(
                      children: [
                        _buildAboutTab(),
                        _buildDescriptionTab(),
                        _buildServicesTab(),
                        _buildLocationsTab(),
                        _buildReviewsTab(),
],
                  ),
                ),
              ],
            ),
          ),
          // Floating Action Button
          Positioned(
            top: 26.0,
            left: 5.0,
            child: FloatingActionButton(
              heroTag: 'BackHome',
              onPressed: () {
                Navigator.of(context).pop();
              },
               backgroundColor: Colors.transparent,
               elevation: 0,
              child: const Icon(FontAwesomeIcons.arrowLeft),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildAboutTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                double additionalMargin = 0;
                if (constraints.maxHeight > 295) {
                  additionalMargin = 10.0;
                }

                return Padding(
                  padding: EdgeInsets.only(bottom: 5.0 + additionalMargin),
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: 295,
                    ),
                    width: 400,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(33, 20, 89, 121),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 13.0, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 2.0),
                                  child: Text(
                                    '${widget.destination['name']}',
                                    style: const TextStyle(
                                      fontSize: 35,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Gabriola',
                                      color: Color.fromARGB(195, 18, 83, 96),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(125, 255, 255, 255),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Text(
                                  '${destinationDetails['Category']}',
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Gabriola',
                                    color: Color.fromARGB(195, 18, 83, 96),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${destinationDetails['About']}',
                            style: const TextStyle(
                              fontSize: 31,
                              fontFamily: 'Gabriola',
                              color: Color.fromARGB(255, 23, 103, 120),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Container(
            height: 295,
            width: 400,
            decoration: BoxDecoration(
              color: const Color.fromARGB(33, 20, 89, 121),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 13.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: const Color(0xFF1E889E),
                        ),
                        width: 177.0,
                        height: 65.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.cloudSunRain,
                              color: Colors.white,
                              size: 38,
                            ),
                            const SizedBox(width: 25.0),
                            Text(
                              '${destinationDetails['Weather']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Time New Roman',
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: const Color(0xFF1E889E),
                        ),
                        width: 177.0,
                        height: 65.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.rankingStar,
                              color: Colors.white,
                              size: 38,
                            ),
                            const SizedBox(width: 25.0),
                            Text(
                              '${destinationDetails['Rating']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Time New Roman',
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: const Color(0xFF1E889E),
                    ),
                    width: 370.0,
                    height: 60.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.clock,
                          color: Colors.white,
                          size: 38,
                        ),
                        const SizedBox(width: 0.0),
                        Text(
                          '${destinationDetails['Opening Time']} - ${destinationDetails['Closing Time']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Time New Roman',
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: const Color(0xFF1E889E),
                    ),
                    width: 370.0,
                    height: 60.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 30.0),
                          child: FaIcon(
                            FontAwesomeIcons.calendar,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 30.0),
                          child: Text(
                            _getFormattedDays(
                                destinationDetails['Working Days']),
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Time New Roman',
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: const Color(0xFF1E889E),
                    ),
                    width: 370.0,
                    height: 60.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 30.0),
                          child: FaIcon(
                            FontAwesomeIcons.dollarSign,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 30.0),
                          child: Text(
                            destinationDetails['Cost Level'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Time New Roman',
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesTab() {
    ScrollController scrollController = ScrollController();

    // Define a list of icons for each service.
    List<IconData> serviceIcons = [
      FontAwesomeIcons.restroom,
      FontAwesomeIcons.squareParking,
      FontAwesomeIcons.gasPump,
      FontAwesomeIcons.wheelchair,
      FontAwesomeIcons.child,
      FontAwesomeIcons.utensils,
      // FontAwesomeIcons.paw,
      // FontAwesomeIcons.handHoldingHeart,
      FontAwesomeIcons.suitcaseMedical,
      FontAwesomeIcons.circleCheck
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          ScrollbarTheme(
            data: ScrollbarThemeData(
              thumbColor: MaterialStateProperty.all(
                  const Color.fromARGB(125, 23, 102, 118)),
              radius: const Radius.circular(10),
            ),
            child: Scrollbar(
              controller: scrollController,
              trackVisibility: true,
              thumbVisibility: true,
              thickness: 10,
              child: Container(
                height: 295,
                width: 400,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(33, 20, 89, 121),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 13.0, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vertical scrollable list of services.
                      SizedBox(
                        height: 295,
                        child: ListView.builder(
                          controller: scrollController,
                          scrollDirection: Axis.vertical,
                          itemCount: destinationDetails['Services'].length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: (index ==
                                      destinationDetails['Services'].length - 1)
                                  ? const EdgeInsets.only(bottom: 20)
                                  : const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: const Color.fromARGB(162, 30, 137, 158),
                              ),
                              height: 100,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Icon for the service, using the corresponding icon from the list
                                    Icon(
                                      index >= 8
                                          ? serviceIcons[7]
                                          : serviceIcons[index],
                                      color: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      size: 35,
                                    ),
                                    // Text description for the service
                                    const SizedBox(
                                      width: 30,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${destinationDetails['Services'][index]}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Times New Roman',
                                          fontSize: 23,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationsTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Container(
            height: 295,
            width: 400,
            decoration: BoxDecoration(
              color: const Color.fromARGB(33, 20, 89, 121),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 10, left: 13.0, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add distance and estimated time labels with icons.
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: const Color(0xFF1E889E),
                        ),
                        width: 370.0,
                        height: 60.0,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 30.0),
                              child: FaIcon(
                                FontAwesomeIcons.locationDot,
                                color: Colors.white,
                                size: 38,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 30.0),
                              child: Text(
                                '5 km away',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Time New Roman',
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: const Color(0xFF1E889E),
                        ),
                        width: 370.0,
                        height: 60.0,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 30.0),
                              child: FaIcon(
                                FontAwesomeIcons.clock,
                                color: Colors.white,
                                size: 38,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 30.0),
                              child: Text(
                                '15 mins away',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Time New Roman',
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 80),
                  // Buttons for getting distance and time, and getting directions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          backgroundColor: const Color(0xFF1E889E),
                          textStyle: const TextStyle(
                            fontSize: 30,
                            fontFamily: 'Zilla',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.route,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Text('Fetch Route'),
                          ],
                        ),
                      ),
                      FloatingActionButton(
                        heroTag: 'Get Directions',
                        backgroundColor: const Color(0xFF1E889E),
                        onPressed: () {
                          // Add logic to get directions.
                        },
                        child: const FaIcon(FontAwesomeIcons.diamondTurnRight),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    // Sample data for reviews.
    final List<Map<String, dynamic>> ratings = [
      {'stars': 5, 'count': 120},
      {'stars': 4, 'count': 80},
      {'stars': 3, 'count': 40},
      {'stars': 2, 'count': 20},
      {'stars': 1, 'count': 10},
    ];

    final List<Map<String, dynamic>> reviews = [
      {
        'firstName': 'Mohamed',
        'lastName': 'Ali',
        'stars': 5,
        'commentTitle': 'Amazing Experience',
        'commentContent':
            'The place is breathtaking, and the staff is incredibly friendly. I highly recommend it!',
      },
      {
        'firstName': 'Fatima',
        'lastName': 'Khaled',
        'stars': 4,
        'commentTitle': 'Great Place',
        'commentContent':
            'A wonderful atmosphere and delicious food. I enjoyed every moment of my visit.',
      },
      {
        'firstName': 'Yousef',
        'lastName': 'Saleh',
        'stars': 3,
        'commentTitle': 'Excellent Experience',
        'commentContent':
            'The inspiration here is amazing, and I love it. Looking forward to coming back!',
      },
      {
        'firstName': 'Layla',
        'lastName': 'Mohamed',
        'stars': 4,
        'commentTitle': 'Beautiful Place',
        'commentContent':
            'You\'ll find success everywhere you go. The ambiance is truly remarkable.',
      },
      {
        'firstName': 'Ali',
        'lastName': 'Noor',
        'stars': 2,
        'commentTitle': 'Needs Improvement',
        'commentContent':
            'Service was slow, and the place needs some improvements. Hope to see changes.',
      },
      {
        'firstName': 'Nourhan',
        'lastName': 'Mustafa',
        'stars': 5,
        'commentTitle': 'Unique Experience',
        'commentContent':
            "I'm very happy with my experience here. Thank you for providing such a unique experience!",
      },
      {
        'firstName': 'Hussein',
        'lastName': 'Ali',
        'stars': 3,
        'commentTitle': 'Good Place',
        'commentContent':
            "Not bad, but there are some aspects that could be improved. Overall, it's a decent place.",
      },
      {
        'firstName': 'Sara',
        'lastName': 'Ahmed',
        'stars': 4,
        'commentTitle': 'Great View',
        'commentContent':
            'I love the stunning view and the peaceful atmosphere. It was a refreshing experience.',
      },
      {
        'firstName': 'Omar',
        'lastName': 'Salah',
        'stars': 5,
        'commentTitle': 'Fantastic Experience',
        'commentContent':
            'The best experience I ever had! The service, ambiance, and everything exceeded my expectations.',
      },
      {
        'firstName': 'Hala',
        'lastName': 'Hassan',
        'stars': 4,
        'commentTitle': 'Very Good',
        'commentContent':
            'A very good experience, I will definitely come back for another visit.',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Container(
            height: 295,
            width: 400,
            decoration: BoxDecoration(
              color: const Color.fromARGB(33, 20, 89, 121),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 10, left: 13.0, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 150,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: ratings.map((rating) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Star icons.
                              Row(
                                children: List.generate(
                                  rating['stars'],
                                  (index) => const Row(
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.solidStar,
                                        color:
                                            Color.fromARGB(255, 211, 171, 12),
                                        size: 18,
                                      ),
                                      SizedBox(width: 5),
                                    ],
                                  ),
                                ),
                              ),
                              // Dynamic filled bars.
                              Container(
                                width: 200,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(59, 30, 137, 158),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: rating['count'] /
                                      ratings.fold<int>(
                                          0,
                                          (int sum, review) =>
                                              sum + (review['count'] as int)),

                                  // rating['count'] / ratings[0]['count'],
                                  child: Container(
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          167, 30, 137, 158),
                                      borderRadius: BorderRadius.circular(10.0),
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
                  // Number of ratings.
                  const SizedBox(height: 8),
                  Text(
                    'Total Ratings: ${ratings.fold<int>(0, (int sum, review) => sum + (review['count'] as int))}',
                    style: const TextStyle(
                      color: Color(0xFF1E889E),
                      fontFamily: 'Gabriola',
                      fontSize: 35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Buttons
                  // const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          getAllReviews();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AllReviewsPage(reviews: reviews),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 10,
                          ),
                          backgroundColor: const Color(0xFF1E889E),
                          textStyle: const TextStyle(
                            fontSize: 30,
                            fontFamily: 'Zilla',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text('See All'),
                      ),
                      FloatingActionButton(
                        heroTag: 'Add Review',
                        backgroundColor: const Color(0xFF1E889E),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddingReviewPage(token: widget.token,)),
                          );
                        },
                        child: const FaIcon(FontAwesomeIcons.plus),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
