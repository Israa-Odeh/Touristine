import 'package:touristine/AndroidMobileApp/Profiles/Tourist/MainPages/Home/images_list.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DestinationDetails extends StatefulWidget {
  final String token;
  final Map<String, dynamic> destination;
  Map<String, dynamic> destinationDetails;
  List<Map<String, dynamic>> destinationImages;

  DestinationDetails(
      {super.key,
      required this.token,
      required this.destination,
      required this.destinationDetails,
      required this.destinationImages});

  @override
  _DestinationDetailsState createState() => _DestinationDetailsState();
}

class _DestinationDetailsState extends State<DestinationDetails> {
  late String selectedImage;

  @override
  void initState() {
    super.initState();
    selectedImage =
        widget.destination['image'] ?? widget.destination['imagePath'];
  }

  @override
  void dispose() {
    super.dispose();
  }

  void updateSelectedImage(String imagePath) {
    setState(() {
      selectedImage = imagePath;
    });
  }

  String getFormattedDays(List<dynamic> days) {
    // Define the order of days.
    List<String> orderOfDays = [
      "Saturday",
      "Sunday",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
    ];

    // Check if the given days are in the desired order.
    bool isInOrder = List.generate(days.length, (index) => index)
        .every((index) => days[index] == orderOfDays[index]);

    // Sort the days if they are not in order.
    if (!isInOrder) {
      days.sort((a, b) => orderOfDays.indexOf(a) - orderOfDays.indexOf(b));
    }

    // Check if the days are in sequence.
    bool isInSequence = List.generate(days.length, (index) => index)
        .every((index) => orderOfDays.indexOf(days[index]) == index);

    // Identify consecutive days.
    List<String> formattedDays = [];
    int startConsecutiveIndex = 0;
    for (int i = 1; i < days.length; i++) {
      if (orderOfDays.indexOf(days[i]) ==
          orderOfDays.indexOf(days[i - 1]) + 1) {
        // Continue checking consecutive days.
        continue;
      } else {
        // Consecutive sequence ended.
        if (startConsecutiveIndex == i - 1) {
          // Consecutive days were just one day, add that day.
          formattedDays.add(days[startConsecutiveIndex].toString());
        } else {
          // Add the consecutive range.
          formattedDays.add(
              '${days[startConsecutiveIndex].toString()}-${days[i - 1].toString()}');
        }
        // Reset start index for the next consecutive sequence.
        startConsecutiveIndex = i;
      }
    }

    // Add the last day or consecutive range.
    if (startConsecutiveIndex == days.length - 1) {
      formattedDays.add(days[startConsecutiveIndex].toString());
    } else {
      formattedDays.add(
          '${days[startConsecutiveIndex].toString()}-${days[days.length - 1].toString()}');
    }

    // Return the formatted string based on the conditions.
    if (days.length == 1) {
      return days.first.toString();
    } else if (days.length == 2) {
      return '${days.first}, ${days.last}';
    } else {
      return (isInSequence)
          ? '${days.first} - ${days.last}'
          : formattedDays.join(', ');
    }
  }

