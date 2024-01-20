import 'package:touristine/WebApplication/Notifications/snack_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class InterestsFillingPage extends StatefulWidget {
  final String token;

  const InterestsFillingPage({super.key, required this.token});

  @override
  _InterestsFillingPageState createState() => _InterestsFillingPageState();
}

class _InterestsFillingPageState extends State<InterestsFillingPage> {
  int currentStep = 0;
  XFile? selectedImage;
  String? selectedCity;

  // Q1 Choices.
  bool budgetFriendly = false; // Default value of the checkbox1.
  bool midRange = false; // Default value of the checkbox2.
  bool luxurious = false; // Default value of the checkbox3.

  // Q2 Choices.
  bool family = false; // Default value of the checkbox4.
  bool friends = false; // Default value of the checkbox5.
  bool solo = false; // Default value of the checkbox6.

  // Q3 Choices.
  bool coastalAreas = false; // Default value of the checkbox7.
  bool mountains = false; // Default value of the checkbox8.
  bool nationalParks = false; // Default value of the checkbox9.
  bool majorCities = false; // Default value of the checkbox10.
  bool countrySide = false; // Default value of the checkbox11.
  bool historicalSites = false; // Default value of the checkbox12.
  bool religiousLandmarks = false; // Default value of the checkbox13.
  bool aquariums = false;
  bool zoos = false;
  bool others = false;

  // Q4 Choices.
  bool yes = false; // Default value of the checkbox14.
  bool no = false; // Default value of the checkbox15.

  // Q5 Choices.
  bool mobility = false; // Default value of the checkbox16.
  bool visual = false; // Default value of the checkbox17.
  bool hearing = false; // Default value of the checkbox18.
  bool cognitive = false; // Default value of the checkbox19.
  bool diabetes = false; // Default value of the checkbox20.

  @override
  void initState() {
    super.initState();
    fetchSavedInterests();
  }

  bool convertToBool(dynamic value) {
    if (value is bool) {
      return value;
    } else if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return false; // Default value if conversion fails.
  }

