import 'package:touristine/WebApplication/Profiles/Coordinator/MainPages/DestinationUpload/bottom_drop_list.dart';
import 'package:touristine/WebApplication/Profiles/Coordinator/MainPages/DestinationUpload/activity_list.dart';
import 'package:touristine/WebApplication/Profiles/Coordinator/MainPages/DestinationUpload/time_picker.dart';
import 'package:touristine/WebApplication/Profiles/Tourist/MainPages/planMaker/custom_bottom_sheet.dart';
import 'package:touristine/WebApplication/Notifications/snack_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'dart:typed_data';
import 'dart:convert';

import 'package:uuid/uuid.dart';

// ignore: must_be_immutable
class AddDestTab extends StatefulWidget {
  final String token;
  Map<String, dynamic> destinationToBeAdded;
  final String coordinatorCity;

  AddDestTab(
      {super.key,
      required this.token,
      this.destinationToBeAdded = const {},
      required this.coordinatorCity});

  @override
  _AddDestTabState createState() => _AddDestTabState();
}

class _AddDestTabState extends State<AddDestTab> {
  bool yes = false;
  bool no = false;

  TextEditingController destNameController = TextEditingController();
  TextEditingController destLatController = TextEditingController();
  TextEditingController destLngController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  TextEditingController otherServicesController = TextEditingController();
  TextEditingController activityTitleController = TextEditingController();
  TextEditingController activityContentController = TextEditingController();
  TextEditingController aboutController = TextEditingController();
  TextEditingController geoTagsController = TextEditingController();
  TextEditingController virtualTourController = TextEditingController();

  List<Uint8List> selectedImages = []; // List to store selected images.
  List<Map<String, String>> addedActivities = [];
  List<String> geoTags = [];

  Color destNameBorderIconColor = Colors.grey;
  Color destLatBorderIconColor = Colors.grey;
  Color destLngBorderIconColor = Colors.grey;

  Color startTimeBorderIconColor = Colors.grey;
  Color endTimeBorderIconColor = Colors.grey;

  TimeOfDay selectedStartTime = TimeOfDay.now();
  TimeOfDay selectedEndTime = TimeOfDay.now();

  late PageController pageController;
  int currentPage = 0;

  int selectedHours = 0;
  int selectedMinutes = 0;

  String selectedCity = '';

  List<String> categoriesList = [
    'Coastal Areas',
    'Mountains',
    'National Parks',
    'Major Cities',
    'Countryside',
    'Historical Sites',
    'Religious Landmarks',
    'Aquariums',
    'Zoos',
    'Others'
  ];

  List<String> budgetsList = [
    'Budget-Friendly',
    'Mid-Range',
    'Luxurious',
  ];

  List<String> compressServicesNames(List<String?> selectedServices) {
    // Map the selected services to the desired format.
    final Map<String, String> serviceMapping = {
      'Restrooms': 'restrooms',
      'Parking Areas': 'parking',
      'Nearby Gas Stations': 'gasstations',
      'Wheel Chair Ramps': 'wheelchairramps',
      'Kids Area': 'kidsarea',
      'Restaurants': 'restaurants',
      'Photographers': 'photographers',
      'Nearby Health Centers': 'healthcenters',
      'Kiosks': 'kiosks',
    };

    // Convert selected services to the desired format, filtering out null values.
    return selectedServices
        .where((service) => service != null)
        .map((service) => serviceMapping[service!])
        .where((formattedService) => formattedService != null)
        .map((formattedService) => formattedService!)
        .toList();
  }

