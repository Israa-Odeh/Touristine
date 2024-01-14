import 'package:touristine/WebApplication/Profiles/Tourist/MainPages/planMaker/custom_bottom_sheet.dart';
import 'package:touristine/WebApplication/Profiles/Tourist/MainPages/planMaker/numeric_stepper.dart';
import 'package:touristine/WebApplication/Profiles/Tourist/MainPages/planMaker/plan_places.dart';
import 'package:touristine/WebApplication/Profiles/Tourist/Profile/Sections/interests_filling.dart';
import 'package:touristine/WebApplication/Notifications/snack_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

class MakePlanTab extends StatefulWidget {
  final String token;

  const MakePlanTab({super.key, required this.token});

  @override
  _MakePlanTabState createState() => _MakePlanTabState();
}

class _MakePlanTabState extends State<MakePlanTab> {
  bool children = false;
  bool teenagers = false;
  bool adults = false;
  bool elders = false;

  List<String> destinationsList = [
    'Jerusalem',
    'Nablus',
    'Ramallah',
    'Bethlehem'
  ];

  TextEditingController dateController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController groupSizeController = TextEditingController();

  Color dateBorderIconColor = Colors.grey;
  Color startTimeBorderIconColor = Colors.grey;
  Color endTimeBorderIconColor = Colors.grey;

  FocusNode durationFocusNode = FocusNode();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedStartTime = TimeOfDay.now();
  TimeOfDay selectedEndTime = TimeOfDay.now();
  late NumericStepButton groupSizeStepper;

  late PageController pageController;
  int currentPage = 0;

  Map<String, dynamic> planDescription = {};
  List<Map<String, dynamic>> planContents = [];

