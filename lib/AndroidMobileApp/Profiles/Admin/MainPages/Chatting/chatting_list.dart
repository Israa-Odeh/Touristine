import 'package:touristine/AndroidMobileApp/Profiles/Tourist/MainPages/Chatting/chat_message.dart';
import 'package:touristine/AndroidMobileApp/Profiles/Admin/MainPages/Chatting/chat_page.dart';
import 'package:touristine/AndroidMobileApp/Profiles/Admin/ActiveStatus/active_status.dart';
import 'package:touristine/AndroidMobileApp/Notifications/snack_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';

class ChattingList extends StatefulWidget {
  final String token;

  const ChattingList({super.key, required this.token});

  @override
  _ChattingListState createState() => _ChattingListState();
}

class _ChattingListState extends State<ChattingList> {
  List<Map<String, dynamic>> filteredCoordinators = [];
  List<Map<String, dynamic>> coordinators = [];
  Color iconColor = Colors.grey;
  late Timer statusUpdateTimer;
  late FocusNode focusNode;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    focusNode = FocusNode();
    focusNode.addListener(() {
      setState(() {
        iconColor = focusNode.hasFocus ? const Color(0xFF1E889E) : Colors.grey;
      });
    });

    Map<String, dynamic> decodedToken = Jwt.parseJwt(widget.token);
    String adminEmail = decodedToken['email'];
    getCoordinatorsEmails(adminEmail);