  // A function to store the created destination details.
  Future<void> addDestination() async {
    String currentDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

    // Convert selected services to the desired format.
    List<String> formattedServices = compressServicesNames(selectedServices);

    // Convert each element in selectedVisitorTypes to lowercase.
    List<String> lowercaseVisitorTypes =
        selectedVisitorTypes.map((type) => type.toLowerCase()).toList();

    // Format time to spend (hours and minutes).
    String formattedHours = selectedHours.toString().padLeft(2, '0');
    String formattedMinutes = selectedMinutes.toString().padLeft(2, '0');

    final url =
        Uri.parse('https://touristineapp.onrender.com/add-new-destination');

    // Create a multi-part request.
    final request = http.MultipartRequest('POST', url);

    // Add headers to the request.
    request.headers['Content-Type'] = 'multipart/form-data';
    request.headers['Authorization'] = 'Bearer ${widget.token}';

    // Add destination data to the request.
    request.fields['date'] = currentDate;
    request.fields['destinationName'] = destNameController.text;
    request.fields['city'] = selectedCity;
    request.fields['category'] =
        selectedCategory.toLowerCase().replaceAll(' ', '');
    request.fields['latitude'] = destLatController.text;
    request.fields['longitude'] = destLngController.text;
    request.fields['openingTime'] = startTimeController.text;
    request.fields['closingTime'] = endTimeController.text;
    String selectedWorkingDaysJson = jsonEncode(selectedWorkingDays);
    request.fields['workingDays'] = selectedWorkingDaysJson;
    request.fields['budget'] = selectedBudget.toLowerCase().replaceAll('-', '');
    request.fields['timeToSpend'] = "$formattedHours:$formattedMinutes";
    request.fields['sheltered'] =
        yes ? yes.toString() : "false"; // true or false.
    request.fields['about'] = aboutController.text;
    String servicesJson = jsonEncode(formattedServices);
    request.fields['services'] = servicesJson;
    String otherServicesJson = jsonEncode(otherServices);
    request.fields['otherServices'] = otherServicesJson;
    String activitiesJson = jsonEncode(addedActivities);
    request.fields['activities'] = activitiesJson;
    String selectedVisitorTypesJson = jsonEncode(lowercaseVisitorTypes);
    request.fields['visitorTypes'] = selectedVisitorTypesJson;
    String selectedAgeCategoriesJson = jsonEncode(selectedAgeCategories);
    request.fields['ageCategories'] = selectedAgeCategoriesJson;
    String geoTagsJson = jsonEncode(geoTags);
    request.fields['geoTags'] = geoTagsJson;
    request.fields['virtualTourLink'] =
        virtualTourController.text.isEmpty ? "" : virtualTourController.text;
    request.fields['edited'] =
        destinationInfo.isNotEmpty && destinationInfo.containsKey('latitude')
            ? "true"
            : "false";

    print('date: ${request.fields['date']}');
    print('destinationName: ${request.fields['destinationName']}');
    print('city: ${request.fields['city']}');
    print('category: ${request.fields['category']}');
    print('latitude: ${request.fields['latitude']}');
    print('longitude: ${request.fields['longitude']}');
    print('openingTime: ${request.fields['openingTime']}');
    print('closingTime: ${request.fields['closingTime']}');
    print('workingDays: ${request.fields['workingDays']}');
    print('budget: ${request.fields['budget']}');
    print('timeToSpend: ${request.fields['timeToSpend']}');
    print('sheltered: ${request.fields['sheltered']}');
    print('about: ${request.fields['about']}');
    print('services: ${request.fields['services']}');
    print('otherServices: ${request.fields['otherServices']}');
    print('activities: ${request.fields['activities']}');
    print('visitorTypes: ${request.fields['visitorTypes']}');
    print('ageCategories: ${request.fields['ageCategories']}');
    print('geoTags: ${request.fields['geoTags']}');
    print(selectedImages);

    const uuid = Uuid();
    // Add images to the request.
    for (int i = 0; i < selectedImages.length; i++) {
      Uint8List imageBytes = selectedImages[i];
      String fileName = 'image_${uuid.v4()}.jpg';

      final image = http.MultipartFile.fromBytes(
        'images',
        imageBytes,
        filename: fileName,
      );
      request.files.add(image);
    }

    // Send the request.
    try {
      final response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        if (destinationInfo.isNotEmpty &&
            destinationInfo.containsKey('latitude')) {
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, 'The destination has been updated',
              bottomMargin: 0);
        } else {
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, 'The destination has been added',
              bottomMargin: 0);
        }
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('error')) {
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
        } else {
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, responseData['message'], bottomMargin: 0);
        }
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Error adding a new destination',
            bottomMargin: 0);
      }
    } catch (error) {
      print('Error adding the destination: $error');
    }
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

        // If end time is specified, re-validate and update if necessary.
        if (endTimeController.text.isNotEmpty) {
          validateAndUpdateEndTime();
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
      if (isEndTimeValid(selectedStartTime, pickedEndTime,
          minHourDifference: 5)) {
        setState(() {
          selectedEndTime = pickedEndTime;
          endTimeController.text =
              '${pickedEndTime.hour.toString().padLeft(2, '0')}:${pickedEndTime.minute.toString().padLeft(2, '0')}';
          updateEndTimeColors();
        });
      } else {
        endTimeController.text = "";
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'End time should be 5 hours after start',
            bottomMargin: 0);
      }
    } else {
      if (pickedEndTime != null) {
        endTimeController.text = "";
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'End time must be from 7 AM to 10 PM',
            bottomMargin: 0);
      }
    }
  }

  // Helper function to validate and update end time.
  void validateAndUpdateEndTime() {
    final TimeOfDay currentEndTime = TimeOfDay(
        hour: int.parse(endTimeController.text.split(":")[0]),
        minute: int.parse(endTimeController.text.split(":")[1]));

    if (!isEndTimeValid(selectedStartTime, currentEndTime,
        minHourDifference: 5)) {
      // Update the end time if it doesn't meet the criteria.
      endTimeController.text = "";
    }
  }

  bool isEndTimeValid(TimeOfDay startTime, TimeOfDay endTime,
      {int minHourDifference = 0}) {
    final DateTime startDateTime =
        DateTime(2023, 1, 1, startTime.hour, startTime.minute);
    final DateTime endDateTime =
        DateTime(2023, 1, 1, endTime.hour, endTime.minute);

    final Duration difference = endDateTime.difference(startDateTime);

    return difference.inHours >= minHourDifference;
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

  Map<String, dynamic> destinationInfo = {};
  @override
  void initState() {
    super.initState();
    selectedCity = widget.coordinatorCity;
    pageController = PageController();
    print("The destination to be added:");
    print(widget.destinationToBeAdded);
    destinationInfo = widget.destinationToBeAdded;
    widget.destinationToBeAdded = {};
    if (destinationInfo.isNotEmpty) {
      setupFieldsForNewDestination();
    }
  }

  void setupFieldsForNewDestination() {
    downloadImages();
    destNameController.text = destinationInfo['destinationName'];
    selectedCity = destinationInfo['city'];
    selectedCategory = getPlaceCategory(destinationInfo['category']);
    selectedBudget = getBudgetLevel(destinationInfo['budget']);
    aboutController.text = destinationInfo['about'];
    if (destinationInfo['sheltered'] == 'true') {
      yes = true;
      no = false;
    } else {
      no = true;
      yes = false;
    }
    selectedHours = destinationInfo['timeToSpend'];
    selectedMinutes = 0;
    if (destinationInfo.containsKey('latitude')) {
      setupOtherFieldsToEdit();
    }
  }

  Future<void> downloadImages() async {
    final dio = Dio();

    for (String imageUrl in destinationInfo['imagesURLs']) {
      try {
        // Make a network request to download the image using Dio
        Response<List<int>> response = await dio.get<List<int>>(
          imageUrl,
          options: Options(responseType: ResponseType.bytes),
        );

        // Convert the response body into Uint8List
        Uint8List imageBytes = Uint8List.fromList(response.data!);

        // Add the Uint8List to the selectedImages list
        selectedImages.add(imageBytes);
      } catch (e) {
        // Handle error if the request was not successful
        print('Failed to fetch image. Error: $e');
      }
    }
  }

  void setupOtherFieldsToEdit() {
    destLatController.text = destinationInfo['latitude'];
    destLngController.text = destinationInfo['longitude'];
    startTimeController.text = destinationInfo['openingTime'];
    endTimeController.text = destinationInfo['closingTime'];
    virtualTourController.text = destinationInfo['virtualTourLink'];

    selectedWorkingDays =
        List<String>.from(destinationInfo['selectedWorkingDays']);

    selectedVisitorTypes = List<String>.from(destinationInfo['visitorTypes'])
        .map((String type) => capitalizeFirstChar(type))
        .toList();

    selectedAgeCategories = List<String>.from(destinationInfo['ageCategories']);
    List<String> services = [];
    List<String> possibleServicesSelections = [
      'restrooms',
      'parking',
      'gasstations',
      'wheelchairramps',
      'kidsarea',
      'restaurants',
      'photographers',
      'healthcenters',
      'kiosks',
    ];
    for (var service in destinationInfo['selectedServices']) {
      if (service.containsKey('name')) {
        String serviceName = service['name'];
        if (possibleServicesSelections.contains(serviceName)) {
          services.add(serviceName);
        } else {
          otherServices.add(serviceName);
        }
      }
    }
    selectedServices = mapServicesNames(services);

    List<dynamic> rawActivities = destinationInfo['addedActivities'];

    // Iterate over the raw activities and convert them to Map<String, String>.
    for (var rawActivity in rawActivities) {
      if (rawActivity is Map<String, dynamic>) {
        // Check if each activity is a Map<String, dynamic>.
        Map<String, String> activity = {};
        // Convert dynamic values to strings if needed.
        rawActivity.forEach((key, value) {
          activity[key] = value.toString();
        });
        addedActivities.add(activity);
      }
    }
    geoTags = List<String>.from(destinationInfo['geoTags']);
  }

  String capitalizeFirstChar(String input) {
    if (input.isEmpty) {
      return input;
    }
    return input[0].toUpperCase() + input.substring(1);
  }

  String getPlaceCategory(String placeCategory) {
    if (placeCategory.toLowerCase() == "coastalareas") {
      return "Coastal Areas";
    } else if (placeCategory.toLowerCase() == "mountains") {
      return "Mountains";
    } else if (placeCategory.toLowerCase() == "nationalparks") {
      return "National Parks";
    } else if (placeCategory.toLowerCase() == "majorcities") {
      return "Major Cities";
    } else if (placeCategory.toLowerCase() == "countryside") {
      return "Countryside";
    } else if (placeCategory.toLowerCase() == "historicalsites") {
      return "Historical Sites";
    } else if (placeCategory.toLowerCase() == "religiouslandmarks") {
      return "Religious Landmarks";
    } else if (placeCategory.toLowerCase() == "aquariums") {
      return "Aquariums";
    } else if (placeCategory.toLowerCase() == "zoos") {
      return "Zoos";
    } else if (placeCategory.toLowerCase() == "others") {
      return "Others";
    } else {
      return placeCategory;
    }
  }

  String getBudgetLevel(String budgetLevel) {
    if (budgetLevel.toLowerCase() == "midrange") {
      return "Mid-Range";
    } else if (budgetLevel.toLowerCase() == "budgetfriendly") {
      return "Budget-Friendly";
    } else if (budgetLevel.toLowerCase() == "luxurious") {
      return "Luxurious";
    } else {
      return budgetLevel;
    }
  }

  List<String> mapServicesNames(List<String?> selectedServices) {
    // Map the selected services to the desired format.
    final Map<String, String> serviceMapping = {
      'restrooms': 'Restrooms',
      'parking': 'Parking Areas',
      'gasstations': 'Nearby Gas Stations',
      'wheelchairramps': 'Wheel Chair Ramps',
      'kidsarea': 'Kids Area',
      'restaurants': 'Restaurants',
      'photographers': 'Photographers',
      'healthcenters': 'Nearby Health Centers',
      'kiosks': 'Kiosks',
    };

    // Convert selected services to the desired format, filtering out null values.
    return selectedServices
        .where((service) => service != null)
        .map((service) => serviceMapping[service!])
        .where((formattedService) => formattedService != null)
        .map((formattedService) => formattedService!)
        .toList();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void nextPage() {
    if (currentPage < 11) {
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

  String selectedCategory = '';
  void showCategorisBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return CustomBottomSheet(itemsList: categoriesList, height: 260);
      },
    ).then((value) {
      // Handle the selected item from the bottom sheet.
      if (value != null) {
        setState(() {
          selectedCategory = value;
        });
      }
    });
  }

  String selectedBudget = '';
  void showBudgetBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return CustomBottomSheet(itemsList: budgetsList, height: 220);
      },
    ).then((value) {
      // Handle the selected item from the bottom sheet.
      if (value != null) {
        setState(() {
          selectedBudget = value;
        });
      }
    });
  }

  List<String> daysOfWeek = [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  List<String> selectedWorkingDays = [];

  void showWorkingDaysBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return BottomDropList(
          itemsList: daysOfWeek,
          height: 450,
          initiallySelectedItems: selectedWorkingDays,
          onDone: (List<String> selectedItems) {
            setState(() {
              selectedWorkingDays = selectedItems;
            });
          },
          title: 'Working Days',
        );
      },
    );
  }

  List<String> suggestedServices = [
    'Restrooms',
    'Parking Areas',
    'Nearby Gas Stations',
    'Wheel Chair Ramps',
    'Kids Area',
    'Restaurants',
    'Nearby Health Centers',
    'Photographers',
    'Kiosks'
  ];

  List<String> selectedServices = [];
  List<String> otherServices = [];

  void showServicesBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return BottomDropList(
          itemsList: suggestedServices,
          height: 450,
          initiallySelectedItems: selectedServices,
          onDone: (List<String> selectedItems) {
            setState(() {
              selectedServices = selectedItems;
            });
          },
          title: 'Suggested Services',
        );
      },
    );
  }

  List<String> visitorTypes = ['Family', 'Friends', 'Solo'];
  List<String> selectedVisitorTypes = [];

  void showVisitorTypesBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return BottomDropList(
          itemsList: visitorTypes,
          height: 210,
          initiallySelectedItems: selectedVisitorTypes,
          onDone: (List<String> selectedItems) {
            setState(() {
              selectedVisitorTypes = selectedItems;
            });
          },
          title: 'Visitor Types',
        );
      },
    );
  }

  List<String> ageCategories = ['Children', 'Teenagers', 'Adults', 'Elders'];
  List<String> selectedAgeCategories = [];

  void showAgeCategoriesBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return BottomDropList(
          itemsList: ageCategories,
          height: 250,
          initiallySelectedItems: selectedAgeCategories,
          onDone: (List<String> selectedItems) {
            setState(() {
              selectedAgeCategories = selectedItems;
            });
          },
          title: 'Age Categories',
        );
      },
    );
  }

  // Function to open image picker.
  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      var image = await pickedFile.readAsBytes();
      setState(() {
        selectedImages.add(image);
      });
    }
  }

  // Function to delete a selected image.
  void deleteImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  void handleTimeChanged(int hours, int minutes) {
    setState(() {
      selectedHours = hours;
      selectedMinutes = minutes;
    });

    // Format the selected hours and minutes with left padding.
    String formattedHours = selectedHours.toString().padLeft(2, '0');
    String formattedMinutes = selectedMinutes.toString().padLeft(2, '0');

    print('Selected Time: $formattedHours:$formattedMinutes');
  }

  bool validateForm() {
    if (selectedBudget.isEmpty) {
      showCustomSnackBar(context, 'Please select a budget', bottomMargin: 0);
      return false;
    }

    if (selectedHours == 0 && selectedMinutes == 0) {
      showCustomSnackBar(context, 'Please select a time to spend',
          bottomMargin: 0);
      return false;
    }

    if (selectedHours < 1 && selectedMinutes == 0) {
      showCustomSnackBar(context, 'The minimum allowed time is an hour',
          bottomMargin: 0);
      return false;
    }
    if (yes == false && no == false) {
      showCustomSnackBar(
          context, 'Specify whether the destination is sheltered',
          bottomMargin: 0);
      return false;
    }
    return true;
  }

  bool isValidDouble(String value) {
    try {
      double.parse(value);
      return true;
    } catch (e) {
      return false;
    }
  }

  bool validateLatLng() {
    if (destLatController.text.isEmpty) {
      showCustomSnackBar(context, 'Please enter a latitude value',
          bottomMargin: 0);
      return false;
    } else if (destLngController.text.isEmpty) {
      showCustomSnackBar(context, 'Please enter a longitude value',
          bottomMargin: 0);
      return false;
    } else if (!isValidDouble(destLatController.text)) {
      showCustomSnackBar(context, 'Latitude must be a double value',
          bottomMargin: 0);
      return false;
    } else if (!isValidDouble(destLngController.text)) {
      showCustomSnackBar(context, 'Longitude must be a double value',
          bottomMargin: 0);
      return false;
    } else {
      return true;
    }
  }

  bool validateTimeAndWD() {
    if (startTimeController.text.isEmpty) {
      showCustomSnackBar(context, 'Please specify the opening time',
          bottomMargin: 0);
      return false;
    } else if (endTimeController.text.isEmpty) {
      showCustomSnackBar(context, 'Please specify the closing time',
          bottomMargin: 0);
      return false;
    } else if (selectedWorkingDays.isEmpty) {
      showCustomSnackBar(context, 'Please specify the working days',
          bottomMargin: 0);
      return false;
    } else {
      return true;
    }
  }

  bool validateActivities() {
    if (activityTitleController.text.isEmpty) {
      showCustomSnackBar(context, 'Please enter the activity title',
          bottomMargin: 0);
      return false;
    } else if (activityContentController.text.isEmpty) {
      showCustomSnackBar(context, 'Please enter the activity content',
          bottomMargin: 0);
      return false;
    } else if (activityTitleController.text.length < 4) {
      showCustomSnackBar(context, 'The title must be at least 4 chars',
          bottomMargin: 0);
      return false;
    } else if (activityContentController.text.length < 40) {
      showCustomSnackBar(context, 'Content should be at least 40 chars',
          bottomMargin: 0);
      return false;
    } else {
      return true;
    }
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
                  buildIntroPage(),
                  buildDestLatLngPage(),
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
                                  'assets/Images/Profiles/Admin/DestUpload/workingDays.gif',
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
                                        'Set Working Times and Days',
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
                              const SizedBox(height: 40),
                              buildTimeInput(
                                'Opening Time',
                                startTimeController,
                                startTimeBorderIconColor,
                                FontAwesomeIcons.clock,
                                () => selectStartTime(context),
                              ),
                              SizedBox(
                                  height: endTimeController.text.isNotEmpty
                                      ? 20
                                      : 10),
                              buildTimeInput(
                                'Closing Time',
                                endTimeController,
                                endTimeBorderIconColor,
                                FontAwesomeIcons.clock,
                                () => selectEndTime(context),
                              ),
                              SizedBox(
                                  height: startTimeController.text.isNotEmpty &&
                                          endTimeController.text.isNotEmpty
                                      ? 15
                                      : 10),
                              ElevatedButton(
                                onPressed: showWorkingDaysBottomSheet,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 231, 231, 231),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                                child: SizedBox(
                                  height: 50,
                                  width: 350,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 5.0),
                                        child: Text(
                                          selectedWorkingDays.isEmpty
                                              ? 'Select Working Days'
                                              : "Working Days",
                                          style: const TextStyle(
                                              color:
                                                  Color.fromARGB(163, 0, 0, 0),
                                              fontSize: 18),
                                        ),
                                      ),
                                      const FaIcon(
                                        FontAwesomeIcons.calendarCheck,
                                        color: Color.fromARGB(100, 0, 0, 0),
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
                                  'assets/Images/Profiles/Admin/DestUpload/Timer.gif',
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
                                        'More Details Matter to Others!',
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
                              const SizedBox(height: 40),
                              ElevatedButton(
                                onPressed: showBudgetBottomSheet,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 231, 231, 231),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                                child: SizedBox(
                                  height: 50,
                                  width: 350,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 5.0),
                                        child: Text(
                                          selectedBudget.isEmpty
                                              ? 'Select Budget'
                                              : selectedBudget,
                                          style: const TextStyle(
                                              color:
                                                  Color.fromARGB(163, 0, 0, 0),
                                              fontSize: 18),
                                        ),
                                      ),
                                      const FaIcon(
                                        FontAwesomeIcons.dollarSign,
                                        color: Color.fromARGB(100, 0, 0, 0),
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 105.0),
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color.fromARGB(
                                              146, 0, 0, 0),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 231, 231, 231),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.all(6.0),
                                          child: Row(
                                            children: [
                                              Row(
                                                children: [
                                                  FaIcon(
                                                    FontAwesomeIcons.clock,
                                                    color: Color.fromARGB(
                                                        163, 0, 0, 0),
                                                    size: 20,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    'Time to spend',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Color.fromARGB(
                                                            163, 0, 0, 0),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            'Times New Roman'),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                        child: TimeWheelPicker(
                                            initialHours: selectedHours,
                                            initialMins: selectedMinutes,
                                            onTimeChanged: handleTimeChanged)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 15),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 105.0),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Sheltered?',
                                      style: TextStyle(
                                        fontFamily: 'Gabriola',
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF455a64),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(width: 30),
                                    Expanded(
                                      child: buildCheckboxListTile(
                                        titleText: 'Yes',
                                        value: yes,
                                        onChanged: (newValue) {
                                          setState(() {
                                            yes = newValue!;
                                            no = false;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 130),
                                    Expanded(
                                      child: buildCheckboxListTile(
                                        titleText: 'No',
                                        value: no,
                                        onChanged: (newValue) {
                                          setState(() {
                                            no = newValue!;
                                            yes = false;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  buildVisitorsAgesPage(),
                  buildAboutPage(),
                  buildServicesPage(),
                  buildActivitiesPage(),
                  buildGeoTagsPage(),
                  buildVirtualTourPage(),
                  buildImagesPage(),
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
                    visible: currentPage < 11,
                    child: ElevatedButton(
                      onPressed: () {
                        if (currentPage == 0) {
                          if (destNameController.text.isEmpty) {
                            showCustomSnackBar(
                                context, 'Please enter a destination name',
                                bottomMargin: 0);
                          } else if (destNameController.text.length > 30) {
                            showCustomSnackBar(
                                context, 'Destination Name: 30 characters max',
                                bottomMargin: 0);
                          } else if (!RegExp(r'^[a-zA-Z0-9_-\s]+$')
                              .hasMatch(destNameController.text)) {
                            showCustomSnackBar(context,
                                'Invalid characters in destination name',
                                bottomMargin: 0);
                          } else if (selectedCity.isEmpty) {
                            showCustomSnackBar(
                                context, 'Please select a destination city',
                                bottomMargin: 0);
                          } else if (selectedCategory.isEmpty) {
                            showCustomSnackBar(
                                context, 'Please select a destination category',
                                bottomMargin: 0);
                          } else {
                            nextPage();
                          }
                        } else if (currentPage == 1) {
                          if (validateLatLng()) {
                            nextPage();
                          }
                        } else if (currentPage == 2) {
                          if (validateTimeAndWD()) {
                            nextPage();
                          }
                        } else if (currentPage == 3) {
                          if (validateForm()) {
                            nextPage();
                          }
                        } else if (currentPage == 4) {
                          if (selectedVisitorTypes.isEmpty) {
                            showCustomSnackBar(
                                context, 'Please specify the visitor types',
                                bottomMargin: 0);
                          } else if (selectedAgeCategories.isEmpty) {
                            showCustomSnackBar(
                                context, 'Please select the age categories',
                                bottomMargin: 0);
                          } else {
                            nextPage();
                          }
                        } else if (currentPage == 5) {
                          if (aboutController.text.isEmpty) {
                            showCustomSnackBar(
                                context, 'Provide information about the place',
                                bottomMargin: 0);
                          } else if (aboutController.text.length < 160) {
                            showCustomSnackBar(
                                context, 'Content must have at least 160 chars',
                                bottomMargin: 0);
                          } else {
                            nextPage();
                          }
                        } else if (currentPage == 6) {
                          if (selectedServices.isEmpty &&
                              otherServices.isEmpty) {
                            showCustomSnackBar(
                                context, 'Please specify the provided services',
                                bottomMargin: 0);
                          } else {
                            nextPage();
                          }
                        } else if (currentPage == 7) {
                          if (addedActivities.isEmpty) {
                            showCustomSnackBar(
                                context, 'Please enter at least one activity',
                                bottomMargin: 0);
                          } else {
                            nextPage();
                          }
                        } else if (currentPage == 8) {
                          if (geoTags.isEmpty) {
                            showCustomSnackBar(context,
                                'Please enter at least one search term',
                                bottomMargin: 0);
                          } else {
                            nextPage();
                          }
                        } else if (currentPage == 10) {
                          if (selectedImages.isEmpty) {
                            showCustomSnackBar(
                                context, 'Destination images are needed',
                                bottomMargin: 0);
                          } else {
                            nextPage();
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

  Widget buildIntroPage() {
    return buildPageContent(
      Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Image.asset(
                  'assets/Images/Profiles/Admin/DestUpload/horseRiding.gif',
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
                          'A Call to Explore Palestine!',
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
                const Text(
                  'Promote Palestinian tourism with enticing destinations',
                  style: TextStyle(
                    fontFamily: 'Gabriola',
                    fontSize: 25,
                    color: Color(0xFF455a64),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                buildDestInput(
                  'Destination Name',
                  55,
                  destNameController,
                  destNameBorderIconColor,
                  FontAwesomeIcons.locationDot,
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {},
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
                            selectedCity.isEmpty ? 'Select City' : selectedCity,
                            style: const TextStyle(
                                color: Color.fromARGB(163, 0, 0, 0),
                                fontSize: 18),
                          ),
                        ),
                        const FaIcon(
                          FontAwesomeIcons.city,
                          color: Color.fromARGB(100, 0, 0, 0),
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: showCategorisBottomSheet,
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
                            selectedCategory.isEmpty
                                ? 'Select Category'
                                : selectedCategory,
                            style: const TextStyle(
                                color: Color.fromARGB(163, 0, 0, 0),
                                fontSize: 18),
                          ),
                        ),
                        const FaIcon(
                          FontAwesomeIcons.mountainCity,
                          color: Color.fromARGB(100, 0, 0, 0),
                          size: 24,
                        ),
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

  Widget buildDestLatLngPage() {
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Image.asset(
                    'assets/Images/Profiles/Admin/DestUpload/currentLocation.gif',
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
                          'Specify the Destination Location',
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
                const SizedBox(height: 80),
                buildDestInput(
                  'Latitude',
                  55,
                  destLatController,
                  destLatBorderIconColor,
                  FontAwesomeIcons.locationDot,
                ),
                SizedBox(height: destLngController.text.isEmpty ? 15 : 20),
                buildDestInput(
                  'Longitude',
                  55,
                  destLngController,
                  destLngBorderIconColor,
                  FontAwesomeIcons.locationDot,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTimeInput(
    String labelText,
    TextEditingController controller,
    Color borderIconColor,
    IconData icon,
    Function() onTap,
  ) {
    return SizedBox(
      height: 55,
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

  Widget buildDestInput(
    String labelText,
    double height,
    TextEditingController controller,
    Color borderIconColor,
    IconData icon,
  ) {
    return SizedBox(
      height: height,
      width: 380,
      child: InkWell(
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
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(
                color: borderIconColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
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
    );
  }

  Widget buildVisitorsAgesPage() {
    return buildPageContent(
      Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Image.asset('assets/Images/Profiles/Admin/DestUpload/camel.png',
                    height: 390, fit: BoxFit.cover),
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
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Define Ages and Visitor Types',
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
                const SizedBox(height: 80),
                ElevatedButton(
                  onPressed: showVisitorTypesBottomSheet,
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
                            selectedVisitorTypes.isEmpty
                                ? 'Select Visitor Types'
                                : "Visitor Types",
                            style: const TextStyle(
                                color: Color.fromARGB(163, 0, 0, 0),
                                fontSize: 18),
                          ),
                        ),
                        const FaIcon(
                          FontAwesomeIcons.listCheck,
                          color: Color.fromARGB(100, 0, 0, 0),
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: showAgeCategoriesBottomSheet,
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
                            selectedAgeCategories.isEmpty
                                ? 'Select Age Categories'
                                : "Age Categories",
                            style: const TextStyle(
                                color: Color.fromARGB(163, 0, 0, 0),
                                fontSize: 18),
                          ),
                        ),
                        const FaIcon(
                          FontAwesomeIcons.userGroup,
                          color: Color.fromARGB(100, 0, 0, 0),
                          size: 24,
                        ),
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

  Widget buildAboutPage() {
    return buildPageContent(
      Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Image.asset('assets/Images/Profiles/Admin/DestUpload/Notes.gif',
                    height: 390, fit: BoxFit.cover),
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
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Inform Others About This Place',
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
                  padding: const EdgeInsets.symmetric(horizontal: 80.0),
                  child: TextFormField(
                    controller: aboutController,
                    decoration: const InputDecoration(
                      labelText: 'About Destination',
                      labelStyle: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF1E889E),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF1E889E)),
                      ),
                    ),
                    minLines: 1,
                    maxLines: 12,
                    maxLength: 1000,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildServicesPage() {
    ScrollController servicesSccrollController = ScrollController();

    return buildPageContent(
      Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Image.asset(
                    'assets/Images/Profiles/Admin/DestUpload/Questions.gif',
                    height: 390,
                    fit: BoxFit.cover),
              ],
            ),
          ),
          Expanded(
            child: CustomScrollView(
              controller: servicesSccrollController,
              slivers: [
                SliverToBoxAdapter(
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
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                'Share the Destination Services',
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
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: showServicesBottomSheet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 231, 231, 231),
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
                                  selectedServices.isEmpty
                                      ? 'Select Services'
                                      : "Services",
                                  style: const TextStyle(
                                      color: Color.fromARGB(163, 0, 0, 0),
                                      fontSize: 18),
                                ),
                              ),
                              const FaIcon(
                                FontAwesomeIcons.listCheck,
                                color: Color.fromARGB(100, 0, 0, 0),
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 110.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: TextFormField(
                                  controller: otherServicesController,
                                  decoration: const InputDecoration(
                                    labelText: 'Other Services',
                                    labelStyle: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFF1E889E),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color(0xFF1E889E)),
                                    ),
                                  ),
                                  minLines: 1,
                                  maxLines: 2,
                                  maxLength: 43,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: ElevatedButton(
                                onPressed: addOtherItem,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 20,
                                  ),
                                  backgroundColor:
                                      const Color.fromARGB(255, 216, 215, 215),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                child: const FaIcon(
                                  FontAwesomeIcons.plus,
                                  color: Color.fromARGB(163, 0, 0, 0),
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: otherServices.length > 2
                      ? SizedBox(
                          height: 150,
                          child: Scrollbar(
                            controller: servicesSccrollController,
                            trackVisibility: true,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              child: Column(
                                children:
                                    otherServices.asMap().entries.map((entry) {
                                  final int index = entry.key;
                                  final String item = entry.value;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 100.0),
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        side: const BorderSide(
                                          color: Color.fromARGB(50, 0, 0, 0),
                                          width: 1.0,
                                        ),
                                      ),
                                      elevation: 3,
                                      margin: const EdgeInsets.all(8),
                                      child: ListTile(
                                        title: Text(item,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontFamily: 'Andalus')),
                                        trailing: InkWell(
                                          onTap: () => removeItem(index),
                                          child: const FaIcon(
                                              FontAwesomeIcons.circleXmark),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: otherServices.asMap().entries.map((entry) {
                            final int index = entry.key;
                            final String item = entry.value;

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 100.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  side: const BorderSide(
                                    color: Color.fromARGB(50, 0, 0, 0),
                                    width: 1.0,
                                  ),
                                ),
                                elevation: 3,
                                margin: const EdgeInsets.all(8),
                                child: ListTile(
                                  title: Text(item,
                                      style: const TextStyle(
                                          fontSize: 18, fontFamily: 'Andalus')),
                                  trailing: InkWell(
                                    onTap: () => removeItem(index),
                                    child: const FaIcon(
                                        FontAwesomeIcons.circleXmark),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void addOtherItem() {
    if (otherServicesController.text.isEmpty) {
      showCustomSnackBar(context, 'Please enter the service you want!',
          bottomMargin: 0);
    } else if (otherServicesController.text.length < 4) {
      showCustomSnackBar(
          context, 'A service can\'t be shorter than 4 characters!',
          bottomMargin: 0);
    } else if (otherServicesController.text.length > 43) {
      showCustomSnackBar(
          context, 'A service can\'t be longer than 43 characters!',
          bottomMargin: 0);
    } else {
      setState(() {
        otherServices.add(otherServicesController.text);
        otherServicesController.clear();
      });
    }
  }

  void removeItem(int index) {
    setState(() {
      otherServices.removeAt(index);
    });
  }

  Widget buildActivitiesPage() {
    return buildPageContent(
      Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Image.asset(
                    'assets/Images/Profiles/Admin/DestUpload/activity.gif',
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
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Highlight Potential Activities',
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
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 80.0),
                  child: TextField(
                    controller: activityTitleController,
                    decoration: const InputDecoration(
                      labelText: 'Activity Title',
                      labelStyle: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF1E889E),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF1E889E)),
                      ),
                    ),
                    maxLength: 25,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 80.0),
                  child: TextFormField(
                    controller: activityContentController,
                    decoration: const InputDecoration(
                      labelText: 'About Activity',
                      labelStyle: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF1E889E),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF1E889E)),
                      ),
                    ),
                    minLines: 1,
                    maxLines: 4,
                    maxLength: 500,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 80.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Visibility(
                        visible: addedActivities.isNotEmpty,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ActivityListPage(
                                        addedActivities: addedActivities,
                                      )),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20,
                            ),
                            backgroundColor: const Color(0xFFe0e0e0),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontFamily: 'Zilla',
                              fontWeight: FontWeight.w300,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          child: const Text(
                            'View All',
                            style: TextStyle(
                                fontFamily: 'Zilla', color: Color(0xFF455a64)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (validateActivities()) {
                            setState(() {
                              addedActivities.add({
                                'title': activityTitleController.text,
                                'description': activityContentController.text,
                              });
                              activityTitleController.clear();
                              activityContentController.clear();
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                          backgroundColor: const Color(0xFFe0e0e0),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontFamily: 'Zilla',
                            fontWeight: FontWeight.w300,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                        child: const FaIcon(
                          FontAwesomeIcons.plus,
                          size: 20,
                          color: Color(0xFF455a64),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGeoTagsPage() {
    ScrollController geoTagsSccrollController = ScrollController();

    return buildPageContent(
      Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Image.asset(
                    'assets/Images/Profiles/Admin/DestUpload/Search.gif',
                    height: 390,
                    fit: BoxFit.cover),
              ],
            ),
          ),
          Expanded(
            child: CustomScrollView(
              controller: geoTagsSccrollController,
              slivers: [
                SliverToBoxAdapter(
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
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                'Identify Search Keywords',
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
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 100.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: TextFormField(
                                  controller: geoTagsController,
                                  decoration: const InputDecoration(
                                    labelText: 'Search Term',
                                    labelStyle: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFF1E889E),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color(0xFF1E889E)),
                                    ),
                                  ),
                                  minLines: 1,
                                  maxLines: 2,
                                  maxLength: 30,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: ElevatedButton(
                                onPressed: addGeoTag,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 20,
                                  ),
                                  backgroundColor:
                                      const Color.fromARGB(255, 216, 215, 215),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                child: const FaIcon(
                                  FontAwesomeIcons.plus,
                                  color: Color.fromARGB(163, 0, 0, 0),
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: geoTags.length > 3
                      ? SizedBox(
                          height: 200,
                          child: Scrollbar(
                            controller: geoTagsSccrollController,
                            trackVisibility: true,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              child: Column(
                                children: geoTags.asMap().entries.map((entry) {
                                  final int index = entry.key;
                                  final String item = entry.value;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 90.0),
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        side: const BorderSide(
                                          color: Color.fromARGB(50, 0, 0, 0),
                                          width: 1.0,
                                        ),
                                      ),
                                      elevation: 3,
                                      margin: const EdgeInsets.all(8),
                                      child: ListTile(
                                        title: Text(item,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontFamily: 'Andalus')),
                                        trailing: InkWell(
                                          onTap: () => removeGeoTag(index),
                                          child: const FaIcon(
                                              FontAwesomeIcons.circleXmark),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: geoTags.asMap().entries.map((entry) {
                            final int index = entry.key;
                            final String item = entry.value;

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 90.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  side: const BorderSide(
                                    color: Color.fromARGB(50, 0, 0, 0),
                                    width: 1.0,
                                  ),
                                ),
                                elevation: 3,
                                margin: const EdgeInsets.all(8),
                                child: ListTile(
                                  title: Text(item,
                                      style: const TextStyle(
                                          fontSize: 18, fontFamily: 'Andalus')),
                                  trailing: InkWell(
                                    onTap: () => removeGeoTag(index),
                                    child: const FaIcon(
                                        FontAwesomeIcons.circleXmark),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void addGeoTag() {
    if (geoTagsController.text.isEmpty) {
      showCustomSnackBar(context, 'Please enter the term you want!',
          bottomMargin: 0);
    } else if (geoTagsController.text.length < 3) {
      showCustomSnackBar(context, 'A term can\'t be shorter than 3 characters!',
          bottomMargin: 0);
    } else {
      setState(() {
        geoTags.add(geoTagsController.text);
        geoTagsController.clear();
      });
    }
  }

  void removeGeoTag(int index) {
    setState(() {
      geoTags.removeAt(index);
    });
  }

  Widget buildVirtualTourPage() {
    return buildPageContent(
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                Image.asset(
                    'assets/Images/Profiles/Admin/DestUpload/VirtualTour.gif',
                    height: 390,
                    fit: BoxFit.cover),
              ],
            ),
          ),
          Expanded(
            child: Column(
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
                          'Incorporate a Virtual Tour',
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
                const Text(
                  'Enhance user experience in Tourstine by integrating\n a virtual tour for destination exploration',
                  style: TextStyle(
                    fontFamily: 'Gabriola',
                    fontSize: 25,
                    color: Color(0xFF455a64),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 80.0),
                  child: TextField(
                    controller: virtualTourController,
                    decoration: const InputDecoration(
                      labelText: 'Virtual Tour Link',
                      labelStyle: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF1E889E),
                        fontWeight: FontWeight.bold,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF1E889E)),
                      ),
                    ),
                    maxLength: 200,
                    minLines: 1,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildImagesPage() {
    final ScrollController scrollController = ScrollController();

    return buildPageContent(
      Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Image.asset(
                    'assets/Images/Profiles/Admin/DestUpload/destImages.gif',
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
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Enrich the Place With Images',
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
                if (selectedImages.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: SizedBox(
                      height: 250,
                      child: selectedImages.length >= 3
                          ? Scrollbar(
                              trackVisibility: true,
                              thumbVisibility: true,
                              thickness: 5,
                              controller: scrollController,
                              child: ListView.builder(
                                controller: scrollController,
                                scrollDirection: Axis.horizontal,
                                itemCount: selectedImages.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Stack(
                                      children: [
                                        Image.memory(
                                          selectedImages[index],
                                          width: 220,
                                          height: 250,
                                          fit: BoxFit.fill,
                                        ),
                                        Positioned(
                                          top: -5,
                                          right: -5,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color.fromARGB(
                                                          255, 20, 94, 108)
                                                      .withOpacity(1),
                                                  blurRadius: 1,
                                                  spreadRadius: -10,
                                                  offset: const Offset(0, 0),
                                                ),
                                              ],
                                            ),
                                            child: IconButton(
                                              icon: const FaIcon(
                                                FontAwesomeIcons.xmark,
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                                size: 20.0,
                                              ),
                                              onPressed: () =>
                                                  deleteImage(index),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              scrollDirection: Axis.horizontal,
                              itemCount: selectedImages.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Stack(
                                    children: [
                                      Image.memory(
                                        selectedImages[index],
                                        width: 220,
                                        height: 250,
                                        fit: BoxFit.fill,
                                      ),
                                      Positioned(
                                        top: -5,
                                        right: -5,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color.fromARGB(
                                                        255, 20, 94, 108)
                                                    .withOpacity(1),
                                                blurRadius: 1,
                                                spreadRadius: -10,
                                                offset: const Offset(0, 0),
                                              ),
                                            ],
                                          ),
                                          child: IconButton(
                                            icon: const FaIcon(
                                              FontAwesomeIcons.xmark,
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              size: 20.0,
                                            ),
                                            onPressed: () => deleteImage(index),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                SizedBox(height: selectedImages.isEmpty ? 100 : 7.5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: ElevatedButton(
                    onPressed: pickImage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
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
                          FontAwesomeIcons.photoFilm,
                          size: 25,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Text('Add Image'),
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

  Widget buildSummaryPage() {
    return buildPageContent(
      Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Image.asset(
                    'assets/Images/Profiles/Admin/DestUpload/Confirmed.gif',
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
                          'Encourage Adventure',
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
                const SizedBox(height: 40),
                const Text(
                  'Submit the destination and encourage\n others to explore!',
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
                      await addDestination();
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
                        Text('Submit'),
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

  ListTileTheme buildCheckboxListTile({
    required String titleText,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return ListTileTheme(
      horizontalTitleGap: 0,
      child: CheckboxListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: const Color(0xFF1E889E),
        title: Row(
          children: [
            Expanded(
              child: Text(
                titleText,
                style: const TextStyle(
                  fontSize: 24,
                  fontFamily: 'Gabriola',
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
          ],
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