  @override
  void initState() {
    super.initState();
    // getDestinationsList();
    pageController = PageController();

    groupSizeStepper = NumericStepButton(
      minValue: 1,
      maxValue: 100,
      onChanged: (value) {
        setState(() {
          groupSizeController.text = value.toString();
        });
      },
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  // A function to store the plan creation details.
  Future<void> storePlan() async {
    List<String> selectedAgeCats = getSelectedAgeCats();

    String groupCount =
        groupSizeController.text.isEmpty ? "1" : groupSizeController.text;

    // Israa, print statements will be deleted after finishing this code completely.
    print(selectedDest.toString());
    print(dateController.text.toString());
    print(startTimeController.text.toString());
    print(endTimeController.text.toString());
    print(durationController.text.toString());
    print(groupCount.toString());
    print(selectedAgeCats.join(', '));

    final url = Uri.parse('https://touristine.onrender.com/store-plan');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {
          'destination': selectedDest.toString(),
          'date': dateController.text.toString(),
          'startTime': startTimeController.text.toString(),
          'endTime': endTimeController.text.toString(),
          'tripDuration': durationController.text.toString(),
          'groupCount': groupCount.toString(),
          'ageCategories': selectedAgeCats.join(','),
        },
      );

      if (response.statusCode == 200) {
        // Success.
        // Jenan I need to retreive two things: a map and a list similar to the
        // format for the ones at the end of the file, at lines 1037 and 1052.
        // Parse the JSON response.
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Extract plan description and contents.
        planDescription = responseData['planDescription'];
        final List<dynamic> rawPlanContents = responseData['planContents'];

        // Convert rawPlanContents to List<Map<String, dynamic>>.
        planContents = List<Map<String, dynamic>>.from(rawPlanContents);

        print("Plan Description & Plan Contents");
        print(planDescription);
        print("\n");
        print(planContents);
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Error storing the plan contents',
            bottomMargin: 370);
      }
    } catch (error) {
      print('Error storing the plan: $error');
    }
  }

  // A function to get the available destinations in the app.
  Future<void> getDestinationsList() async {
    final url =
        Uri.parse('https://touristine.onrender.com/get-destinations-list');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        // Success.
        // Jenan I need to retreive a list of the available destinations, using this format:
        /* 
        List<String> destinationsList = [
          'Destination 1',
          'Destination 2',
          'Destination 3',
          'Destination 4',
          'Destination 5',
          'Destination 6',
          'Destination 7',
          'Destination 8',
          'Destination 9',
        ];
        */
      } else {
        // Handle other cases....
        print(
            'Failed to get the destinations list. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error getting destinations list: $error');
    }
  }

  // Function to get selected age categories.
  List<String> getSelectedAgeCats() {
    List<String> selectedageCats = [];

    if (children) {
      selectedageCats.add('Children');
    }
    if (teenagers) {
      selectedageCats.add('Teenagers');
    }
    if (adults) {
      selectedageCats.add('Adults');
    }
    if (elders) {
      selectedageCats.add('Elders');
    }
    return selectedageCats;
  }

  void nextPage() {
    if (currentPage < 3) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        currentPage++;
      });
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        currentPage--;
      });
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
        updateColors();
      });
    }
  }

  void updateColors() {
    setState(() {
      dateBorderIconColor = const Color(0xFF1E889E);
    });
  }

  Future<void> selectStartTime(BuildContext context) async {
    final TimeOfDay? pickedStartTime = await showTimePicker(
      context: context,
      initialTime: selectedStartTime,
    );

    if (pickedStartTime != null &&
        pickedStartTime.hour >= 5 &&
        pickedStartTime.hour <= 20) {
      setState(() {
        selectedStartTime = pickedStartTime;
        startTimeController.text =
            '${pickedStartTime.hour.toString().padLeft(2, '0')}:${pickedStartTime.minute.toString().padLeft(2, '0')}';
        updateStartTimeColors();
        if (endTimeController.text.isNotEmpty) {
          calculateDuration();
        }
      });
    } else {
      if (pickedStartTime != null) {
        startTimeController.text = "";
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Start time must be from 5 AM to 8 PM',
            bottomMargin: 0);
      }
    }
  }

  Future<void> selectEndTime(BuildContext context) async {
    final TimeOfDay? pickedEndTime = await showTimePicker(
      context: context,
      initialTime: selectedEndTime,
    );

    if (pickedEndTime != null &&
        pickedEndTime.hour >= 7 &&
        pickedEndTime.hour <= 22) {
      setState(() {
        selectedEndTime = pickedEndTime;
        endTimeController.text =
            '${pickedEndTime.hour.toString().padLeft(2, '0')}:${pickedEndTime.minute.toString().padLeft(2, '0')}';
        if (startTimeController.text.isNotEmpty) {
          calculateDuration();
        }
        updateEndTimeColors();
      });
    } else {
      if (pickedEndTime != null) {
        endTimeController.text = "";
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'End time must be from 7 AM to 10 PM',
            bottomMargin: 0);
      }
    }
  }

  void updateStartTimeColors() {
    setState(() {
      startTimeBorderIconColor = const Color(0xFF1E889E);
    });
  }

  void updateEndTimeColors() {
    setState(() {
      endTimeBorderIconColor = const Color(0xFF1E889E);
    });
  }

  void calculateDuration() {
    final startDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedStartTime.hour,
      selectedStartTime.minute,
    );
    final endDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedEndTime.hour,
      selectedEndTime.minute,
    );

    final duration = endDateTime.difference(startDateTime);
    final hours = duration.inHours;

    if (hours >= 2) {
      final minutes = duration.inMinutes.remainder(60);

      setState(() {
        durationController.text = '$hours hours $minutes minutes';
      });
    } else {
      showCustomSnackBar(
        context,
        'Minimum trip duration is 2 hours',
        bottomMargin: 0,
      );
      durationController.text = '';
    }
  }

  String selectedDest = '';
  void showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return CustomBottomSheet(
          itemsList: destinationsList,
          height: 260,
        );
      },
    ).then((value) {
      // Handle the selected item from the bottom sheet.
      if (value != null) {
        setState(() {
          selectedDest = value;
        });
      }
    });
  }

  bool validateForm() {
    if (dateController.text.isEmpty) {
      showCustomSnackBar(context, 'Please select a trip date', bottomMargin: 0);
      return false;
    }

    if (startTimeController.text.isEmpty) {
      showCustomSnackBar(context, 'Please select a start time',
          bottomMargin: 0);
      return false;
    }

    if (endTimeController.text.isEmpty) {
      showCustomSnackBar(context, 'Please select an end time', bottomMargin: 0);
      return false;
    }
    if (durationController.text.isEmpty) {
      showCustomSnackBar(context, 'Please select valid times', bottomMargin: 0);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 450,
              child: PageView(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  buildInterestsPage(),
                  Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Image.asset(
                                  'assets/Images/Profiles/Tourist/PlanMaker/TimeDate.gif',
                                  height: 390,
                                  fit: BoxFit.cover),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 50.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        thickness: 1,
                                        color: Color(0xFF1E889E),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Text(
                                        "Plan Your Day",
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontFamily: 'Gabriola',
                                          color:
                                              Color.fromARGB(255, 19, 87, 100),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        thickness: 1,
                                        color: Color(0xFF1E889E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              buildDateTimeInput(
                                'Date Selection',
                                dateController,
                                dateBorderIconColor,
                                FontAwesomeIcons.calendarDays,
                                () => selectDate(context),
                              ),
                              SizedBox(
                                  height: startTimeController.text.isNotEmpty
                                      ? 20
                                      : 10),
                              buildDateTimeInput(
                                'Start Time',
                                startTimeController,
                                startTimeBorderIconColor,
                                FontAwesomeIcons.clock,
                                () => selectStartTime(context),
                              ),
                              SizedBox(
                                  height: endTimeController.text.isNotEmpty
                                      ? 20
                                      : 10),
                              buildDateTimeInput(
                                'End Time',
                                endTimeController,
                                endTimeBorderIconColor,
                                FontAwesomeIcons.clock,
                                () => selectEndTime(context),
                              ),
                              SizedBox(
                                  height: durationFocusNode.hasFocus ? 20 : 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 110.0),
                                child: TextFormField(
                                  controller: durationController,
                                  focusNode: durationFocusNode,
                                  onTap: () {
                                    setState(() {
                                      durationFocusNode.requestFocus();
                                    });
                                  },
                                  style: const TextStyle(
                                      fontSize: 18,
                                      color: Color.fromARGB(192, 0, 0, 0)),
                                  decoration: const InputDecoration(
                                    labelText: 'Trip Duration',
                                    labelStyle: TextStyle(fontSize: 18),
                                    floatingLabelStyle: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF1E889E),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xFF1E889E),
                                      ),
                                    ),
                                  ),
                                  readOnly: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  buildGroupDetailsPage(),
                  buildSummaryPage(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                    visible: currentPage > 0,
                    child: ElevatedButton(
                      onPressed: () {
                        previousPage();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        backgroundColor: const Color(0xFF1E889E),
                        textStyle: const TextStyle(
                          fontSize: 22,
                          fontFamily: 'Zilla',
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      child: const Text('Previous'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Visibility(
                    visible: currentPage < 3,
                    child: ElevatedButton(
                      onPressed: () {
                        if (currentPage == 0) {
                          if (selectedDest.isEmpty) {
                            showCustomSnackBar(
                                context, 'Please select a destination',
                                bottomMargin: 0);
                          } else {
                            nextPage();
                          }
                        } else if (currentPage == 1) {
                          if (validateForm()) {
                            nextPage();
                          }
                        } else if (currentPage == 2) {
                          int groupCount = int.parse(
                              groupSizeController.text.isEmpty
                                  ? "1"
                                  : groupSizeController.text);
                          List<String> selectedAgeCats = getSelectedAgeCats();

                          if (selectedAgeCats.isNotEmpty) {
                            if (groupCount == 1 && selectedAgeCats.length > 1) {
                              showCustomSnackBar(context,
                                  'Please select a single age category',
                                  bottomMargin: 0);
                            } else if (groupCount == 2 &&
                                selectedAgeCats.length > 2) {
                              showCustomSnackBar(context,
                                  'Please select 1 to 2 age categories',
                                  bottomMargin: 0);
                            } else if (groupCount == 3 &&
                                selectedAgeCats.length > 3) {
                              showCustomSnackBar(context,
                                  'Please select 1 to 3 age categories',
                                  bottomMargin: 0);
                            } else {
                              nextPage();
                            }
                          } else {
                            showCustomSnackBar(
                                context, 'Please select an age category',
                                bottomMargin: 0);
                          }
                        } else {
                          nextPage();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 20,
                        ),
                        backgroundColor: const Color(0xFF1E889E),
                        textStyle: const TextStyle(
                          fontSize: 22,
                          fontFamily: 'Zilla',
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      child: const Text('Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPageContent(Widget content) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: content,
    );
  }

  Widget buildInterestsPage() {
    return buildPageContent(
      Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Image.asset(
                  'assets/Images/Profiles/Tourist/PlanMaker/Checklist.gif',
                  height: 390,
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Color(0xFF1E889E),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Customize Your Adventure",
                          style: TextStyle(
                            fontSize: 30,
                            fontFamily: 'Gabriola',
                            color: Color.fromARGB(255, 19, 87, 100),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Color(0xFF1E889E),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'For a journey of discovery and unforgettable moments,\n select a destination and specify your interests',
                  style: TextStyle(
                    fontFamily: 'Gabriola',
                    fontSize: 25,
                    color: Color(0xFF455a64),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: showBottomSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 231, 231, 231),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: SizedBox(
                    height: 50,
                    width: 350,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Text(
                            selectedDest.isEmpty
                                ? 'Select Destination'
                                : selectedDest,
                            style: const TextStyle(
                                color: Color.fromARGB(163, 0, 0, 0),
                                fontSize: 18),
                          ),
                        ),
                        const FaIcon(
                          FontAwesomeIcons.compass,
                          color: Color.fromARGB(163, 0, 0, 0),
                          size: 28,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 106.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              InterestsFillingPage(token: widget.token),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 20,
                      ),
                      backgroundColor: const Color(0xFF1E889E),
                      textStyle: const TextStyle(
                        fontSize: 25,
                        fontFamily: 'Zilla',
                        fontWeight: FontWeight.w300,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.listCheck,
                          size: 22,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Text('Fill Now'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDateTimeInput(
    String labelText,
    TextEditingController controller,
    Color borderIconColor,
    IconData icon,
    Function() onTap,
  ) {
    return SizedBox(
      height: 60,
      width: 380,
      child: InkWell(
        onTap: onTap,
        child: IgnorePointer(
          child: TextFormField(
            controller: controller,
            style: const TextStyle(
                fontSize: 18, color: Color.fromARGB(192, 0, 0, 0)),
            decoration: InputDecoration(
              labelStyle: const TextStyle(fontSize: 18),
              labelText: labelText,
              floatingLabelStyle: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w400,
                color: Color(0xFF1E889E),
              ),
              suffixIcon: Icon(icon, color: borderIconColor, size: 24),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: borderIconColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: borderIconColor,
                ),
              ),
              hintStyle: TextStyle(
                color: borderIconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildGroupDetailsPage() {
    return buildPageContent(
      Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Image.asset(
                    'assets/Images/Profiles/Tourist/PlanMaker/destinationList.png',
                    height: 390,
                    fit: BoxFit.cover),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Color(0xFF1E889E),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Create Memorable Journeys Together',
                          style: TextStyle(
                            fontFamily: 'Gabriola',
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF455a64),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Color(0xFF1E889E),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E889E),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.listOl,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Group Count',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(height: 52, width: 200, child: groupSizeStepper),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 100),
                  child: Text(
                    'Select age categories',
                    style: TextStyle(
                      fontFamily: 'Gabriola',
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF455a64),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100),
                  child: buildCheckboxListTile(
                    leftPadding: 145,
                    titleText: 'Children (0-12 years)',
                    value: children,
                    onChanged: (newValue) {
                      setState(() {
                        children = newValue!;
                      });
                    },
                    assetImagePath:
                        'assets/Images/Profiles/Tourist/PlanMaker/childrenIcon.png',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100),
                  child: buildCheckboxListTile(
                    leftPadding: 134,
                    titleText: 'Teenagers (13-17 years)',
                    value: teenagers,
                    onChanged: (newValue) {
                      setState(() {
                        teenagers = newValue!;
                      });
                    },
                    assetImagePath:
                        'assets/Images/Profiles/Tourist/PlanMaker/teenagersIcon.png',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100),
                  child: buildCheckboxListTile(
                    leftPadding: 155,
                    titleText: 'Adults (18-59 years)',
                    value: adults,
                    onChanged: (newValue) {
                      setState(() {
                        adults = newValue!;
                      });
                    },
                    assetImagePath:
                        'assets/Images/Profiles/Tourist/PlanMaker/adultsIcon.png',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100),
                  child: buildCheckboxListTile(
                    leftPadding: 165,
                    titleText: 'Elders (60+ years)',
                    value: elders,
                    onChanged: (newValue) {
                      setState(() {
                        elders = newValue!;
                      });
                    },
                    assetImagePath:
                        'assets/Images/Profiles/Tourist/PlanMaker/seniorsIcon.png',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ListTileTheme buildCheckboxListTile({
    required String titleText,
    required bool value,
    required double leftPadding,
    required Function(bool?) onChanged,
    required String assetImagePath,
  }) {
    return ListTileTheme(
      horizontalTitleGap: 0,
      child: CheckboxListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: const Color(0xFF1E889E),
        title: Row(
          children: [
            Text(
              titleText,
              style: const TextStyle(
                fontSize: 24,
                fontFamily: 'Gabriola',
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: leftPadding),
              child: Image.asset(
                assetImagePath,
                width: 35,
                height: 35,
              ),
            ),
          ],
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget buildSummaryPage() {
    return buildPageContent(
      Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Image.asset(
                    'assets/Images/Profiles/Tourist/PlanMaker/Confirmed.gif',
                    height: 390,
                    fit: BoxFit.cover),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Color(0xFF1E889E),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Begin Your Adventure",
                          style: TextStyle(
                            fontSize: 30,
                            fontFamily: 'Gabriola',
                            color: Color.fromARGB(255, 19, 87, 100),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Color(0xFF1E889E),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Create the plan and begin \nyour journey!',
                  style: TextStyle(
                    fontFamily: 'Gabriola',
                    fontSize: 28,
                    color: Color(0xFF455a64),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 160.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      await storePlan();
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PlanPlacesPage(
                            token: widget.token,
                            planContents: planContents,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 20,
                      ),
                      backgroundColor: const Color(0xFF1E889E),
                      textStyle: const TextStyle(
                        fontSize: 25,
                        fontFamily: 'Zilla',
                        fontWeight: FontWeight.w300,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.circleCheck,
                          size: 22,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Text('Create Plan'),
                      ],
                    ),
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