    // Start a timer to periodically update active status.
    statusUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Update active status for all coordinators.
      if (mounted) updateCoordinatorsActiveStatus();
    });
  }

  Future<void> getCoordinatorsEmails(String adminEmail) async {
    try {
      if (!mounted) return;

      setState(() {
        isLoading = true;
      });

      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('chats')
              .where('admin.email', isEqualTo: adminEmail)
              .where('messages', isGreaterThan: []).get();

      if (querySnapshot.docs.isEmpty) {
        print('No messages with the specified admin ($adminEmail) exist.');
      } else {
        List<String> coordinatorsEmails = [];
        for (QueryDocumentSnapshot<Map<String, dynamic>> document
            in querySnapshot.docs) {
          Map<String, dynamic> coordinatorData = document['tourist'];
          String coordinatorEmail = coordinatorData['email'];
          coordinatorsEmails.add(coordinatorEmail);
        }
        print(coordinatorsEmails);
        await getCoordinatorsInfo(coordinatorsEmails);
      }
    } catch (e) {
      print('Error getting coordinators with emails: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> getCoordinatorsInfo(List<String> coordinatorsEmails) async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    final url =
        Uri.parse('https://touristineapp.onrender.com/get-coordinators-info');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {
          'tcoordinatorsEmails': jsonEncode(coordinatorsEmails),
        },
      );

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> fetchedCoordinators =
            List<Map<String, dynamic>>.from(
          jsonDecode(response.body)['coordinators'],
        );

        // Fetch the active status for each coordinator.
        List<bool> coordinatorsActiveStatus =
            await getCoordinatorsActiveStatusList(coordinatorsEmails);

        // Update the coordinators map with active status.
        for (int i = 0; i < fetchedCoordinators.length; i++) {
          fetchedCoordinators[i]['activeStatus'] =
              coordinatorsActiveStatus.isNotEmpty && coordinatorsActiveStatus.length > i
                  ? coordinatorsActiveStatus[i]
                  : false;
        }
        setState(() {
          coordinators = fetchedCoordinators;
          filteredCoordinators = List.from(coordinators);
        });
        print(coordinators);
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
      }
    } catch (e) {
      print('Error fetching coordinators list: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<List<bool>> getCoordinatorsActiveStatusList(
      List<String> coordinatorsEmails) async {
    List<bool> statusList = [];

    for (String email in coordinatorsEmails) {
      bool? status = await getCoordinatorActiveStatus(email);
      statusList.add(status ?? false);
    }
    return statusList;
  }

  void updateCoordinatorsActiveStatus() async {
    try {
      List<bool> coordinatorsActiveStatus =
          await getCoordinatorsActiveStatusList(coordinators
              .map((coordinator) => coordinator['email'] as String)
              .toList());

      for (int i = 0; i < coordinators.length; i++) {
        coordinators[i]['activeStatus'] = coordinatorsActiveStatus.isNotEmpty &&
                coordinatorsActiveStatus.length > i
            ? coordinatorsActiveStatus[i]
            : false;
        // Print the new active status.
        print(
            'Coordinator ${coordinators[i]['firstName']} ${coordinators[i]['lastName']} - Active Status: ${coordinators[i]['activeStatus']}');
      }

      // Trigger a UI update.
      if (mounted) setState(() {});
    } catch (e) {
      print('Error updating coordinators active status: $e');
    }
  }

  void filterCoordinators(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCoordinators = List.from(coordinators);
      } else {
        filteredCoordinators = coordinators.where((coordinator) {
          final fullName =
              '${coordinator['firstName']} ${coordinator['lastName']}';
          final queryLowerCase = query.toLowerCase();
          return fullName.toLowerCase().contains(queryLowerCase) ||
              coordinator['firstName'].toLowerCase().contains(queryLowerCase) ||
              coordinator['lastName'].toLowerCase().contains(queryLowerCase) ||
              fullName.split(' ').every((namePart) =>
                  namePart.toLowerCase().startsWith(queryLowerCase));
        }).toList();
      }
    });
  }

  void openChatWithCoordinator(Map<String, dynamic> coordinator) async {
    // Extract the admin email from the token.
    Map<String, dynamic> decodedToken = Jwt.parseJwt(widget.token);
    String adminEmail = decodedToken['email'];
    String coordinatorEmail = coordinator['email'];

    DocumentSnapshot<Map<String, dynamic>> chatDoc =
        await getChat(adminEmail, coordinatorEmail);

    if (chatDoc.exists) {
      // Chat exists, retrieve and print messages.
      List<dynamic> messages = chatDoc['messages'];
      print('Chat already exists. Messages:');
      for (var message in messages) {
        ChatMessage chatMessage;
        if (message['imageUrl'] != null) {
          // If the message contains an image, create a ChatMessage with the image.
          chatMessage = ChatMessage(
            sender: message['sender'] ?? '',
            message: message['imageUrl'] ?? '',
            date: message['date'] ?? '',
            time: message['time'] ?? '',
          );
        } else {
          // If the message is text, create a ChatMessage with the text.
          chatMessage = ChatMessage(
            sender: message['sender'] ?? '',
            message: message['message'] ?? '',
            date: message['date'] ?? '',
            time: message['time'] ?? '',
          );
        }
        print(
            '${chatMessage.sender}: ${chatMessage.message} - Date: ${chatMessage.date}, Time: ${chatMessage.time}');
      }
      // Navigate to the ChatPage.
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            coordinatorName:
                '${coordinator['firstName']} ${coordinator['lastName']}',
            coordinatorEmail: coordinator['email'],
            coordinatorImage: coordinator['image'],
            token: widget.token,
          ),
        ),
      );
    } else {
      // Chat doesn't exist.
      print('Chat does not exist.');
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getChat(
      String adminEmail, String coordinatorEmail) async {
    String chatId = getChatId(adminEmail, coordinatorEmail);
    DocumentSnapshot<Map<String, dynamic>> chatDoc =
        await FirebaseFirestore.instance.collection('chats').doc(chatId).get();

    return chatDoc;
  }

  String getChatId(String user1, String user2) {
    List<String> users = [user1, user2]..sort();
    return "${users[0]}_${users[1]}";
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed.
    statusUpdateTimer.cancel();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/Images/Profiles/Admin/mainBackground.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              if (!isLoading) const SizedBox(height: 40),
              if (!isLoading && coordinators.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    focusNode: focusNode,
                    onChanged: filterCoordinators,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(
                        FontAwesomeIcons.magnifyingGlass,
                        color: iconColor,
                      ),
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF1E889E)),
                      ),
                    ),
                    style: const TextStyle(
                      color: Color.fromARGB(255, 20, 92, 107),
                    ),
                  ),
                ),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF1E889E)),
                        ),
                      )
                    : filteredCoordinators.isEmpty
                        ? SingleChildScrollView(
                            child: Center(
                              child: Column(
                                children: [
                                  const SizedBox(height: 110),
                                  Image.asset(
                                    'assets/Images/Profiles/Tourist/emptyListTransparent.gif',
                                    fit: BoxFit.cover,
                                  ),
                                  const Text(
                                    'No chats found',
                                    style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Gabriola',
                                      color: Color.fromARGB(255, 23, 99, 114),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredCoordinators.length,
                            itemBuilder: (context, index) {
                              final coordinator = filteredCoordinators[index];
                              final bool isActive =
                                  coordinator['activeStatus'] ?? false;
                              return Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: const Color.fromARGB(240, 255, 255, 255),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Colors.white,
                                            radius: 50,
                                            backgroundImage: (coordinator[
                                                            'image'] !=
                                                        null &&
                                                    coordinator['image'] != "")
                                                ? NetworkImage(
                                                    coordinator['image'])
                                                : const AssetImage(
                                                        "assets/Images/Profiles/Tourist/DefaultProfileImage.png")
                                                    as ImageProvider<Object>?,
                                          ),
                                          const SizedBox(width: 16),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${coordinator['firstName']} ${coordinator['lastName']}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              Text(
                                                coordinator['email'],
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        icon: const FaIcon(
                                          FontAwesomeIcons.facebookMessenger,
                                          color: Color.fromARGB(255, 0, 0, 0),
                                        ),
                                        onPressed: () {
                                          openChatWithCoordinator(coordinator);
                                        },
                                      ),
                                      // Display the active status dot.
                                      Positioned(
                                        top: 4,
                                        right: 16,
                                        child: Container(
                                          width: 15,
                                          height: 15,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isActive
                                                ? const Color.fromARGB(
                                                    170, 76, 175, 79)
                                                : const Color.fromARGB(
                                                    174, 244, 67, 54),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
