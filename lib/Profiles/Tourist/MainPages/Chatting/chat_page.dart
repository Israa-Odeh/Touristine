import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
  late FirebaseStorage _storage;
  late ImagePicker _imagePicker;
  StreamSubscription<DocumentSnapshot>? chatSubscription;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    _storage = FirebaseStorage.instance;
    _imagePicker = ImagePicker();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    String chatId =
        getChatId(widget.adminEmail, Jwt.parseJwt(widget.token)['email']);
    DocumentReference chatRef = _firestore.collection('chats').doc(chatId);

    chatSubscription = chatRef.snapshots().listen((chatSnapshot) {
      List<dynamic>? fetchedMessages = (chatSnapshot.data()
          as Map<String, dynamic>?)?['messages'] as List<dynamic>?;

      if (fetchedMessages != null) {
        List<Map<String, dynamic>> formattedMessages =
            List<Map<String, dynamic>>.from(
          fetchedMessages.map((message) => Map<String, dynamic>.from(message)),
        );
        setState(() {
          chatMessages = formattedMessages;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 300), () {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
          });
        });
      }
    });
  }

  @override
  void dispose() {
    chatSubscription?.cancel();
    super.dispose();
  }

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
                reverse: false,
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
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, left: 12),
          child: IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.image,
              color: Color(0xFF1E889E),
            ),
            onPressed: () {
              pickAndUploadImage();
            },
          ),
        ),
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.only(right: 10.0, left: 10.0, bottom: 30.0),
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
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, right: 12),
          child: IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.paperPlane,
              color: Color(0xFF1E889E),
            ),
            onPressed: () {
              sendUserMessage();
            },
          ),
        ),
      ],
    );
  }

  void pickAndUploadImage() async {
    try {
      final XFile? pickedFile =
          await _imagePicker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);

        String imageUrl = await uploadImage(imageFile);

        sendUserMessage(imageUrl);
      }
    } catch (e) {
      print('Error picking or uploading image: $e');
    }
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference =
          _storage.ref().child('chat_images/$fileName.jpg');
      UploadTask uploadTask = storageReference.putFile(imageFile);

      await uploadTask.whenComplete(() => null);

      String imageUrl = await storageReference.getDownloadURL();

      print('Image uploaded successfully. URL: $imageUrl');

      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw e;
    }
  }

  void sendUserMessage([String? imageUrl]) {
    String message = messageController.text;
    if (message.isNotEmpty || imageUrl != null) {
      messageController.clear();

      setState(() {
        chatMessages.add({
          'sender': Jwt.parseJwt(widget.token)['email'],
          'message': message,
          'imageUrl': imageUrl,
          'date': DateFormat('dd/MM/yyyy').format(DateTime.now().toLocal()),
          'time': DateFormat('HH:mm:ss.SSS').format(DateTime.now().toLocal()),
        });
      });

      Future.delayed(const Duration(milliseconds: 200), () {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      });

      storeMessageInFirebase(message, imageUrl);
    }
  }

  Future<void> storeMessageInFirebase(String message, String? imageUrl) async {
    Map<String, dynamic> decodedToken = Jwt.parseJwt(widget.token);
    String userEmail = decodedToken['email'];
    String chatId = getChatId(widget.adminEmail, userEmail);

    try {
      DocumentReference chatRef = _firestore.collection('chats').doc(chatId);

      await chatRef.update({
        'messages': FieldValue.arrayUnion([
          {
            'sender': userEmail,
            'message': message,
            'imageUrl': imageUrl,
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

  Widget buildMessageItem(int index) {
    String sender = chatMessages[index]['sender'];
    bool isTourist = sender == Jwt.parseJwt(widget.token)['email'];

    if (chatMessages[index]['imageUrl'] != null) {
      return Padding(
        padding: EdgeInsets.only(
          right: isTourist ? 8 : 120,
          left: isTourist ? 120 : 8,
          top: 8.0,
          bottom: 0,
        ),
        child: InkWell(
          onTap: () {
            showImageDialog(chatMessages[index]['imageUrl']);
          },
          child: SizedBox(
            height: 200,
            width: 500,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Image.network(
                chatMessages[index]['imageUrl'],
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(
          right: isTourist ? 8 : 120,
          left: isTourist ? 120 : 8,
          top: 8.0,
          bottom: 0,
        ),
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
                  fontSize: 20,
                  color: isTourist ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  void showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Stack(
            children: [
              SizedBox(
                width: 500,
                height: 500,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.fill,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 251, 251, 251)
                            .withOpacity(0.5),
                        spreadRadius: -5,
                        blurRadius: 0,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const FaIcon(FontAwesomeIcons.xmark),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
