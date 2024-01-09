import 'package:touristine/AndroidMobileApp/Notifications/snack_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class ComplaintsListPage extends StatefulWidget {
  final String token;
  final String destinationName;

  const ComplaintsListPage(
      {super.key, required this.token, required this.destinationName});

  @override
  _ComplaintsListPageState createState() => _ComplaintsListPageState();
}

class _ComplaintsListPageState extends State<ComplaintsListPage> {
  List<Map<String, dynamic>> complaints = [];
  bool isLoading = true;

  // A Function to fetch destination complaints from the backend.
  Future<void> getDestinationComplaints() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    final url =
        Uri.parse('https://touristine.onrender.com/get-destination-complaints');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {
          'destinationName': widget.destinationName,
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        // Jenan, I need to retrieve a list of complaints - if there is any,
        // the retrieved list<map> will be of the same format as the one
        // given at line 243.
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<Map<String, dynamic>> fetchedComplaints =
            List<Map<String, dynamic>>.from(responseBody['complaints']);

        setState(() {
          complaints = fetchedComplaints;
        });
        print(complaints);
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['error'] ==
            'Complaints are not available for this destination') {
          showCustomSnackBar(context, 'Complaints are not available',
              bottomMargin: 0);
        } else {
          showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
        }
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Error retrieving destination complaints',
            bottomMargin: 0);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        print('Error fetching complaints: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // A function to delete all complaints for a specific destination - from the admin side.
  Future<void> deleteAllComplaints() async {
    bool? confirmDeletion = await showConfirmationDialog(
      context,
      dialogMessage: 'Are you sure you want to delete all the complaints?',
    );

    if (confirmDeletion == true) {
      if (!mounted) return;
      try {
        final url =
            Uri.parse('https://touristine.onrender.com/delete-all-complaints');

        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Bearer ${widget.token}',
          },
          body: {
            'destinationName': widget.destinationName,
          },
        );
        if (response.statusCode == 200) {
          // Successful deletion on the backend, now update the UI.
          setState(() {
            complaints.clear();
          });
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, "The complaints have been deleted",
              bottomMargin: 0);
        } else {
          final Map<String, dynamic> responseData = json.decode(response.body);
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
        }
      } catch (error) {
        print('Error deleting all complaints: $error');
      }
    }
  }

  void deleteComplaint(String complaintId) async {
    bool? confirmDeletion = await showConfirmationDialog(context);

    if (confirmDeletion == true) {
      if (!mounted) return;
      try {
        final url =
            Uri.parse('https://touristine.onrender.com/delete-complaint');

        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Bearer ${widget.token}',
          },
          body: {
            'complaintId': complaintId,
            'destinationName': widget.destinationName,
          },
        );

        if (response.statusCode == 200) {
          // Israa, show a notification on success.
          setState(() {
            complaints
                .removeWhere((complaint) => complaint['id'] == complaintId);
          });
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, "The complaint has been deleted",
              bottomMargin: 0);
        } else {
          final Map<String, dynamic> responseData = json.decode(response.body);
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
        }
      } catch (error) {
        print('Error deleting complaint: $error');
      }
    }
  }

  Future<void> markComplaintAsSeen(String complaintId) async {
    if (!mounted) return;

    try {
      final url =
          Uri.parse('https://touristine.onrender.com/mark-complaint-as-seen');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {
          'complaintId': complaintId,
          'destinationName': widget.destinationName,
        },
      );

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, "The seen status has been modified",
            bottomMargin: 0);
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
      }
    } catch (error) {
      print('Error marking complaint as seen: $error');
    }
  }

  void updateComplaintStatusLocally(String complaintId) {
    // Find the index of the complaint in the list.
    int index = complaints.indexWhere((c) => c['id'] == complaintId);
    if (index != -1) {
      // Update the 'seen' status locally.
      setState(() {
        complaints[index]['seen'] = 'true';
      });
    }
  }

  Future<bool?> showConfirmationDialog(
    BuildContext context, {
    String dialogMessage = 'Are you sure you want to delete this complaint?',
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion',
              style: TextStyle(
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
              child: const Text(
                'Delete',
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
  void initState() {
    super.initState();
    print(widget.destinationName);
    getDestinationComplaints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: complaints.isNotEmpty ? 0.0 : 24),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
              image:
                  AssetImage("assets/Images/Profiles/Admin/mainBackground.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF1E889E)),
                        ),
                      )
                    : (complaints.isEmpty
                        ? Center(
                            child: Column(
                              children: [
                                const SizedBox(height: 120),
                                Image.asset(
                                  'assets/Images/Profiles/Tourist/emptyListTransparent.gif',
                                  fit: BoxFit.cover,
                                ),
                                const Text(
                                  'No complaints found',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Gabriola',
                                    color: Color.fromARGB(255, 23, 99, 114),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: complaints.length,
                            itemBuilder: (context, index) {
                              return ComplaintCard(
                                complaint: complaints[index],
                                onDelete: deleteComplaint,
                                showConfirmationDialog: showConfirmationDialog,
                                markAsSeen: markComplaintAsSeen,
                                updateComplaintLocally:
                                    updateComplaintStatusLocally,
                              );
                            },
                          )),
              ),
            ],
          ),
        ),
      ),
      persistentFooterButtons: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: IconButton(
                icon: const FaIcon(
                  FontAwesomeIcons.arrowLeft,
                  color: Color(0xFF1E889E),
                  size: 30,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            if (complaints.isNotEmpty && !isLoading)
              ElevatedButton(
                onPressed: () async {
                  await deleteAllComplaints();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  backgroundColor: const Color(0xFF1E889E),
                  textStyle: const TextStyle(
                    fontSize: 25,
                    fontFamily: 'Zilla',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Delete All'),
              ),
          ],
        ),
      ],
    );
  }
}

