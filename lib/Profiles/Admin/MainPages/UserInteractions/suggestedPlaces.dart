import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:touristine/Notifications/SnackBar.dart';

class SuggestedPlacesPage extends StatefulWidget {
  final String token;
  final Function(int, Map<String, String>) changeTabIndex;

  SuggestedPlacesPage(
      {super.key, required this.token, required this.changeTabIndex});

  @override
  _SuggestedPlacesPageState createState() => _SuggestedPlacesPageState();
}

class _SuggestedPlacesPageState extends State<SuggestedPlacesPage> {
  int uploadedDestsLength = 0;
  Map<String, String> approvedDestination = {};
  List<Map<String, dynamic>> uploadedDestinations = [
    {
      'firstName': 'Israa',
      'lastName': 'Odeh',
      'destID': '200',
      'date': '2023-01-01',
      'destinationName': 'Sample Destination 1',
      'city': 'Sample City 1',
      'category': 'Sample Category 1',
      'budget': 'Sample Budget 1',
      'timeToSpend': 2,
      'sheltered': 'true',
      'status': 'Unseen',
      'about':
          'This is a sample destination description for the testing purposes.',
      'imagesURLs': [
        'https://noblesanctuary.com/wp-content/uploads/2021/08/Jami-al-Aqsa.jpg',
        'https://i.pinimg.com/736x/9c/58/86/9c588698ef11f7e3b46a5e7d73bd1067.jpg',
      ],
    },
    // Add more sample destinations as needed
    // {
    //   'firstName': 'Rula',
    //   'lastName': 'Odeh',
    //   'destID': '201',
    //   'date': '2023-01-02',
    //   'destinationName': 'Sample Destination 2',
    //   'city': 'Sample City 2',
    //   'category': 'Sample Category 2',
    //   'budget': 'Sample Budget 2',
    //   'timeToSpend': 3,
    //   'sheltered': 'false',
    //   'status': 'Unseen',
    //   'about':
    //       'This is another sample destination description for the testing purposes.',
    //   'imagesURLs': [
    //     'https://noblesanctuary.com/wp-content/uploads/2021/08/Jami-al-Aqsa.jpg',
    //     'https://i.pinimg.com/736x/9c/58/86/9c588698ef11f7e3b46a5e7d73bd1067.jpg',
    //   ],
    // },
  ];
  bool isLoading = true;