  // A function that sends a request to the server to retrieve the saved interests.
  Future<void> fetchSavedInterests() async {
    final url = Uri.parse('https://touristine.onrender.com/get-interests');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Retrieve and set the values based on the response data.
        setState(() {
          budgetFriendly = convertToBool(responseData['BudgetFriendly']);
          midRange = convertToBool(responseData['MidRange']);
          luxurious = convertToBool(responseData['Luxurious']);

          family = convertToBool(responseData['family']);
          friends = convertToBool(responseData['friends']);
          solo = convertToBool(responseData['solo']);

          coastalAreas = convertToBool(responseData['coastalAreas']);
          mountains = convertToBool(responseData['mountains']);
          nationalParks = convertToBool(responseData['nationalParks']);
          majorCities = convertToBool(responseData['majorCities']);
          countrySide = convertToBool(responseData['countrySide']);
          historicalSites = convertToBool(responseData['historicalSites']);
          religiousLandmarks =
              convertToBool(responseData['religiousLandmarks']);
          // Newly added.
          aquariums = convertToBool(responseData['aquariums']);
          zoos = convertToBool(responseData['zoos']);
          others = convertToBool(responseData['others']);

          yes = convertToBool(responseData['Yes']);
          no = convertToBool(responseData['No']);

          mobility = convertToBool(responseData['mobility']);
          visual = convertToBool(responseData['visual']);
          hearing = convertToBool(responseData['hearing']);
          cognitive = convertToBool(responseData['cognitive']);
          diabetes = convertToBool(responseData['diabetes']);
        });
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('error')) {
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
        }
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, "Failed to fetch your interests",
            bottomMargin: 0);
      }
    } catch (error) {
      print('Failed to fetch interests: $error');
    }
  }

  Future<void> sendAndSaveData() async {
    final url = Uri.parse('https://touristine.onrender.com/interests-filling');

    try {
      final Map<String, String> postBody = {
        // Q1.
        'BudgetFriendly': budgetFriendly.toString(),
        'MidRange': midRange.toString(),
        'Luxurious': luxurious.toString(),

        // Q2.
        'family': family.toString(),
        'friends': friends.toString(),
        'solo': solo.toString(),

        // Q3.
        'coastalAreas': coastalAreas.toString(),
        'mountains': mountains.toString(),
        'nationalParks': nationalParks.toString(),
        'majorCities': majorCities.toString(),
        'countrySide': countrySide.toString(),
        'historicalSites': historicalSites.toString(),
        'religiousLandmarks': religiousLandmarks.toString(),
        // Newly added.
        'aquariums': aquariums.toString(),
        'zoos': zoos.toString(),
        'others': others.toString(),

        // Q4.
        'Yes': yes.toString(),
        'No': no.toString(),
      };

      // If the user has a disability, provide information about the disability.
      if (yes) {
        postBody.addAll({
          // Q5.
          'mobility': mobility.toString(),
          'visual': visual.toString(),
          'hearing': hearing.toString(),
          'cognitive': cognitive.toString(),
          'diabetes': diabetes.toString(),
        });
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: postBody,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('message') &&
            responseData['message'] == 'updated') {
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, "Your interests have been updated",
              bottomMargin: 0);
        }
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, "Unable to update your interests",
            bottomMargin: 0);
      }
    } catch (error) {
      print('Failed to save your interests. Error: $error');
    }
  }

  // A function to check if the current step's conditions are met.
  bool areStepConditionsMet(int step) {
    switch (step) {
      case 0:
        return budgetFriendly || midRange || luxurious;
      case 1:
        return family || friends || solo;
      case 2:
        return coastalAreas ||
            mountains ||
            nationalParks ||
            majorCities ||
            countrySide ||
            historicalSites ||
            religiousLandmarks ||
            aquariums ||
            zoos ||
            others;
      case 3:
        return yes || no;
      case 4:
        if (yes) {
          if (mobility || visual || hearing || cognitive || diabetes) {
            return true;
          } else {
            return false;
          }
        } else {
          return true;
        }
      default:
        return true; // Return true for steps not requiring validation.
    }
  }

  // Function to create a CheckboxListTile
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
        title: Text(
          titleText,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        value: value,
        onChanged: onChanged, // Callback to handle checkbox state changes.
      ),
    );
  }

  ListTileTheme buildCheckboxListTilePair({
    required String titleText1,
    required bool value1,
    required Function(bool?) onChanged1,
    required String titleText2,
    required bool value2,
    required Function(bool?) onChanged2,
  }) {
    return ListTileTheme(
      horizontalTitleGap: 0,
      child: Row(
        children: [
          Expanded(
            child: CheckboxListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: const Color(0xFF1E889E),
              title: Text(
                titleText1,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              value: value1,
              onChanged: onChanged1,
            ),
          ),
          Expanded(
            child: CheckboxListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: const Color(0xFF1E889E),
              title: Text(
                titleText2,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              value: value2,
              onChanged: onChanged2,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        body: SizedBox(
          height: 500,
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: Color(0xFF1E889E)),
              canvasColor: const Color.fromARGB(0, 255, 255, 255),
            ),
            child: Stepper(
              elevation: 0,
              type: StepperType.horizontal,
              steps: getSteps(),
              currentStep: currentStep,
              onStepContinue: () {
                if (areStepConditionsMet(currentStep)) {
                  final isLastStep = currentStep == getSteps().length - 1;
                  if (isLastStep) {
                    sendAndSaveData();
                  } else if (currentStep == 3 && !yes && no) {
                    setState(() {
                      currentStep += 2;
                    });
                  } else {
                    setState(() {
                      currentStep += 1;
                    });
                  }
                } else {
                  showCustomSnackBar(context, "Please complete this step",
                      bottomMargin: 0);
                }
              },
              onStepCancel: () {
                if (currentStep != 0) {
                  if (currentStep == 5 && !yes && no) {
                    setState(() {
                      currentStep -= 2;
                    });
                  } else {
                    setState(() {
                      currentStep -= 1;
                    });
                  }
                } else {
                  null;
                }
              },
              onStepTapped: (step) => setState(() {
                currentStep = step;
              }),
              controlsBuilder: (context, ControlsDetails controlsDetails) {
                final isLastStep = currentStep == getSteps().length - 1;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: !isLastStep ? 540 : 610),
                    if (currentStep != 0)
                      ElevatedButton(
                        onPressed: controlsDetails.onStepCancel,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 100,
                            vertical: 20,
                          ),
                          backgroundColor: const Color(0xFFe6e6e6),
                          textStyle: const TextStyle(
                            color: Color(0xFF455a64),
                            fontSize: 22,
                            fontFamily: 'Zilla',
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        child: const Text(
                          'Back',
                          style: TextStyle(
                            color: Color(0xFF1e889e),
                          ),
                        ),
                      ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: controlsDetails.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: currentStep == 0
                              ? 250
                              : !isLastStep
                                  ? 100
                                  : 80,
                          vertical: 20,
                        ),
                        backgroundColor: const Color(0xFF1E889E),
                        textStyle: const TextStyle(
                          fontSize: 22,
                          fontFamily: 'Zilla',
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      child: Text(isLastStep ? 'Confirm' : 'Next'),
                    ),
                  ],
                );
              },
            ),
          ),
        ));
  }

  // A function that creates and returns a list of steps that are displayed within the Stepper.
  List<Step> getSteps() {
    return [
      Step(
        state: StepState.indexed,
        isActive: currentStep >= 0,
        title: const Text(''),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  Image.asset(
                    'assets/Images/Profiles/Tourist/InterestsFillingPage/Banknote.gif',
                    fit: BoxFit.cover,
                    height: 350,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'What is your travel budget?',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Gabriola',
                      color: Color.fromARGB(255, 39, 51, 57),
                    ),
                  ),

                  // Create CheckboxListTile 1.
                  buildCheckboxListTile(
                    titleText: 'Budget-Friendly',
                    value: budgetFriendly,
                    onChanged: (value) {
                      setState(() {
                        budgetFriendly = value!;
                      });
                    },
                  ),

                  // Create CheckboxListTile 2.
                  buildCheckboxListTile(
                    titleText: 'Mid-Range',
                    value: midRange,
                    onChanged: (value) {
                      setState(() {
                        midRange = value!;
                      });
                    },
                  ),

                  // Create CheckboxListTile 3.
                  buildCheckboxListTile(
                    titleText: 'Luxurious',
                    value: luxurious,
                    onChanged: (value) {
                      setState(() {
                        luxurious = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      Step(
        state: StepState.indexed,
        isActive: currentStep >= 1,
        title: const Text(''),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  Image.asset(
                    'assets/Images/Profiles/Tourist/InterestsFillingPage/RoadTrip.gif',
                    fit: BoxFit.cover,
                    height: 350,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(right: 21.0),
                    child: Text(
                      'Do you prefer to travel alone, with friends, or with family?',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Gabriola',
                        color: Color.fromARGB(255, 39, 51, 57),
                      ),
                    ),
                  ),

                  // Create CheckboxListTile 1.
                  buildCheckboxListTile(
                    titleText: 'Family',
                    value: family,
                    onChanged: (value) {
                      setState(() {
                        family = value!;
                      });
                    },
                  ),

                  // Create CheckboxListTile 2
                  buildCheckboxListTile(
                    titleText: 'Friends',
                    value: friends,
                    onChanged: (value) {
                      setState(() {
                        friends = value!;
                      });
                    },
                  ),

                  // Create CheckboxListTile 3
                  buildCheckboxListTile(
                    titleText: 'Solo',
                    value: solo,
                    onChanged: (value) {
                      setState(() {
                        solo = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      Step(
        state: StepState.indexed,
        isActive: currentStep >= 2,
        title: const Text(''),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  Image.asset(
                    'assets/Images/Profiles/Tourist/InterestsFillingPage/StoneBridge.gif',
                    fit: BoxFit.cover,
                    height: 350,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(right: 21.0),
                    child: Text(
                      'What regions of Palestine are you interested in exploring?',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Gabriola',
                        color: Color.fromARGB(255, 39, 51, 57),
                      ),
                    ),
                  ),

                  // Create CheckboxListTile Pair 1.
                  buildCheckboxListTilePair(
                    titleText1: 'Coastal Areas',
                    value1: coastalAreas,
                    onChanged1: (value) {
                      setState(() {
                        coastalAreas = value!;
                      });
                    },
                    titleText2: 'Mountains',
                    value2: mountains,
                    onChanged2: (value) {
                      setState(() {
                        mountains = value!;
                      });
                    },
                  ),

                  // Create CheckboxListTile Pair 2.
                  buildCheckboxListTilePair(
                    titleText1: 'National Parks',
                    value1: nationalParks,
                    onChanged1: (value) {
                      setState(() {
                        nationalParks = value!;
                      });
                    },
                    titleText2: 'Major Cities',
                    value2: majorCities,
                    onChanged2: (value) {
                      setState(() {
                        majorCities = value!;
                      });
                    },
                  ),

                  // Create CheckboxListTile Pair 3.
                  buildCheckboxListTilePair(
                    titleText1: 'Countryside',
                    value1: countrySide,
                    onChanged1: (value) {
                      setState(() {
                        countrySide = value!;
                      });
                    },
                    titleText2: 'Historical Sites',
                    value2: historicalSites,
                    onChanged2: (value) {
                      setState(() {
                        historicalSites = value!;
                      });
                    },
                  ),

                  // Create CheckboxListTile Pair 4.
                  buildCheckboxListTilePair(
                    titleText1: 'Religious Landmarks',
                    value1: religiousLandmarks,
                    onChanged1: (value) {
                      setState(() {
                        religiousLandmarks = value!;
                      });
                    },
                    titleText2: 'Aquariums',
                    value2: aquariums,
                    onChanged2: (value) {
                      setState(() {
                        aquariums = value!;
                      });
                    },
                  ),

                  // Create CheckboxListTile Pair 5.
                  buildCheckboxListTilePair(
                    titleText1: 'Zoos',
                    value1: zoos,
                    onChanged1: (value) {
                      setState(() {
                        zoos = value!;
                      });
                    },
                    titleText2: 'Others',
                    value2: others,
                    onChanged2: (value) {
                      setState(() {
                        others = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      Step(
        state: StepState.indexed,
        isActive: currentStep >= 3,
        title: const Text(''),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  Image.asset(
                    'assets/Images/Profiles/Tourist/InterestsFillingPage/YesOrNo.gif',
                    fit: BoxFit.cover,
                    height: 350,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(right: 21.0),
                    child: Text(
                      'Do you or anyone in your travel group have disabilities?',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Gabriola',
                        color: Color.fromARGB(255, 39, 51, 57),
                      ),
                    ),
                  ),

                  // Create CheckboxListTile 1.
                  buildCheckboxListTile(
                    titleText: 'Yes',
                    value: yes,
                    onChanged: (value) {
                      setState(() {
                        yes = value!;
                        no = false;
                      });
                    },
                  ),

                  // Create CheckboxListTile 2.
                  buildCheckboxListTile(
                    titleText: 'No',
                    value: no,
                    onChanged: (value) {
                      setState(() {
                        no = value!;
                        yes = false;
                        // All the options for Question 5 are false.
                        mobility = false;
                        visual = false;
                        hearing = false;
                        cognitive = false;
                        diabetes = false;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      Step(
        state: StepState.indexed,
        isActive: currentStep >= 4,
        title: const Text(''),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  Image.asset(
                    'assets/Images/Profiles/Tourist/InterestsFillingPage/PeopleWithDisability.gif',
                    fit: BoxFit.cover,
                    height: 350,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(right: 21.0),
                    child: Text(
                      'Choose the disability type(s):',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Gabriola',
                        color: Color.fromARGB(255, 39, 51, 57),
                      ),
                    ),
                  ),

                  // Create CheckboxListTile 1.
                  buildCheckboxListTile(
                    titleText: 'Mobility Impairment',
                    value: mobility,
                    onChanged: (value) {
                      setState(() {
                        mobility = value!;
                      });
                    },
                  ),

                  // Create CheckboxListTile 2.
                  buildCheckboxListTile(
                    titleText: 'Visual Impairment',
                    value: visual,
                    onChanged: (value) {
                      setState(() {
                        visual = value!;
                      });
                    },
                  ),

                  // Create CheckboxListTile 3.
                  buildCheckboxListTile(
                    titleText: 'Hearing Impairment',
                    value: hearing,
                    onChanged: (value) {
                      setState(() {
                        hearing = value!;
                      });
                    },
                  ),

                  // Create CheckboxListTile 4,
                  buildCheckboxListTile(
                    titleText:
                        'Cognitive or Neurodiverse', // Autism, ADHD, etc.
                    value: cognitive,
                    onChanged: (value) {
                      setState(() {
                        cognitive = value!;
                      });
                    },
                  ),

                  // Create CheckboxListTile 5.
                  buildCheckboxListTile(
                    titleText: 'Diabetes',
                    value: diabetes,
                    onChanged: (value) {
                      setState(() {
                        diabetes = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      Step(
        isActive: currentStep >= 5,
        title: const Text(''),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  Image.asset(
                    'assets/Images/Profiles/Tourist/InterestsFillingPage/Wondering.gif',
                    fit: BoxFit.cover,
                    height: 350,
                  ),
                ],
              ),
            ),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 100),
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Color(0xFF1E889E),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Validate Choices',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Gabriola',
                              color: Color.fromARGB(255, 39, 51, 57),
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
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Are you sure about keeping the choices\n you\'ve selected?',
                      style: TextStyle(
                        fontSize: 26,
                        fontFamily: 'Gabriola',
                        color: Color.fromARGB(255, 39, 51, 57),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }
}
