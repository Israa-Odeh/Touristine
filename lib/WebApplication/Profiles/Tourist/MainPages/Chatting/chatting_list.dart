import 'package:touristine/WebApplication/Profiles/Tourist/MainPages/Chatting/chat_message.dart';
import 'package:touristine/WebApplication/Profiles/Tourist/ActiveStatus/active_status.dart';
import 'package:touristine/WebApplication/Profiles/Tourist/MainPages/Chatting/chat_page.dart';
import 'package:touristine/WebApplication/Notifications/snack_bar.dart';
import 'package:touristine/WebApplication/UserData/user_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
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
  bool isLoading = true;
  late FocusNode focusNode;
  Color iconColor = Colors.grey;
  List<Map<String, dynamic>> filteredAdmins = [];
  List<Map<String, dynamic>> admins = [];
  late Timer statusUpdateTimer;

  @override
  void initState() {
    super.initState();

    focusNode = FocusNode();
    focusNode.addListener(() {
      setState(() {
        iconColor = focusNode.hasFocus ? const Color(0xFF1E889E) : Colors.grey;
      });
    });

    // Retrieve available admins for chatting.
    getAdminsData();

    // Start a timer to periodically update active status.
    statusUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Update active status for all admins.
      if (mounted) updateAdminsActiveStatus();
    });
  }

  void updateAdminsActiveStatus() async {
    try {
      List<bool> adminsActiveStatus = await getAdminsActiveStatusList(
          admins.map((admin) => admin['email'] as String).toList());

      for (int i = 0; i < admins.length; i++) {
        admins[i]['activeStatus'] =
            adminsActiveStatus.isNotEmpty && adminsActiveStatus.length > i
                ? adminsActiveStatus[i]
                : false;
        // Print the new active status.
        print(
            'Admin ${admins[i]['firstName']} ${admins[i]['lastName']} - Active Status: ${admins[i]['activeStatus']}');
      }

      // Trigger a UI update.
      if (mounted) setState(() {});
    } catch (e) {
      print('Error updating admins active status: $e');
    }
  }

  Future<void> getAdminsData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('https://touristineapp.onrender.com/get-admins-Data');

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
          final Map<String, dynamic> responseData = json.decode(response.body);
          List<Map<String, dynamic>> fetchedAdmins =
              List<Map<String, dynamic>>.from(responseData['admins']);

          // Extract emails from fetchedAdmins.
          List<String> adminsEmails =
              fetchedAdmins.map((admin) => admin['email'] as String).toList();

          // Fetch the active status for each admin by passing the list of emails.
          List<bool> adminsActiveStatus =
              await getAdminsActiveStatusList(adminsEmails);

          // Update the admins map with active status.
          for (int i = 0; i < fetchedAdmins.length; i++) {
            fetchedAdmins[i]['activeStatus'] =
                adminsActiveStatus.isNotEmpty && adminsActiveStatus.length > i
                    ? adminsActiveStatus[i]
                    : false;
          }
          setState(() {
            admins = fetchedAdmins;
            filteredAdmins = List.from(admins);
          });
          print(admins);
        } else if (response.statusCode == 500) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
        } else {
          // ignore: use_build_context_synchronously
          showCustomSnackBar(context, 'Error fetching available admins',
              bottomMargin: 0);
        }
      }
    } catch (error) {
      if (mounted) {
        print('Error fetching admins: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<List<bool>> getAdminsActiveStatusList(
      List<String> adminsEmails) async {
    List<bool> statusList = [];

    for (String email in adminsEmails) {
      bool? status = await getAdminActiveStatus(email);
      statusList.add(status ?? false);
    }
    return statusList;
  }

  void filterAdmins(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredAdmins = List.from(admins);
      } else {
        filteredAdmins = admins.where((admin) {
          final fullName = '${admin['firstName']} ${admin['lastName']}';
          final queryLowerCase = query.toLowerCase();
          return fullName.toLowerCase().contains(queryLowerCase) ||
              admin['firstName'].toLowerCase().contains(queryLowerCase) ||
              admin['lastName'].toLowerCase().contains(queryLowerCase) ||
              fullName.split(' ').every((namePart) =>
                  namePart.toLowerCase().startsWith(queryLowerCase));
        }).toList();
      }
    });
  }

  void openChatWithAdmin(Map<String, dynamic> admin) async {
    // Extract the tourist email from the token.
    Map<String, dynamic> decodedToken = Jwt.parseJwt(widget.token);
    String touristEmail = decodedToken['email'];
    String adminEmail = admin['email'];

    DocumentSnapshot<Map<String, dynamic>> chatDoc =
        await getChat(touristEmail, adminEmail);

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
    } else {
      // Chat doesn't exist, initiate a new chat.
      await createChatDocument(touristEmail, admin);
      print('New chat created.');
    }

    // Navigate to the ChatPage.
    // ignore: use_build_context_synchronously
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          adminName: '${admin['firstName']} ${admin['lastName']}',
          adminEmail: admin['email'],
          adminImage: admin['image'],
          token: widget.token,
        ),
      ),
    );
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getChat(
      String tourist, String admin) async {
    String chatId = getChatId(tourist, admin);
    DocumentSnapshot<Map<String, dynamic>> chatDoc =
        await FirebaseFirestore.instance.collection('chats').doc(chatId).get();

    return chatDoc;
  }

  Future<void> createChatDocument(
      String touristEmail, Map<String, dynamic> admin) async {
    String touristFirstName = context.read<UserProvider>().firstName;
    String touristLastName = context.read<UserProvider>().lastName;

    String adminFirstName = admin['firstName'];
    String adminLastName = admin['lastName'];
    String adminEmail = admin['email'];

    String chatId = getChatId(touristEmail, adminEmail);
    try {
      await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
        'tourist': {
          'email': touristEmail,
          'firstName': touristFirstName,
          'lastName': touristLastName,
        },
        'admin': {
          'email': adminEmail,
          'firstName': adminFirstName,
          'lastName': adminLastName,
        },
        'messages': [], // Initialize with an empty list of messages.
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Chat document created successfully.');
    } catch (e) {
      print('Error creating chat document: $e');
    }
  }

  String getChatId(String user1, String user2) {
    List<String> users = [user1, user2]..sort();
    return "${users[0]}_${users[1]}";
  }

  @override
  void dispose() {
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
              'assets/Images/Profiles/Tourist/homeBackground.jpg',
              fit: BoxFit.fill,
            ),
          ),
          Column(
            children: [
              if (!isLoading) const SizedBox(height: 20),
              if (!isLoading && admins.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.only(right: 20.0, left: 20, bottom: 20),
                  child: TextField(
                    focusNode: focusNode,
                    onChanged: filterAdmins,
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
                    : filteredAdmins.isEmpty
                        ? Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              top: -80,
                              child: Image.asset(
                                'assets/Images/Profiles/Tourist/emptyListTransparent.gif',
                                fit: BoxFit.cover,
                              ),
                            ),
                            const Positioned(
                              top: 350,
                              child: Text(
                                'No chats found',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontFamily: 'Gabriola',
                                  color: Color.fromARGB(255, 23, 99, 114),
                                ),
                              ),
                            ),
                          ],
                        ),
                          )
                        : ListView.builder(
                            itemCount: filteredAdmins.length,
                            itemBuilder: (context, index) {
                              final admin = filteredAdmins[index];
                              final bool isActive =
                                  admin['activeStatus'] ?? false;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0),
                                child: Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  color:
                                      const Color.fromARGB(240, 255, 255, 255),
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
                                              backgroundImage: (admin[
                                                              'image'] !=
                                                          null &&
                                                      admin['image'] != "")
                                                  ? NetworkImage(admin['image'])
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
                                                  '${admin['firstName']} ${admin['lastName']}',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                Text(
                                                  admin['email'],
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
                                            openChatWithAdmin(admin);
                                          },
                                        ),
                                        // Display the active status dot.
                                        Positioned(
                                          top: 4,
                                          right: 15,
                                          child: Container(
                                            width: 12,
                                            height: 12,
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
