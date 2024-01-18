import 'package:touristine/WebApplication/Profiles/Tourist/MainPages/planMaker/custom_bottom_sheet.dart';
import 'package:touristine/WebApplication/Profiles/Tourist/MainPages/DestinationUpload/time_picker.dart';
import 'package:touristine/WebApplication/Notifications/snack_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'dart:convert';

class AddDestTab extends StatefulWidget {
  final String token;

  const AddDestTab({super.key, required this.token});

  @override
  _AddDestTabState createState() => _AddDestTabState();
}

class _AddDestTabState extends State<AddDestTab> {
  bool yes = false;
  bool no = false;

  TextEditingController destNameController = TextEditingController();
  TextEditingController aboutController = TextEditingController();
  List<Uint8List> selectedImages = []; // List to store selected images.

  Color destBorderIconColor = Colors.grey;

  late PageController pageController;
  int currentPage = 0;

  int selectedHours = 0;
  int selectedMinutes = 0;

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

  List<String> citiesList = ['Jerusalem', 'Nablus', 'Ramallah', 'Bethlehem'];

  // A function to store the created destination details.
  Future<void> storeDestination() async {
    String currentDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

    // Format time to spend (hours and minutes).
    String formattedHours = selectedHours.toString().padLeft(2, '0');
    String formattedMinutes = selectedMinutes.toString().padLeft(2, '0');

    final url = Uri.parse('https://touristine.onrender.com/store-destination');

    // Create a multi-part request.
    final request = http.MultipartRequest('POST', url);

    // Add headers to the request.
    request.headers['Content-Type'] = 'multipart/form-data';
    request.headers['Authorization'] = 'Bearer ${widget.token}';

    // Add destination data to the request.
    request.fields['date'] = currentDate;
    request.fields['destinationName'] = destNameController.text;
    request.fields['city'] = selectedCity;
    request.fields['category'] = selectedCategory;
    request.fields['budget'] = selectedBudget;
    request.fields['timeToSpend'] = "$formattedHours:$formattedMinutes";
    request.fields['sheltered'] = yes ? yes.toString() : "false";
    request.fields['about'] = aboutController.text;

    // Israa, these print statements will be deleted after finishing this code.
    print(currentDate);
    print(destNameController.text);
    print(selectedCity);
    print(selectedCategory);
    print(selectedBudget);
    print("$formattedHours:$formattedMinutes");
    print("Sheltered ${yes ? yes.toString() : false}");
    print(aboutController.text);
    // print(selectedImages);

    // Add images to the request.
    for (int i = 0; i < selectedImages.length; i++) {
      Uint8List imageBytes = selectedImages[i];
      String fileName = 'image_$i.jpg';

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
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Thanks for suggesting a new place',
            bottomMargin: 0);
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
        showCustomSnackBar(context, 'Error storing your destination',
            bottomMargin: 0);
      }
    } catch (error) {
      print('Error storing the destination: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void nextPage() {
    if (currentPage < 4) {
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
        return CustomBottomSheet(
          itemsList: categoriesList,
          height: 540,
        );
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

  String selectedCity = '';
  void showCityBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return CustomBottomSheet(
          itemsList: citiesList,
          height: 260,
        );
      },
    ).then((value) {
      // Handle the selected item from the bottom sheet.
      if (value != null) {
        setState(() {
          selectedCity = value;
        });
      }
    });
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
                                  'assets/Images/Profiles/Tourist/DestUpload/Timer.gif',
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
                  buildAboutPage(),
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
                    visible: currentPage < 4,
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
                                'Invalid characters in the destination name',
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
                          if (validateForm()) {
                            nextPage();
                          }
                        } else if (currentPage == 2) {
                          if (aboutController.text.isEmpty) {
                            showCustomSnackBar(context,
                                'Please provide information about the place',
                                bottomMargin: 0);
                          } else if (aboutController.text.length < 160) {
                            showCustomSnackBar(context,
                                'The about content must have at least 160 chars',
                                bottomMargin: 0);
                          } else {
                            nextPage();
                          }
                        } else if (currentPage == 3) {
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
                  'assets/Images/Profiles/Tourist/DestUpload/CableCar.gif',
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
                          'Share Your Unique Experiences',
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
                  'Contribute by adding your destinations to inspire others',
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
                  destNameController,
                  destBorderIconColor,
                  FontAwesomeIcons.locationDot,
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: showCityBottomSheet,
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

  Widget buildDestInput(
    String labelText,
    TextEditingController controller,
    Color borderIconColor,
    IconData icon,
  ) {
    return SizedBox(
      height: 55,
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

  Widget buildAboutPage() {
    return buildPageContent(
      Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Image.asset(
                    'assets/Images/Profiles/Tourist/DestUpload/Notes.gif',
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
                        fontWeight: FontWeight.bold,
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

  Widget buildImagesPage() {
    final ScrollController scrollController = ScrollController();

    return buildPageContent(
      Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Image.asset(
                    'assets/Images/Profiles/Tourist/DestUpload/ImagesSection.gif',
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
                  padding: const EdgeInsets.symmetric(horizontal: 60.0),
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
                      await storeDestination();
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
