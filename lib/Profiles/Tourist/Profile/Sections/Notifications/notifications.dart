import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:touristine/Notifications/SnackBar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'notification_controller.dart';
import 'dart:convert';

class NotificationsWidget extends StatefulWidget {
  final String token;

  const NotificationsWidget({super.key, required this.token});

  @override
  _NotificationsWidgetState createState() => _NotificationsWidgetState();
}

class _NotificationsWidgetState extends State<NotificationsWidget> {
  bool enableNotifications = false;

  @override
  void initState() {
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:
            NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
            NotificationController.onDismissActionReceivedMethod);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E889E)),
        useMaterial3: true,
      ),
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned(
              top: 23,
              left: 0,
              right: 0,
              bottom: 0,
              child: Image.asset(
                'assets/Images/Profiles/Tourist/Notifications/notificationsBackground.png',
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 120.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                        'assets/Images/Profiles/Tourist/Notifications/pushNotifications.gif',
                        fit: BoxFit.cover),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E889E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Enable Notifications',
                            style: TextStyle(
                                fontSize: 22.0,
                                color: Color.fromARGB(255, 18, 82, 95)),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Switch(
                            value: enableNotifications,
                            onChanged: (value) {
                              setState(() {
                                enableNotifications = value;
                                if (enableNotifications) {
                                  List<Map<String, dynamic>> userComplaints = [
                                    {
                                      'title': 'Leaking Tank',
                                      'destinationName': 'Palestine Aquarium',
                                      'city': 'Ramallah',
                                      'isNotified': 'true'
                                      // seen true or false.
                                    },
                                  ];
                                  List<Map<String, dynamic>> userUploads = [
                                    {
                                      'keywords': 'General',
                                      'destinationName': 'Palestine Aquarium',
                                      'city': 'Ramallah',
                                      'status': 'Approved'
                                    },
                                  ];
                                  List<Map<String, dynamic>> userSuggestions = [
                                    {
                                      'destinationName': 'Palestine Aquarium',
                                      'city': 'Ramallah',
                                    },
                                  ];
                                  // Suggestions status (Seen/Unseen).

                                  sendNotification(userComplaints, userUploads,
                                      userSuggestions);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 320.0, top: 130),
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void sendNotification(
      List<Map<String, dynamic>> userComplaints,
      List<Map<String, dynamic>> userUploads,
      List<Map<String, dynamic>> userSuggestions) {
    for (var complaint in userComplaints) {
      String title = complaint['title'];
      String destinationName = complaint['destinationName'];
      String city = complaint['city'];

      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: userComplaints.indexOf(complaint) + 1000,
          channelKey: "touristine_channel",
          title: "Touristine Notification",
          body:
              """Your complaint about $title at $destinationName in $city has been reviewed.
               Thank you for bringing this to our attention; your concern is being considered.
                If you have additional details or questions, feel free to reach out. Your 
                contribution to maintaining our quality is appreciated.""",
        ),
      );
    }
    // Loop through the user uploads and create notifications
    for (var uplaod in userUploads) {
      String keywords = uplaod['keywords'];
      String destinationName = uplaod['destinationName'];
      String city = uplaod['city'];
      String status = uplaod['status'];

      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: userUploads.indexOf(uplaod) + 2000,
          channelKey: "touristine_channel",
          title: "Touristine Notification",
          body: status.toLowerCase() == "Approved"
              ? "Your uploaded images in the specified category $keywords for $destinationName in $city has been officially approved. Your diligence in contributing valuable content is genuinely appreciated, and we anticipate more of your meaningful contributions in the future. Thank you for being a valuable member of our community!"
              : "Your uploaded images in the specified category $keywords for $destinationName in $city has not met our approval criteria and has been rejected. We appreciate your effort. Thank you for your understanding.",
        ),
      );
    }

    // Loop through the user suggestions and create notifications.
    for (var suggestion in userSuggestions) {
      String destinationName = suggestion['destinationName'];
      String city = suggestion['city'];

      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: userSuggestions.indexOf(suggestion) + 3000,
          channelKey: "touristine_channel",
          title: "Touristine Notification",
          body: """Your suggested $destinationName in $city has been viewed,
           and there is a comment for you to check.""",
        ),
      );
    }
  }

  void sendNotificationTest() async {
    try {
      // Fetch user complaints from the backend
      List<Map<String, dynamic>> userComplaints =
          await fetchUnnotifiedComplaints();
      List<Map<String, dynamic>> userUploadedImages =
          await fetchUnnotifiedUploads();
      List<Map<String, dynamic>> userSuggestions =
          await fetchUnnotifiedSuggestions();

      // Loop through the user complaints and create notifications
      for (var complaint in userComplaints) {
        String title = complaint['title'];
        String destinationName = complaint['destinationName'];
        String city = complaint['city'];

        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: userComplaints.indexOf(complaint) + 1,
            channelKey: "touristine_channel",
            title: "Touristine Notification",
            body:
                "Your complaint about $title at $destinationName in $city has been reviewed. Thank you for bringing this to our attention; your concern is being considered. If you have additional details or questions, feel free to reach out. Your contribution to maintaining our quality is appreciated.",
          ),
        );
      }
      // Loop through the user uploads and create notifications
      for (var uplaod in userUploadedImages) {
        String catgeory = uplaod['category'];
        String destinationName = uplaod['destinationName'];
        String city = uplaod['city'];
        String status = uplaod['status'];

        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: userComplaints.indexOf(uplaod) + 1,
            channelKey: "touristine_channel",
            title: "Touristine Notification",
            body: status.toLowerCase() == "Approved"
                ? "Your uploaded images in the specified category $catgeory for $destinationName in $city has been officially approved. Your diligence in contributing valuable content is genuinely appreciated, and we anticipate more of your meaningful contributions in the future. Thank you for being a valuable member of our community!"
                : "Your uploaded images in the specified category $catgeory for $destinationName in $city has not met our approval criteria and has been rejected. We appreciate your effort. Thank you for your understanding.",
          ),
        );
      }
      // Loop through the user suggestions and create notifications.
      for (var suggestion in userSuggestions) {
        String destinationName = suggestion['destinationName'];
        String city = suggestion['city'];

        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: userSuggestions.indexOf(suggestion) + 3000,
            channelKey: "touristine_channel",
            title: "Touristine Notification",
            body: """Your suggested $destinationName in $city has been viewed,
           and there is a comment for you to check.""",
          ),
        );
      }
    } catch (e) {
      print("Error fetching user complaints: $e");
    }
  }

  // // A Function to fetch user unNotified complaints from the backend.
  Future<List<Map<String, dynamic>>> fetchUnnotifiedComplaints() async {
    final url =
        Uri.parse('https://touristine.onrender.com/get-unnotified-complaints');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        // Jenan, I need to retrieve a List<Map> of complaints which have a status of
        // (seen: true) and and aren't notified (isNotified flag == false), the format
        // will be as follows:
        /* 
        List<Map<String, dynamic>> userComplaints = [
          {
            'title': 'Leaking Tank',
            'destinationName': 'Palestine Aquarium',
            'city': 'Ramallah'
          },
        ];
        */
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('complaints')) {
          List<Map<String, dynamic>> complaints =
              List<Map<String, dynamic>>.from(responseData['complaints']);
          print(complaints);
          return complaints;
        } else {
          // Handle the case when 'complaints' key is not present in the response
          print('No complaints keyword found in the response');
          return [];
        }
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, responseData['error'], bottomMargin: 310);
        return [];
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Error retrieving unnotified complaints',
            bottomMargin: 310);
        return [];
      }
    } catch (error) {
      print('Error fetching unnotified complaints: $error');
      return [];
    }
  }

  // A Function to fetch user unNotified complaints from the backend.
  Future<List<Map<String, dynamic>>> fetchUnnotifiedUploads() async {
    final url =
        Uri.parse('https://touristine.onrender.com/get-unnotified-uplaods');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        // Jenan, I need to retrieve a List<Map> of uploaded Images which have the status
        // (Rejected, and Approved only) and aren't not (isNotified flag == false),
        // the format will be as follows:
        /* 
        List<Map<String, dynamic>> userUploads = [
          {
            'keywords': 'General',
            'destinationName': 'Palestine Aquarium',
            'city': 'Ramallah',
            'status': 'Approved' // or Rejected, I don't need Pending ones.
          },
        ];
        */
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('uploadedImages')) {
          List<Map<String, dynamic>> uploadedImages =
              List<Map<String, dynamic>>.from(responseData['uploadedImages']);
          print(uploadedImages);
          return uploadedImages;
        } else {
          // Handle the case when 'complaints' key is not present in the response
          print('No uploadedImages keyword found in the response');
          return [];
        }
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, responseData['error'], bottomMargin: 310);
        return [];
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Error retrieving unnotified uploads',
            bottomMargin: 310);
        return [];
      }
    } catch (error) {
      print('Error fetching unnotified uploads: $error');
      return [];
    }
  }

  // A Function to fetch user unNotified complaints from the backend.
  Future<List<Map<String, dynamic>>> fetchUnnotifiedSuggestions() async {
    final url =
        Uri.parse('https://touristine.onrender.com/get-unnotified-suggestions');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        // Jenan, I need to retrieve a List<Map> of suggestions which have the
        // status (Seen) and are not notified (isNotified flag == false),
        // the format will be as follows:
        /*
        List<Map<String, dynamic>> userSuggestions = [
          {
            'destinationName': 'Palestine Aquarium',
            'city': 'Ramallah',
          },
        ];
         */

        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('suggestions')) {
          List<Map<String, dynamic>> suggestions =
              List<Map<String, dynamic>>.from(responseData['suggestions']);
          print(suggestions);
          return suggestions;
        } else {
          // Handle the case when 'complaints' key is not present in the response
          print('No uploadedImages keyword found in the response');
          return [];
        }
      } else if (response.statusCode == 500) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, responseData['error'], bottomMargin: 310);
        return [];
      } else {
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, 'Error retrieving unnotified suggestions',
            bottomMargin: 310);
        return [];
      }
    } catch (error) {
      print('Error fetching unnotified suggestions: $error');
      return [];
    }
  }
}
