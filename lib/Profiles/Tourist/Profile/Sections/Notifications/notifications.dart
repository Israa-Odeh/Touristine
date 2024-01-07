import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'notification_controller.dart';

void main() async {
  await AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelGroupKey: "touristine_channel_group",
      channelKey: "touristine_channel",
      channelName: "Touristine Notification",
      channelDescription: "Touristine notifications channel",
    )
  ], channelGroups: [
    NotificationChannelGroup(
        channelGroupKey: "touristine_channel_group",
        channelGroupName: "Touristine Group")
  ]);
  bool isAllowedToSendNotification =
      await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowedToSendNotification) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Touristine Notifications Interface',
      home: NotificationsWidget(),
    );
  }
}

class NotificationsWidget extends StatefulWidget {
  const NotificationsWidget({super.key});
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
                'assets/images/notificationsBackground.png',
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/PushNotifications.gif',
                      fit: BoxFit.cover),
                  const SizedBox(height: 20.0),
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
                                  },
                                ];
                                List<Map<String, dynamic>> userUploads = [
                                  {
                                    'category': 'General',
                                    'destinationName': 'Palestine Aquarium',
                                    'city': 'Ramallah',
                                    'status': 'Approved'
                                  },
                                ];
                                sendNotification(userComplaints, userUploads);
                              }
                            });
                          },
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
    );
  }

  void sendNotification(List<Map<String, dynamic>> userComplaints,
      List<Map<String, dynamic>> userUploads) {
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
              """Your complaint about $title at $destinationName in $city has been reviewed.
               Thank you for bringing this to our attention; your concern is being considered.
                If you have additional details or questions, feel free to reach out. Your 
                contribution to maintaining our quality is appreciated.""",
        ),
      );
    }
    // Loop through the user uploads and create notifications
    for (var uplaod in userUploads) {
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
  }

  // void sendNotification() async {
  //   try {
  //     // Fetch user complaints from the backend
  //     List<Map<String, dynamic>> userComplaints =
  //         await fetchUnnotifiedComplaints();
  //     List<Map<String, dynamic>> userUploadedImages =
  //         await fetchUnnotifiedUploads();

  //     // Loop through the user complaints and create notifications
  //     for (var complaint in userComplaints) {
  //       String title = complaint['title'];
  //       String destinationName = complaint['destinationName'];
  //       String city = complaint['city'];

  //       AwesomeNotifications().createNotification(
  //         content: NotificationContent(
  //           id: userComplaints.indexOf(complaint) + 1,
  //           channelKey: "touristine_channel",
  //           title: "Touristine Notification",
  //           body:
  //               "Your complaint about $title at $destinationName in $city has been reviewed. Thank you for bringing this to our attention; your concern is being considered. If you have additional details or questions, feel free to reach out. Your contribution to maintaining our quality is appreciated.",
  //         ),
  //       );
  //     }
  //     // Loop through the user uploads and create notifications
  //     for (var uplaod in userUploadedImages) {
  //       String catgeory = uplaod['category'];
  //       String destinationName = uplaod['destinationName'];
  //       String city = uplaod['city'];
  //       String status = uplaod['status'];

  //       AwesomeNotifications().createNotification(
  //         content: NotificationContent(
  //           id: userComplaints.indexOf(uplaod) + 1,
  //           channelKey: "touristine_channel",
  //           title: "Touristine Notification",
  //           body: status.toLowerCase() == "Approved"
  //               ? "Your uploaded images in the specified category $catgeory for $destinationName in $city has been officially approved. Your diligence in contributing valuable content is genuinely appreciated, and we anticipate more of your meaningful contributions in the future. Thank you for being a valuable member of our community!"
  //               : "Your uploaded images in the specified category $catgeory for $destinationName in $city has not met our approval criteria and has been rejected. We appreciate your effort. Thank you for your understanding.",
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     print("Error fetching user complaints: $e");
  //   }
  // }

  // // // A Function to fetch user unNotified complaints from the backend.
  // Future<void> fetchUnnotifiedComplaints() async {
  //   final url =
  //       Uri.parse('https://touristine.onrender.com/get-unnotified-complaints');

  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/x-www-form-urlencoded',
  //         'Authorization': 'Bearer ${widget.token}',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       // Jenan, I need to retrieve a list of complaints which have a seen
  //       // status (true) and not notified (isNotified flag == false).
  //       final Map<String, dynamic> responseData = json.decode(response.body);

  //       if (responseData.containsKey('complaints')) {
  //         complaints =
  //             List<Map<String, dynamic>>.from(responseData['complaints']);
  //         print(complaints);
  //       } else {
  //         // Handle the case when 'complaints' key is not present in the response
  //         print('No complaints keyword found in the response');
  //       }
  //     } else if (response.statusCode == 500) {
  //       final Map<String, dynamic> responseData = json.decode(response.body);
  //       // ignore: use_build_context_synchronously
  //       showCustomSnackBar(context, responseData['error'], bottomMargin: 310);
  //     } else {
  //       // ignore: use_build_context_synchronously
  //       showCustomSnackBar(context, 'Error retrieving unnotified complaints',
  //           bottomMargin: 310);
  //     }
  //   } catch (error) {
  //     print('Error fetching unnotified complaints: $error');
  //   }
  // }

  // // A Function to fetch user unNotified complaints from the backend.
  // Future<void> fetchUnnotifiedUploads() async {
  //   final url =
  //       Uri.parse('https://touristine.onrender.com/get-unnotified-uplaods');

  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/x-www-form-urlencoded',
  //         'Authorization': 'Bearer ${widget.token}',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       // Jenan, I need to retrieve a list of uploadd which have the
  //       // status (Rejected, Approved, when pending no need) and not
  //       // notified (isNotified flag == false).
  //       final Map<String, dynamic> responseData = json.decode(response.body);

  //       if (responseData.containsKey('uploadedImages')) {
  //         uploadedImages =
  //             List<Map<String, dynamic>>.from(responseData['uploadedImages']);
  //         print(uploadedImages);
  //       } else {
  //         // Handle the case when 'complaints' key is not present in the response
  //         print('No uploadedImages keyword found in the response');
  //       }
  //     } else if (response.statusCode == 500) {
  //       final Map<String, dynamic> responseData = json.decode(response.body);
  //       // ignore: use_build_context_synchronously
  //       showCustomSnackBar(context, responseData['error'], bottomMargin: 310);
  //     } else {
  //       // ignore: use_build_context_synchronously
  //       showCustomSnackBar(context, 'Error retrieving unnotified uploads',
  //           bottomMargin: 310);
  //     }
  //   } catch (error) {
  //     print('Error fetching unnotified uploads: $error');
  //   }
  // }
}