class ComplaintCard extends StatelessWidget {
  final Map<String, dynamic> complaint;
  final Function(String) onDelete;
  final Function(BuildContext) showConfirmationDialog;
  final Function(String) markAsSeen;
  final Function(String) updateComplaintLocally;

  const ComplaintCard(
      {super.key,
      required this.complaint,
      required this.onDelete,
      required this.showConfirmationDialog,
      required this.markAsSeen,
      required this.updateComplaintLocally});

  @override
  Widget build(BuildContext context) {
    bool isSeen = complaint['seen'].toLowerCase() == 'true';

    final List<String> images = (complaint['images'] as List).cast<String>();
    final ScrollController scrollController = ScrollController();

    return Card(
      margin: const EdgeInsets.only(right: 10, left: 10, bottom: 15),
      color: const Color.fromARGB(255, 239, 239, 239),
      elevation: 5,
      // shadowColor: const Color(0xFF1E889E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    complaint['firstName'],
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Times New Roman',
                      color: Color.fromARGB(255, 21, 98, 113),
                    ),
                  ),
                  Text(
                    " ${complaint['lastName']}",
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Times New Roman',
                      color: Color.fromARGB(255, 21, 98, 113),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Color.fromARGB(126, 14, 63, 73),
              thickness: 2,
            ),
            ListTile(
              title: Padding(
                padding: const EdgeInsets.only(bottom: 15.0, top: 10.0),
                child: Text(
                  complaint['title'],
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Times New Roman',
                    color: Color.fromARGB(255, 14, 63, 73),
                  ),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    complaint['complaint'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w100,
                      fontFamily: 'Zilla',
                      color: Color.fromARGB(255, 14, 63, 73),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Display images if available.
            if (images.isNotEmpty)
              SizedBox(
                height: 150,
                child: images.length >= 4
                    ? Scrollbar(
                        trackVisibility: true,
                        thumbVisibility: true,
                        controller: scrollController,
                        child: ListView.builder(
                          controller: scrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length,
                          itemBuilder: (context, imgIndex) {
                            return InkWell(
                              onTap: () {
                                showImageDialog(context, images[imgIndex]);
                              },
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      right: 8.0,
                                      left: 8.0,
                                      top: 8.0,
                                      bottom: 15.0,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        border: Border.all(
                                          color: const Color.fromARGB(
                                              121, 30, 137, 158),
                                          width: 3.0,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: Image.network(
                                          images[imgIndex],
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: InkWell(
                                      onTap: () {
                                        showImageDialog(
                                            context, images[imgIndex]);
                                      },
                                      child: const Icon(
                                        Icons.fullscreen,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: images.length,
                        itemBuilder: (context, imgIndex) {
                          return InkWell(
                            onTap: () {
                              showImageDialog(context, images[imgIndex]);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color:
                                        const Color.fromARGB(121, 30, 137, 158),
                                    width: 3.0,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    images[imgIndex],
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Text(
                      complaint['date'],
                      style: const TextStyle(
                        fontSize: 19.5,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Time New Roman',
                        color: Color.fromARGB(255, 14, 63, 73),
                      ),
                    ),
                  ),
                  Text(
                    complaint['seen'].toLowerCase() == "true"
                        ? 'Seen'
                        : 'Unseen',
                    style: const TextStyle(
                      fontSize: 19.5,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Time New Roman',
                      color: Color.fromARGB(255, 14, 63, 73),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Color.fromARGB(126, 14, 63, 73),
              thickness: 2,
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: isSeen
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    FontAwesomeIcons.trash,
                    color: Color(0xFF1E889E),
                    size: 30,
                  ),
                  onPressed: () async {
                    onDelete(complaint['id']);
                    print('complaint: ${complaint['title']}');
                  },
                ),
                if (!isSeen)
                  IconButton(
                    tooltip: "Mark as Seen",
                    icon: const Icon(
                      FontAwesomeIcons.solidCircleCheck,
                      color: Color(0xFF1E889E),
                      size: 30,
                    ),
                    onPressed: () async {
                      await markAsSeen(complaint['id']);
                      // Update the 'seen' status locally
                      updateComplaintLocally(complaint['id']);
                      print('The marked complaint: ${complaint['title']}');
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void showImageDialog(BuildContext context, String imagePath) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: SizedBox(
          width: 500,
          height: 260,
          child: Column(
            children: [
              Expanded(
                child: PhotoView(
                  imageProvider: NetworkImage(imagePath),
                  minScale: PhotoViewComputedScale.covered,
                  maxScale: PhotoViewComputedScale.covered * 4,
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        backgroundColor: const Color(0xFF1E889E),
                        textStyle: const TextStyle(
                          fontSize: 22.0,
                          fontFamily: 'Zilla',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('Close'),
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