  // A Function to fetch user uploaded destinations.
  Future<void> fetchSuggestions() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('https://touristine.onrender.com/get-suggestions');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
      );
      if (mounted) {
        if (response.statusCode == 200) {
          setState(() {
            final List<dynamic> responseData = json.decode(response.body);

            // Convert destinationsData into a list of maps.
            uploadedDestinations = responseData.map((destinationData) {
              return {
                'destID': destinationData['destID'],
                'date': destinationData['date'],
                'destinationName': destinationData['destinationName'],
                'city': destinationData['city'],
                'category': destinationData['category'],
                'budget': destinationData['budget'],
                'timeToSpend': destinationData['timeToSpend'],
                'sheltered': destinationData['sheltered'],
                'status': destinationData['status'],
                'about': destinationData['about'],
                'imagesURLs': destinationData['imagesURLs'],
                // 'adminComment': destinationData['adminComment'],
              };
            }).toList();
            print(uploadedDestinations);
          });
        } else if (response.statusCode == 500) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
        } else {
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, 'Error retrieving suggestions',
              bottomMargin: 0);
        }
      }
    } catch (error) {
      if (mounted) {
        print('Error fetching suggested dests: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // If there are any suggestion to be added as a new destination, navigate
  // to theuploads interface and include the destination where needed.
  void changeTabIndex(int newIndex, Map<String, String> destinationInfo) {
    widget.changeTabIndex(newIndex, destinationInfo);
  }

  void approveDestination(Map<String, String> destinationInfo) {
    approvedDestination = destinationInfo;
    print("Destination Approved: $approvedDestination");

    changeTabIndex(1, approvedDestination);
  }

  @override
  void initState() {
    super.initState();
    fetchSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E889E)),
        ),
      );
    } else if (uploadedDestinations.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 70),
            Image.asset(
              'assets/Images/Profiles/Tourist/emptyListTransparent.gif',
              fit: BoxFit.cover,
            ),
            const Text(
              'No places found',
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Gabriola',
                  color: Color.fromARGB(255, 23, 99, 114)),
            ),
          ],
        ),
      );
    } else {
      ScrollController pageScrollController = ScrollController();

      return uploadedDestinations.length > 1
          ? ScrollbarTheme(
              data: ScrollbarThemeData(
                thumbColor: MaterialStateProperty.all(
                    const Color.fromARGB(255, 131, 131, 131)),
                radius: const Radius.circular(0),
              ),
              child: Scrollbar(
                thumbVisibility: true,
                trackVisibility: true,
                thickness: 6.0,
                controller: pageScrollController,
                child: ListView.builder(
                  controller: pageScrollController,
                  itemCount: uploadedDestinations.length,
                  itemBuilder: (context, index) {
                    TextEditingController commentController =
                        TextEditingController();
                    return DestinationCard(
                      token: widget.token,
                      destination: uploadedDestinations[index],
                      onDelete: () {
                        setState(() {
                          uploadedDestinations.removeAt(index);
                        });
                      },
                      uploadedDestsLength: uploadedDestsLength,
                      commentController: commentController,
                      onApproveSuggestion: (destinationInfo) {
                        approveDestination(destinationInfo);
                      },
                    );
                  },
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 0.0),
              child: ListView.builder(
                itemCount: uploadedDestinations.length,
                itemBuilder: (context, index) {
                  TextEditingController commentController =
                      TextEditingController();
                  return DestinationCard(
                    token: widget.token,
                    destination: uploadedDestinations[index],
                    onDelete: () {
                      setState(() {
                        uploadedDestinations.removeAt(index);
                      });
                    },
                    uploadedDestsLength: uploadedDestsLength,
                    commentController: commentController,
                    onApproveSuggestion: (destinationInfo) {
                      // Call the approveDestination function with the destinationInfo
                      approveDestination(destinationInfo);
                    },
                  );
                },
              ),
            );
    }
  }
}

class DestinationCard extends StatefulWidget {
  final String token;
  final Map<String, dynamic> destination;
  final int uploadedDestsLength;
  final VoidCallback onDelete;
  final TextEditingController commentController;
  final void Function(Map<String, String>) onApproveSuggestion;

  const DestinationCard({
    super.key,
    required this.token,
    required this.destination,
    required this.uploadedDestsLength,
    required this.onDelete,
    required this.commentController,
    required this.onApproveSuggestion,
  });

  @override
  _DestinationCardState createState() => _DestinationCardState();
}

class _DestinationCardState extends State<DestinationCard> {
  final ScrollController imagesScrollController = ScrollController();
  final ScrollController aboutScrollController = ScrollController();

