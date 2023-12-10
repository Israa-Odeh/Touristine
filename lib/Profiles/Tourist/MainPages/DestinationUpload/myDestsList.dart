import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:touristine/Notifications/SnackBar.dart';

// ignore: must_be_immutable
class DestinationCardGenerator extends StatefulWidget {
  final String token;
  List<Map<String, dynamic>> uploadedDestinations;

  DestinationCardGenerator(
      {super.key, required this.token, required this.uploadedDestinations});

  @override
  _DestinationCardGeneratorState createState() =>
      _DestinationCardGeneratorState();
}

class _DestinationCardGeneratorState extends State<DestinationCardGenerator> {
  int uploadedDestsLength = 0;
  // A Function to fetch user uploaded destinations.
  Future<void> fetchUploadedDests() async {
    final url = Uri.parse('https://touristine.onrender.com/get-uploaded-dests');

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
            widget.uploadedDestinations = responseData.map((destinationData) {
              return {
                'destID': destinationData['destID'],
                'date': destinationData['date'],
                'destinationName': destinationData['destinationName'],
                'category': destinationData['category'],
                'budget': destinationData['budget'],
                'timeToSpend': destinationData['timeToSpend'],
                'sheltered': destinationData['sheltered'],
                'status': destinationData['status'],
                'about': destinationData['about'],
                'imagesURLs': destinationData['imagesURLs'],
              };
            }).toList();
            print(widget.uploadedDestinations);
          });
        } else if (response.statusCode == 500) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
        } else {
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, 'Error retrieving your places',
              bottomMargin: 0);
        }
      }
    } catch (error) {
      if (mounted) {
        print('Error fetching uploaded dests: $error');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUploadedDests();
    uploadedDestsLength = widget.uploadedDestinations.length;
  }

  @override
  Widget build(BuildContext context) {
    ScrollController pageScrollController = ScrollController();

    return widget.uploadedDestinations.length > 1
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
                itemCount: widget.uploadedDestinations.length,
                itemBuilder: (context, index) {
                  return DestinationCard(
                    token: widget.token,
                    destination: widget.uploadedDestinations[index],
                    onDelete: () {
                      setState(() {
                        widget.uploadedDestinations.removeAt(index);
                      });
                    },
                    uploadedDestsLength: uploadedDestsLength,
                  );
                },
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.0),
            child: ListView.builder(
              itemCount: widget.uploadedDestinations.length,
              itemBuilder: (context, index) {
                return DestinationCard(
                  token: widget.token,
                  destination: widget.uploadedDestinations[index],
                  onDelete: () {
                    setState(() {
                      widget.uploadedDestinations.removeAt(index);
                    });
                  },
                  uploadedDestsLength: uploadedDestsLength,
                );
              },
            ),
          );
  }
}

class DestinationCard extends StatefulWidget {
  final String token;
  final Map<String, dynamic> destination;
  final int uploadedDestsLength;
  final VoidCallback onDelete;

  const DestinationCard(
      {super.key,
      required this.token,
      required this.destination,
      required this.uploadedDestsLength,
      required this.onDelete});

  @override
  _DestinationCardState createState() => _DestinationCardState();
}

class _DestinationCardState extends State<DestinationCard> {
  final ScrollController imagesScrollController = ScrollController();
  final ScrollController aboutScrollController = ScrollController();

  // A function to delete a specific destination.
  Future<void> deleteDestination(String destId) async {
    final url =
        Uri.parse('https://touristine.onrender.com/delete-destination/$destId');

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
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, 'The Destination has been deleted',
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
        showCustomSnackBar(context, 'Error deleting this destination',
            bottomMargin: 0);
      }
    } catch (error) {
      print('Error deleting the destination: $error');
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          widget.destination['status'].toLowerCase() == "seen"
                              ? FontAwesomeIcons.circleCheck
                              : FontAwesomeIcons.circleXmark,
                          color: const Color(0xFF7F7F7F),
                          size: 23,
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          widget.destination['status'].toLowerCase() == "seen"
                              ? "Seen"
                              : "Unseen",
                          style: const TextStyle(
                              color: Color(0xFF7F7F7F),
                              fontFamily: 'Calibri',
                              fontWeight: FontWeight.bold,
                              fontSize: 25),
                        ),
                      ],
                    ),
                    Visibility(
                      visible:
                          widget.destination['status'].toLowerCase() == "seen",
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            showCommentDialog(
                                widget.destination['adminComment']);
                          },
                          borderRadius: BorderRadius.circular(100.0),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 0.0),
                            child: Visibility(
                              visible: widget.destination['adminComment'] != "",
                              child: Image.asset(
                                  'assets/Images/Profiles/Tourist/DestUpload/adminIcon.png',
                                  color: Colors.black,
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Horizontal ListView of images.
            SizedBox(
              height: widget.uploadedDestsLength == 1 &&
                      widget.destination['status'].toLowerCase() == "seen"
                  ? 175
                  : 220,
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
                          fit: BoxFit.fill,
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
                  const Text(
                    "Bethlehem",
                    style: TextStyle(
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
                height: 130.0,
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
              padding: widget.destination['status'].toLowerCase() == "seen"
                  ? const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10)
                  : const EdgeInsets.only(
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
            Visibility(
              visible: widget.destination['status'].toLowerCase() == "seen",
              child: Container(
                color: const Color.fromARGB(94, 195, 195, 195),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            print(widget.destination['destID']);
                            await deleteDestination(
                                widget.destination['destID']);
                            // This will be called only if the deletion process succeeded.
                            widget.onDelete();
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
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showCommentDialog(String comment) async {
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
                  'Admin Comment',
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
                  comment,
                  style: const TextStyle(
                    fontSize: 22.0,
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
}
