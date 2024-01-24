import 'package:touristine/WebApplication/Profiles/Tourist/MainPages/Chatting/chat_message.dart';
import 'package:touristine/WebApplication/Profiles/Coordinator/MainPages/Chatting/chat_page.dart';
import 'package:touristine/WebApplication/Profiles/Coordinator/ActiveStatus/active_status.dart';
import 'package:touristine/WebApplication/Notifications/snack_bar.dart';
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
  List<Map<String, dynamic>> filteredTourists = [];
  List<Map<String, dynamic>> tourists = [];
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
    getTouristsEmails(adminEmail);

    // Start a timer to periodically update active status.
    statusUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Update active status for all tourists.
      if (mounted) updateTouristsActiveStatus();
    });
  }

  Future<void> getTouristsEmails(String adminEmail) async {
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
        List<String> touristEmails = [];
        for (QueryDocumentSnapshot<Map<String, dynamic>> document
            in querySnapshot.docs) {
          Map<String, dynamic> touristData = document['tourist'];
          String touristEmail = touristData['email'];
          touristEmails.add(touristEmail);
        }
        print(touristEmails);
        await getTouristsInfo(touristEmails);
      }
    } catch (e) {
      print('Error getting tourists with emails: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> getTouristsInfo(List<String> touristEmails) async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('https://touristineapp.onrender.com/get-tourists-info');

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
        List<Map<String, dynamic>> fetchedTourists =
            List<Map<String, dynamic>>.from(
          jsonDecode(response.body)['tourists'],
        );

        // Fetch the active status for each tourist.
        List<bool> touristsActiveStatus =
            await getTouristsActiveStatusList(touristEmails);

        // Update the tourists map with active status.
        for (int i = 0; i < fetchedTourists.length; i++) {
          fetchedTourists[i]['activeStatus'] =
              touristsActiveStatus.isNotEmpty && touristsActiveStatus.length > i
                  ? touristsActiveStatus[i]
                  : false;
        }
        setState(() {
          tourists = fetchedTourists;
          filteredTourists = List.from(tourists);
        });
        print(tourists);
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // ignore: use_build_context_synchronously
        showCustomSnackBar(context, responseData['error'], bottomMargin: 0);
      }
    } catch (e) {
      print('Error fetching tourist list: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<List<bool>> getTouristsActiveStatusList(
      List<String> touristsEmails) async {
    List<bool> statusList = [];

    for (String email in touristsEmails) {
      bool? status = await getTouristActiveStatus(email);
      statusList.add(status ?? false);
    }
    return statusList;
  }

  void updateTouristsActiveStatus() async {
    try {
      List<bool> touristsActiveStatus = await getTouristsActiveStatusList(
          tourists.map((tourist) => tourist['email'] as String).toList());

      for (int i = 0; i < tourists.length; i++) {
        tourists[i]['activeStatus'] =
            touristsActiveStatus.isNotEmpty && touristsActiveStatus.length > i
                ? touristsActiveStatus[i]
                : false;
        // Print the new active status.
        print(
            'Tourist ${tourists[i]['firstName']} ${tourists[i]['lastName']} - Active Status: ${tourists[i]['activeStatus']}');
      }

      // Trigger a UI update.
      if (mounted) setState(() {});
    } catch (e) {
      print('Error updating tourists active status: $e');
    }
  }

  void filterTourists(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredTourists = List.from(tourists);
      } else {
        filteredTourists = tourists.where((tourist) {
          final fullName = '${tourist['firstName']} ${tourist['lastName']}';
          final queryLowerCase = query.toLowerCase();
          return fullName.toLowerCase().contains(queryLowerCase) ||
              tourist['firstName'].toLowerCase().contains(queryLowerCase) ||
              tourist['lastName'].toLowerCase().contains(queryLowerCase) ||
              fullName.split(' ').every((namePart) =>
                  namePart.toLowerCase().startsWith(queryLowerCase));
        }).toList();
      }
    });
  }

  void openChatWithTourist(Map<String, dynamic> tourist) async {
    // Extract the admin email from the token.
    Map<String, dynamic> decodedToken = Jwt.parseJwt(widget.token);
    String adminEmail = decodedToken['email'];
    String touristEmail = tourist['email'];

    DocumentSnapshot<Map<String, dynamic>> chatDoc =
        await getChat(adminEmail, touristEmail);

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
            touristName: '${tourist['firstName']} ${tourist['lastName']}',
            touristEmail: tourist['email'],
            touristImage: tourist['image'],
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
      String adminEmail, String touristEmail) async {
    String chatId = getChatId(adminEmail, touristEmail);
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
              fit: BoxFit.fill,
            ),
          ),
          Column(
            children: [
              if (!isLoading) const SizedBox(height: 40),
              if (!isLoading && tourists.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.only(right: 20.0, left: 20, bottom: 20),
                  child: TextField(
                    focusNode: focusNode,
                    onChanged: filterTourists,
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
                    : filteredTourists.isEmpty
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
                            itemCount: filteredTourists.length,
                            itemBuilder: (context, index) {
                              final tourist = filteredTourists[index];
                              final bool isActive =
                                  tourist['activeStatus'] ?? false;
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
                                              backgroundImage: (tourist[
                                                              'image'] !=
                                                          null &&
                                                      tourist['image'] != "")
                                                  ? NetworkImage(
                                                      tourist['image'])
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
                                                  '${tourist['firstName']} ${tourist['lastName']}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
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
                                            openChatWithTourist(tourist);
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