  void showWDDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Working Days"),
          content: Text(
            getFormattedDays(widget.destinationDetails['WorkingDays']),
            style: const TextStyle(
              fontFamily: 'Time New Roman',
              fontSize: 18,
              fontWeight: FontWeight.normal,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Close',
                style: TextStyle(
                  fontSize: 22.0,
                  fontFamily: 'Zilla',
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 200, 50, 27),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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
                  Image.network(
                    selectedImage,
                    width: 500,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 8),
                  if (widget.destinationImages.isNotEmpty)
                    ImagesList(
                      listOfImages: widget.destinationImages,
                      onImageSelected: updateSelectedImage,
                    ),
                  if (widget.destinationImages.isEmpty)
                    const SizedBox(height: 130),
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
                    ],
                  ),
                  SizedBox(
                    height: 320,
                    child: TabBarView(
                      children: [
                        _buildAboutTab(),
                        _buildDescriptionTab(),
                        _buildServicesTab(),
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

  String getPlaceCategory(String placeCategory) {
    if (placeCategory.toLowerCase() == "coastalareas") {
      return "Coastal Area";
    } else if (placeCategory.toLowerCase() == "mountains") {
      return "Mountain";
    } else if (placeCategory.toLowerCase() == "nationalparks") {
      return "National Park";
    } else if (placeCategory.toLowerCase() == "majorcities") {
      return "Major City";
    } else if (placeCategory.toLowerCase() == "countryside") {
      return "Countryside";
    } else if (placeCategory.toLowerCase() == "historicalsites") {
      return "Historical Site";
    } else if (placeCategory.toLowerCase() == "religiouslandmarks") {
      return "Religious Landmark";
    } else if (placeCategory.toLowerCase() == "aquariums") {
      return "Aquarium";
    } else if (placeCategory.toLowerCase() == "zoos") {
      return "Zoo";
    } else {
      return "Others";
    }
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

                String destinationName = widget.destination['name'];
                String category =
                    getPlaceCategory(widget.destinationDetails['Category']);

                int totalLength = destinationName.length + category.length;

                bool displayInSameRow = totalLength <= 32;

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
                          if (displayInSameRow)
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 2.0),
                                    child: Text(
                                      destinationName,
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        125, 255, 255, 255),
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Text(
                                    category,
                                    style: const TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Gabriola',
                                      color: Color.fromARGB(195, 18, 83, 96),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (!displayInSameRow)
                            Padding(
                              padding: const EdgeInsets.only(left: 2.0),
                              child: Text(
                                destinationName,
                                style: const TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Gabriola',
                                  color: Color.fromARGB(195, 18, 83, 96),
                                ),
                              ),
                            ),
                          if (!displayInSameRow)
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(125, 255, 255, 255),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Gabriola',
                                  color: Color.fromARGB(195, 18, 83, 96),
                                ),
                              ),
                            ),
                          SizedBox(height: totalLength <= 32 ? 10 : 20),
                          Text(
                            displayInSameRow
                                ? widget.destinationDetails['About']
                                    .split('\n')
                                    .take(2)
                                    .join('\n')
                                : widget.destinationDetails['About']
                                    .split('\n')
                                    .take(3)
                                    .join('\n'),
                            maxLines: displayInSameRow ? 3 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 31,
                              fontFamily: 'Gabriola',
                              color: Color.fromARGB(255, 23, 103, 120),
                            ),
                          ),
                          // Button to show the full text in a dialog.
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  backgroundColor: const Color(0xFF1E889E),
                                  textStyle: const TextStyle(
                                    fontSize: 22,
                                    fontFamily: 'Zilla',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('About $destinationName',
                                            style: const TextStyle(
                                                color: Color.fromARGB(
                                                    255, 11, 57, 66))),
                                        content: Scrollbar(
                                          thickness: 5,
                                          trackVisibility: true,
                                          thumbVisibility: true,
                                          child: SizedBox(
                                            height: 350,
                                            child: SingleChildScrollView(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10.0),
                                                child: Text(
                                                  widget.destinationDetails[
                                                      'About'],
                                                  style: const TextStyle(
                                                    fontSize: 27,
                                                    fontFamily: 'Gabriola',
                                                    color: Color.fromARGB(
                                                        255, 23, 103, 120),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              'Close',
                                              style: TextStyle(
                                                fontSize: 22.0,
                                                fontFamily: 'Zilla',
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 200, 50, 27),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: const Text('Read More'),
                              ),
                            ],
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

  String getBudgetLevel(String budgetLevel) {
    if (budgetLevel.toLowerCase() == "midrange") {
      return "Mid-Range";
    } else if (budgetLevel.toLowerCase() == "budgetfriendly") {
      return "Budget-Friendly";
    } else {
      return "Luxurious";
    }
  }

  Widget _buildDescriptionTab() {
    ScrollController scrollController = ScrollController();
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
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: const Color(0xFF1E889E),
                            ),
                            width: 174.0,
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
                                  '${widget.destinationDetails['Weather'][0]}°C',
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
                            width: 174.0,
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
                                  widget.destinationDetails['Rating'] != null
                                      ? '${widget.destinationDetails['Rating']}'
                                      : '0.0',
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 30.0),
                              child: FaIcon(
                                FontAwesomeIcons.cloudSun,
                                color: Colors.white,
                                size: 38,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 30.0),
                              child: Text(
                                widget.destinationDetails['WeatherDescription']
                                    [0],
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
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.clock,
                              color: Colors.white,
                              size: 38,
                            ),
                            const SizedBox(width: 0.0),
                            Text(
                              '${widget.destinationDetails['OpeningTime']} - ${widget.destinationDetails['ClosingTime']}',
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
                      GestureDetector(
                        onTap: () {
                          showWDDialog(context);
                        },
                        child: Container(
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
                                  getFormattedDays(widget.destinationDetails[
                                                  'WorkingDays'])
                                              .length <=
                                          20
                                      ? getFormattedDays(widget
                                          .destinationDetails['WorkingDays'])
                                      : "Workings Days",
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
                                getBudgetLevel(
                                    widget.destinationDetails['CostLevel']),
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
                                FontAwesomeIcons.personShelter,
                                color: Colors.white,
                                size: 38,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 30.0),
                              child: Text(
                                widget.destinationDetails['sheltered']
                                            .toLowerCase() ==
                                        ("true")
                                    ? 'Sheltered'
                                    : 'Unsheltered',
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
                                FontAwesomeIcons.hourglass,
                                color: Colors.white,
                                size: 38,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 30.0),
                              child: Text(
                                '${widget.destinationDetails['EstimatedTime']} hours',
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
                      const SizedBox(height: 20.0),
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

  ServiceDescription getServiceDescription(String serviceName) {
    if (serviceName.toLowerCase() == "restrooms") {
      return ServiceDescription(
          "Public restrooms are available", FontAwesomeIcons.restroom);
    } else if (serviceName.toLowerCase() == "wheelchairramps") {
      return ServiceDescription("Wheelchair ramps for enhanced accessibility",
          FontAwesomeIcons.wheelchair);
    } else if (serviceName.toLowerCase() == "photographers") {
      return ServiceDescription(
          "Photographic services are accessible", FontAwesomeIcons.cameraRetro);
    } else if (serviceName.toLowerCase() == "healthcenters") {
      return ServiceDescription("Accessible health care centers are available",
          FontAwesomeIcons.suitcaseMedical);
    } else if (serviceName.toLowerCase() == "parking") {
      return ServiceDescription("Convenient access to a parking garage",
          FontAwesomeIcons.squareParking);
    } else if (serviceName.toLowerCase() == "kidsarea") {
      return ServiceDescription(
          "Play areas for children are available", FontAwesomeIcons.child);
    } else if (serviceName.toLowerCase() == "gasstations") {
      return ServiceDescription(
          "There are nearby gas stations", FontAwesomeIcons.gasPump);
    } else if (serviceName.toLowerCase() == "restaurants") {
      return ServiceDescription(
          "Nearby restaurants for dining options", FontAwesomeIcons.utensils);
    } else {
      return ServiceDescription(serviceName, FontAwesomeIcons.circleCheck);
    }
  }

  Widget _buildServicesTab() {
    ScrollController scrollController = ScrollController();
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
                          itemCount:
                              widget.destinationDetails['Services'].length,
                          itemBuilder: (context, index) {
                            String serviceName = widget
                                .destinationDetails['Services'][index]['name'];
                            ServiceDescription serviceDescription =
                                getServiceDescription(serviceName);

                            return Container(
                              margin: (index ==
                                      widget.destinationDetails['Services']
                                              .length -
                                          1)
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
                                      serviceDescription.icon,
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
                                        serviceDescription.description,
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
}

class ServiceDescription {
  final String description;
  final IconData icon;

  ServiceDescription(this.description, this.icon);
}