  // A function to delete a specific destination.
  Future<void> deleteSuggestion(String suggestionId) async {
    bool? confirmDeletion = await showConfirmationDialog(
      context,
      'Delete',
      dialogMessage: 'Are you sure you want to delete this suggestion?',
    );
    if (confirmDeletion == true) {
      final url = Uri.parse(
          'https://touristine.onrender.com/delete-suggestion/$suggestionId');

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

          if (responseData.containsKey('message')) {
            // Call onDelete only if deletion is successful
            widget.onDelete();
            // ignore: use_build_context_synchronously
            showCustomSnackBar(context, 'The suggestion has been deleted',
                bottomMargin: 0);
          } else {
            // Handle the case when 'message' key is not present in the response
            print('No message keyword found in the response');
          }
        } else if (response.statusCode == 500) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
        } else if (response.statusCode == 404) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
        } else {
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, 'Error deleting this suggestion',
              bottomMargin: 0);
        }
      } catch (error) {
        print('Error deleting the suggested destination: $error');
      }
    }
  }

  void addAdminComment(String suggestionID, String comment) async {
    print(suggestionID);
    print(comment);
    try {
      final url =
          Uri.parse('https://touristine.onrender.com/add-admin-comment');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {'suggestionID': suggestionID, 'adminComment': comment},
      );

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Your comment has been added',
            bottomMargin: 0);
      } else {
        // final Map<String, dynamic> responseData = json.decode(response.body);
        // // ignore: use_build_context_synchronously
        // showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
      }
    } catch (error) {
      print('Error adding the comment: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: const BorderSide(
          color: Color.fromARGB(80, 0, 0, 0),
          width: 2.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status icon and button row.
            Container(
              height: 55,
              color: const Color.fromARGB(94, 195, 195, 195),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        showTouristNameDialog(
                            "${widget.destination['firstName']} ${widget.destination['lastName']}");
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.circleUser,
                        size: 30,
                        color: Color.fromARGB(185, 0, 0, 0),
                      ),
                      iconSize: 30,
                      color: const Color.fromARGB(82, 30, 137, 158),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          showCommentDialog(
                            widget.commentController,
                          );
                        },
                        borderRadius: BorderRadius.circular(100.0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0.0),
                          child: Image.asset(
                              'assets/Images/Profiles/Admin/message.png',
                              color: Colors.black,
                              width: 35,
                              height: 35,
                              fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Horizontal ListView of images.
            SizedBox(
              height: 200,
              child: Scrollbar(
                trackVisibility: true,
                thumbVisibility: true,
                thickness: 5,
                controller: imagesScrollController,
                child: ListView.builder(
                  controller: imagesScrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.destination['imagesURLs'].length,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 400,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Image.network(
                          widget.destination['imagesURLs'][index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.destination['destinationName'] ?? '',
                          style: const TextStyle(
                            color: Color.fromARGB(255, 12, 53, 61),
                            fontFamily: 'Zilla Slab Light',
                            fontWeight: FontWeight.bold,
                            fontSize: 23,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child:
                  Divider(thickness: 3, color: Color.fromARGB(80, 19, 83, 96)),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 2.0, bottom: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.destination['category'] ?? '',
                    style: const TextStyle(
                        color: Color.fromARGB(255, 12, 53, 61),
                        fontFamily: 'Zilla Slab Light',
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  Text(
                    widget.destination['city'],
                    style: const TextStyle(
                        color: Color.fromARGB(255, 12, 53, 61),
                        fontFamily: 'Zilla Slab Light',
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ],
              ),
            ),
            // Divider.
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child:
                  Divider(thickness: 3, color: Color.fromARGB(80, 19, 83, 96)),
            ),
            // About destination text.
            Scrollbar(
              thickness: 5.0,
              thumbVisibility: true,
              trackVisibility: true,
              controller: aboutScrollController,
              child: SizedBox(
                height: 90.0,
                child: SingleChildScrollView(
                  controller: aboutScrollController,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 8),
                    child: Text(
                      widget.destination['about'] ?? '',
                      style: const TextStyle(
                        fontFamily: 'Andalus',
                        color: Color(0xFF595959),
                        fontSize: 25,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Divider.
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Divider(thickness: 2.0, color: Color(0xFFbfbfbf)),
            ),
            // Budget and sheltered status row.
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.destination['budget'] ?? '',
                    style: const TextStyle(fontFamily: 'Calibri', fontSize: 20),
                  ),
                  Text(
                      widget.destination['sheltered'] == "true"
                          ? 'Sheltered'
                          : 'Unsheltered',
                      style:
                          const TextStyle(fontFamily: 'Calibri', fontSize: 20)),
                ],
              ),
            ),
            // Divider.
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Divider(thickness: 2.0, color: Color(0xFFbfbfbf)),
            ),
            // Time to spend and date row.
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15, top: 10, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '${widget.destination['timeToSpend']} ${widget.destination['timeToSpend'] > 1 ? 'hours' : 'hour'}',
                      style:
                          const TextStyle(fontFamily: 'Calibri', fontSize: 20)),
                  Text(widget.destination['date'] ?? '',
                      style:
                          const TextStyle(fontFamily: 'Calibri', fontSize: 20)),
                ],
              ),
            ),
            // Container with icon button.
            Container(
              color: const Color.fromARGB(94, 195, 195, 195),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          print(widget.destination['destID']);
                          await deleteSuggestion(widget.destination['destID']);
                        },
                        borderRadius: BorderRadius.circular(30.0),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10),
                          child: FaIcon(
                            FontAwesomeIcons.solidTrashCan,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (widget.commentController.text.isEmpty) {
                          showCustomSnackBar(
                              context, 'Kindly provide feedback for the user',
                              bottomMargin: 0);
                        } else {
                          print("A comment is added");
                          addAdminComment(widget.destination['destID'],
                              widget.commentController.text);

                          // Send a request to update the admin comment.
                          List<String> imagesURLs =
                              widget.destination['imagesURLs'];
                          String imagesURLsString = imagesURLs.join(', ');

                          // Format the map with all destination information
                          Map<String, String> destinationInfo = {
                            // 'destID': widget.destination['destID'],
                            // 'comment': widget.commentController.text,
                            'destinationName':
                                widget.destination['destinationName'],
                            'city': widget.destination['city'],
                            'category': widget.destination['category'],
                            'budget': widget.destination['budget'],
                            'timeToSpend':
                                widget.destination['timeToSpend'].toString(),
                            'sheltered': widget.destination['sheltered'],
                            'status': widget.destination['status'],
                            'about': widget.destination['about'],
                            'imageURLs': imagesURLsString,
                            // Add other destination information as needed
                            ///////////////// Image URLs //////////////////
                          };
                          // Call the callback function when add comment button is pressed
                          widget.onApproveSuggestion(destinationInfo);
                        }
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.circlePlus,
                        size: 30,
                        color: Color.fromARGB(185, 0, 0, 0),
                      ),
                      iconSize: 30,
                      color: const Color.fromARGB(82, 30, 137, 158),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showTouristNameDialog(String name) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'This place is suggested by',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontFamily: 'Gabriola',
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 18, 84, 97),
                  ),
                ),
                const Divider(
                    thickness: 1, color: Color.fromARGB(255, 16, 73, 85)),
                const SizedBox(height: 10.0),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 28.0,
                    fontFamily: 'Zilla Slab Light',
                    color: Color.fromARGB(255, 18, 84, 97),
                  ),
                ),
                const SizedBox(height: 20.0),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 22.0,
                        fontFamily: 'Zilla',
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 214, 61, 27),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> showCommentDialog(TextEditingController controller) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  cursorColor: const Color(0xFF1E889E),
                  controller: controller,
                  minLines: 1,
                  maxLines: 7,
                  maxLength: 200,
                  decoration: const InputDecoration(
                    labelText: 'Enter your comment',
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1E889E)),
                    ),
                    labelStyle: TextStyle(
                      fontSize: 25,
                      color: Color.fromARGB(255, 71, 71, 71),
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 22.0,
                    fontFamily: 'Zilla Slab Light',
                    color: Color.fromARGB(255, 18, 84, 97),
                  ),
                ),
                const SizedBox(height: 20.0),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
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
                            color: Color.fromARGB(255, 214, 61, 27),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool?> showConfirmationDialog(
    BuildContext context,
    String confirmBTN, {
    String dialogMessage =
        'Are you certain about adding this suggestion as a new destination?',
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              confirmBTN == "Delete" ? 'Confirm Deletion' : "Confirm Decision",
              style: const TextStyle(
                  fontFamily: 'Zilla Slab Light',
                  fontWeight: FontWeight.bold,
                  fontSize: 25)),
          content: Text(
            dialogMessage,
            style: const TextStyle(fontFamily: 'Andalus', fontSize: 25),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 22.0,
                  fontFamily: 'Zilla',
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                confirmBTN,
                style: const TextStyle(
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
}
