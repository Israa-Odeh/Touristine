import 'package:touristine/WebApplication/Notifications/snack_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class DestinationCardGenerator extends StatefulWidget {
  final String token;

  const DestinationCardGenerator({super.key, required this.token});

  @override
  _DestinationCardGeneratorState createState() =>
      _DestinationCardGeneratorState();
}

class _DestinationCardGeneratorState extends State<DestinationCardGenerator> {
  double mainAxisExtent = 540; // Default height value for unseen destinations.
  int uploadedDestsLength = 0;
  List<Map<String, dynamic>> uploadedDestinations = [];
  bool isLoading = true;

  // A Function to fetch user uploaded destinations.
  Future<void> fetchUploadedDests() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('https://touristineapp.onrender.com/get-uploaded-dests');

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
                'adminComment': destinationData['adminComment'],
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
          showCustomSnackBar(context, 'Error retrieving your places',
              bottomMargin: 0);
        }
      }
    } catch (error) {
      if (mounted) {
        print('Error fetching uploaded dests: $error');
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
    fetchUploadedDests();
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: -20,
              child: Image.asset(
                'assets/Images/Profiles/Tourist/emptyListTransparent.gif',
                fit: BoxFit.fill,
              ),
            ),
            const Positioned(
              top: 420,
              child: Text(
                'No places found',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Gabriola',
                  color: Color.fromARGB(255, 23, 99, 114),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 15.0, right: 5.0, left: 5.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // # of destinations in each row.
            mainAxisExtent: 520, // Height of each card.
            crossAxisSpacing: 2.0, // Horizontal spacing between destinations.
            mainAxisSpacing: 8.0, // Vertical spacing between rows.
          ),
          itemCount: uploadedDestinations.length,
          itemBuilder: (context, index) {
            return DestinationCard(
              token: widget.token,
              destination: uploadedDestinations[index],
              onDelete: () {
                setState(() {
                  uploadedDestinations.removeAt(index);
                });
              },
              uploadedDestsLength: uploadedDestsLength,
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
        Uri.parse('https://touristineapp.onrender.com/delete-destination/$destId');

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
      margin: const EdgeInsets.only(right: 5.0, left: 5.0, bottom: 10),
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
              height: 45,
              color: const Color.fromARGB(94, 195, 195, 195),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5.0),
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
                          size: 18,
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
                              fontSize: 20),
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
                                  width: 25,
                                  height: 25,
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
              height: widget.destination['status'].toLowerCase() == "seen"
                  ? 140
                  : 180,
              child: Scrollbar(
                trackVisibility: widget.destination['imagesURLs'].length > 1,
                thumbVisibility: widget.destination['imagesURLs'].length > 1,
                thickness: 5,
                controller: imagesScrollController,
                child: ListView.builder(
                  controller: imagesScrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.destination['imagesURLs'].length,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 310,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Image.network(
                          widget.destination['imagesURLs'][index],
                          height: widget.destination['status'].toLowerCase() ==
                                  "seen"
                              ? 150
                              : 190,
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
                            fontSize: 18,
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
                  Divider(thickness: 2, color: Color.fromARGB(80, 19, 83, 96)),
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
                        fontSize: 16),
                  ),
                  Text(
                    widget.destination['city'],
                    style: const TextStyle(
                        color: Color.fromARGB(255, 12, 53, 61),
                        fontFamily: 'Zilla Slab Light',
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ],
              ),
            ),
            // Divider.
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child:
                  Divider(thickness: 2, color: Color.fromARGB(80, 19, 83, 96)),
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
                        fontSize: 18,
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
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.destination['budget'] ?? '',
                    style: const TextStyle(fontFamily: 'Calibri', fontSize: 17),
                  ),
                  Text(
                      widget.destination['sheltered'] == "true"
                          ? 'Sheltered'
                          : 'Unsheltered',
                      style:
                          const TextStyle(fontFamily: 'Calibri', fontSize: 17)),
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
                      left: 15.0, right: 15, top: 5, bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '${widget.destination['timeToSpend']} ${widget.destination['timeToSpend'] > 1 ? 'hours' : 'hour'}',
                      style:
                          const TextStyle(fontFamily: 'Calibri', fontSize: 17)),
                  Text(widget.destination['date'] ?? '',
                      style:
                          const TextStyle(fontFamily: 'Calibri', fontSize: 17)),
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
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: FaIcon(
                              FontAwesomeIcons.solidTrashCan,
                              color: Colors.black,
                              size: 20,
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
            width: 400,
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
                    fontSize: 20.0,
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
                    fontSize: 18.0,
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
                        fontSize: 16.0,
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
