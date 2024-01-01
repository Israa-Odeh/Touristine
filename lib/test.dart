import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';

class Chat {
  final List<Message> messages;

  Chat({
    required this.messages,
  });

  Map<String, dynamic> toMap() {
    return {
      'messages': messages.map((message) => message.toMap()).toList(),
    };
  }
}

class Message {
  final String text;
  final DateTime dateTime;

  Message({
    required this.text,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    final formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
    final formattedTime = DateFormat('HH:mm').format(dateTime);

    return {
      'text': text,
      'date': formattedDate,
      'time': formattedTime,
    };
  }
}

class User {
  final String email;
  final String firstName;
  final String lastName;
  final String imagePath;
  final Map<String, Chat> chats;

  User({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.imagePath,
    required this.chats,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'imagePath': imagePath,
      'chats': chats.map((receiverEmail, chat) =>
          MapEntry(receiverEmail, chat.toMap())),
    };
  }
}

Future<void> addUserToFirebase(User user) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  try {
    await usersCollection.doc(user.email).set(user.toMap());
    print("User added");
  } catch (error) {
    print("Failed to add user: $error");
  }
}

class MyApp extends StatelessWidget {
  final User user;

  MyApp({
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Firebase Storage Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  addUserToFirebase(user);
                },
                child: Text('Add User to Firebase'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  sendMessage(user);
                },
                child: Text('Send Message'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void sendMessage(User user) {
    // Get the chat with the specified receiver email
    final Chat chat = user.chats["receiver1@example.com"]!;

    // Add a new message to the chat
    final Message newMessage = Message(
      text: "New message sent at ${DateTime.now()}",
      dateTime: DateTime.now(),
    );

    chat.messages.add(newMessage);

    // Update the user in Firebase with the modified chat
    addUserToFirebase(user);
  }
}

void main() {
  final User user = User(
    email: "john.doe@example.com",
    firstName: "John",
    lastName: "Doe",
    imagePath: "path/to/image.jpg",
    chats: {
      "receiver1@example.com": Chat(
        messages: [
          Message(text: "Hello Receiver 1!", dateTime: DateTime.now()),
          Message(text: "How are you?", dateTime: DateTime.now()),
          Message(text: "Good to see you!", dateTime: DateTime.now()),
        ],
      ),
      "receiver2@example.com": Chat(
        messages: [
          Message(text: "Hello Receiver 2!", dateTime: DateTime.now()),
          Message(text: "How are you?", dateTime: DateTime.now()),
          Message(text: "Good to see you!", dateTime: DateTime.now()),
        ],
      ),
      // Add more entries if needed
    },
  );

  runApp(MyApp(user: user));
}
