import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decode/jwt_decode.dart';

class ChatPage extends StatefulWidget {
  final String token;
  final String adminName;
  final String adminEmail;
  final String adminImage;

  const ChatPage({
    Key? key,
    required this.adminName,
    required this.adminEmail,
    required this.adminImage,
    required this.token,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  List<Map<String, dynamic>> chatMessages = [];
  ScrollController scrollController = ScrollController();
  late FirebaseFirestore _firestore;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    // Load initial messages from Firebase
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    String chatId =
        getChatId(widget.adminEmail, Jwt.parseJwt(widget.token)['email']);
    DocumentSnapshot chatSnapshot =
        await _firestore.collection('chats').doc(chatId).get();
    List<dynamic> fetchedMessages = (chatSnapshot.data()
            as Map<String, dynamic>?)?['messages'] as List<dynamic> ??
        [];
    List<Map<String, dynamic>> formattedMessages =
        List<Map<String, dynamic>>.from(
      fetchedMessages.map((message) => Map<String, dynamic>.from(message)),
    );
    setState(() {
      chatMessages = formattedMessages;
    });

    // Scroll to the bottom after loading messages
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          backgroundColor: const Color(0xFF1E889E),
          leading: Padding(
            padding: const EdgeInsets.only(top: 15.0, left: 15),
            child: IconButton(
              icon: const FaIcon(FontAwesomeIcons.angleLeft),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.adminImage),
                ),
                const SizedBox(width: 10),
                Text(widget.adminName),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Scrollbar(
              trackVisibility: true,
              controller: scrollController,
              child: ListView.builder(
                controller: scrollController,
                reverse: false, // Set reverse to false
                itemCount: chatMessages.length,
                itemBuilder: (context, index) {
                  return buildMessageItem(index);
                },
              ),
            ),
          ),
          const Divider(
            thickness: 1.5,
          ),
          buildInputField(),
        ],
      ),
    );
  }

  Widget buildInputField() {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0, left: 20.0, bottom: 30.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: const TextStyle(
                fontSize: 20,
              ),
              controller: messageController,
              decoration: const InputDecoration(
                hintText: 'Type your message',
                hintStyle: TextStyle(fontSize: 20),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF1E889E), width: 1.5),
                ),
              ),
              minLines: 1,
              maxLines: 5,
            ),
          ),
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.paperPlane,
              color: Color(0xFF1E889E),
            ),
            onPressed: () {
              sendUserMessage();
            },
          ),
        ],
      ),
    );
  }

  Widget buildMessageItem(int index) {
    String sender = chatMessages[index]['sender'];
    bool isTourist = sender == Jwt.parseJwt(widget.token)['email'];

    return Padding(
      padding: EdgeInsets.only(
          right: isTourist ? 8 : 120,
          left: isTourist ? 120 : 8,
          top: 8.0,
          bottom: 0),
      child: Card(
        color: isTourist
            ? const Color.fromARGB(255, 106, 159, 170)
            : const Color.fromARGB(255, 169, 216, 225),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: ListTile(
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              chatMessages[index]['message'],
              style: TextStyle(
                  fontSize: 20, color: isTourist ? Colors.white : Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  void sendUserMessage() {
    String message = messageController.text;
    if (message.isNotEmpty) {
      messageController.clear();

      // Update the local state with the new message
      setState(() {
        chatMessages.add({
          'sender': Jwt.parseJwt(widget.token)['email'],
          'message': message,
          'date': DateFormat('dd/MM/yyyy').format(DateTime.now().toLocal()),
          'time': DateFormat('HH:mm:ss.SSS').format(DateTime.now().toLocal()),
        });
      });

      // Scroll to the bottom after adding a new message
      Future.delayed(const Duration(milliseconds: 200), () {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      });

      // Store message in Firebase
      storeMessageInFirebase(message);
    }
  }

  Future<void> storeMessageInFirebase(String message) async {
    Map<String, dynamic> decodedToken = Jwt.parseJwt(widget.token);
    String userEmail = decodedToken['email'];
    String chatId = getChatId(widget.adminEmail, userEmail);

    try {
      // Create a reference to the chat document
      DocumentReference chatRef = _firestore.collection('chats').doc(chatId);

      // Update the 'messages' field in the document
      await chatRef.update({
        'messages': FieldValue.arrayUnion([
          {
            'sender': userEmail,
            'message': message,
            'date': DateFormat('dd/MM/yyyy').format(DateTime.now().toLocal()),
            'time': DateFormat('HH:mm:ss.SSS').format(DateTime.now().toLocal()),
          },
        ]),
      });

      print('Message stored in Firebase successfully!');
    } catch (e) {
      print('Error storing message in Firebase: $e');
    }
  }

  String getChatId(String user1, String user2) {
    List<String> users = [user1, user2]..sort();
    return "${users[0]}_${users[1]}";
  }
}
