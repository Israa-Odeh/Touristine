import 'package:touristine/Profiles/Admin/MainPages/Chatting/chat_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:touristine/Profiles/Admin/MainPages/Chatting/chat_message.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class ChattingList extends StatefulWidget {
  final String token;

  const ChattingList({super.key, required this.token});

  @override
  _ChattingListState createState() => _ChattingListState();
}

class _ChattingListState extends State<ChattingList> {
  bool isLoading = true;
  List<Map<String, dynamic>> tourists = [];

  late FocusNode focusNode;
  Color iconColor = Colors.grey;
  List<Map<String, dynamic>> filteredTourists = [];

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
    getTouristsEmails(adminEmail);
  }

  Future<void> getTouristsEmails(String adminEmail) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('chats')
              .where('admin', isEqualTo: adminEmail)
              .get();

      if (querySnapshot.docs.isEmpty) {
        print('No messages with the specified admin ($adminEmail) exist.');
      } else {
        List<String> touristEmails =
            []; // Create a list to store emails directly
        for (QueryDocumentSnapshot<Map<String, dynamic>> document
            in querySnapshot.docs) {
          String touristEmail = document['tourist'];
          touristEmails.add(touristEmail); // Add email to the list
        }
        setState(() {
          filteredTourists =
              touristEmails.map((email) => {'email': email}).toList();
        });
      }
    } catch (e) {
      print('Error getting tourists with emails: $e');
    }
  }

  Future<void> getTouristsInfo(List<String> touristEmails) async {
    // Replace the URL with your actual backend server endpoint
    final url = Uri.parse('https://touristine.onrender.com/get-tourists-info');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: {
          'touristsEmails': jsonEncode(touristEmails),
        },
      );

      if (response.statusCode == 200) {
        print('Tourist list sent successfully.');
        // You can handle the response from the server here
      } else {
        print(
            'Failed to send tourist list. Status code: ${response.statusCode}');
        // Handle the error accordingly
      }
    } catch (e) {
      print('Error sending tourist list: $e');
      // Handle the error accordingly
    }
  }

  void filterAdmins(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredTourists = List.from(tourists);
      } else {
        filteredTourists = tourists.where((admin) {
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
    String userEmail = decodedToken['email'];
    String adminEmail = admin['email'];

    DocumentSnapshot<Map<String, dynamic>> chatDoc =
        await getChat(userEmail, adminEmail);

    if (chatDoc.exists) {
      // Chat exists, retrieve and print messages
      List<dynamic> messages = chatDoc['messages'];
      print('Chat already exists. Messages:');
      for (var message in messages) {
        ChatMessage chatMessage;
        if (message['image'] != null) {
          // If the message contains an image, create a ChatMessage with the image
          chatMessage = ChatMessage(
            sender:
                message['sender'] ?? '', // Provide a default value if it's null
            message:
                message['image'] ?? '', // Provide a default value if it's null
            date: message['date'] ?? '', // Provide a default value if it's null
            time: message['time'] ?? '', // Provide a default value if it's null
          );
        } else {
          // If the message is text, create a ChatMessage with the text
          chatMessage = ChatMessage(
            sender:
                message['sender'] ?? '', // Provide a default value if it's null
            message: message['message'] ??
                '', // Provide a default value if it's null
            date: message['date'] ?? '', // Provide a default value if it's null
            time: message['time'] ?? '', // Provide a default value if it's null
          );
        }
        print(
            '${chatMessage.sender}: ${chatMessage.message} - Date: ${chatMessage.date}, Time: ${chatMessage.time}');
      }
    } else {
      // Chat doesn't exist, initiate a new chat.
      await createChatDocument(userEmail, adminEmail);
      print('New chat created.');
    }

    // Navigate to the ChatPage passing the admin's name.
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

  Future<void> createChatDocument(String user1, String user2) async {
    String chatId = getChatId(user1, user2);

    try {
      await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
        'tourist': user1,
        'admin': user2,
        'messages': [], // Initialize with an empty list for messages
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
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                child: ListView.builder(
                  itemCount: filteredTourists.length,
                  itemBuilder: (context, index) {
                    final tourist = filteredTourists[index];
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
                                // CircleAvatar(
                                //   radius: 50,
                                //   backgroundImage: NetworkImage(admin['image']),
                                // ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Text(
                                    //   '${tourist['firstName']} ${tourist['lastName']}',
                                    //   style: const TextStyle(
                                    //     fontWeight: FontWeight.bold,
                                    //     fontSize: 20,
                                    //   ),
                                    // ),
                                    const SizedBox(height: 20),
                                    Text(
                                      tourist['email'],
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
                                openChatWithAdmin(tourist);
                              },
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
