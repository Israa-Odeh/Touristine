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
  final String senderEmail;

  Message({
    required this.text,
    required this.dateTime,
    required this.senderEmail,
  });

  Map<String, dynamic> toMap() {
    final formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
    final formattedTime = DateFormat('HH:mm:ss.SSSSSS').format(dateTime);

    return {
      'text': text,
      'date': formattedDate,
      'time': formattedTime,
      'senderEmail': senderEmail,
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
      'chats': chats
          .map((receiverEmail, chat) => MapEntry(receiverEmail, chat.toMap())),
    };
  }

  void addChat(String receiverEmail, Chat chat) {
    chats[receiverEmail] = chat;
  }
}

Future<void> addUserToFirebase(User user) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  try {
    final userObject = await usersCollection.doc(user.email).get();

    if (userObject.exists) {
      print('The user document already exists.');
    } else {
      await usersCollection.doc(user.email).set(user.toMap());
      print("The user has been initialized successfully.");
    }
  } catch (error) {
    print("Failed to add/retrieve the user: $error");
  }
}

void addChatToUser(User user, String newReceiverEmail) {
  if (!user.chats.containsKey(newReceiverEmail)) {
    final Chat newChat = Chat(messages: []);
    user.addChat(newReceiverEmail, newChat);
    updateChatListInFirebase(user.email, user.chats);
    print("Chat between $newReceiverEmail and ${user.email} has been added successfully.");
  } else {
    print("Chat already exists between $newReceiverEmail and ${user.email}");
  }
}

Future<void> updateChatListInFirebase(String userEmail, Map<String, Chat> chats) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  try {
    final DocumentReference userDocRef = usersCollection.doc(userEmail);
    final DocumentSnapshot userObject = await userDocRef.get();

    if (userObject.exists) {
      Map<String, dynamic> existingChats = userObject.get('chats');
      // Merge existing chats with the new chats.
      existingChats.addAll(chats.map((receiverEmail, chat) => MapEntry(receiverEmail, chat.toMap())));
      await userDocRef.update({'chats': existingChats});
      print("The chat has been updated successfully.");
    } else {
      print("User not found in Firebase.");
    }
  } catch (error) {
    print("Failed to update the chat list: $error");
  }
}


void sendMessage(User user, String receiverEmail) {
  final Chat chat = user.chats[receiverEmail]!;
  final Message newMessage = Message(
    text: "New message sent at ${DateTime.now()}",
    dateTime: DateTime.now(),
    senderEmail: user.email,
  );
  chat.messages.add(newMessage);
  updateChatInFirebase(user.email, receiverEmail, chat);
}

Future<void> updateChatInFirebase(
    String userEmail, String receiverEmail, Chat chat) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  try {
    final DocumentReference userDocRef = usersCollection.doc(userEmail);
    final DocumentSnapshot userObject = await userDocRef.get();

    if (userObject.exists) {
      Map<String, dynamic> chats = userObject.get('chats');
      chats[receiverEmail] = chat.toMap();

      await userDocRef.update({'chats': chats});
      print("Message added successfully.");
    } else {
      print("User not found in Firebase.");
    }
  } catch (error) {
    print("Failed to update the chat: $error");
  }
}

Future<List<Map<String, dynamic>>> getMessagesBetweenUsers(
    String userEmail, String receiverEmail) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  try {
    final DocumentSnapshot userObject =
        await usersCollection.doc(userEmail).get();

    if (userObject.exists) {
      final Map<String, dynamic> chats = userObject.get('chats');
      if (chats.containsKey(receiverEmail)) {
        final Map<String, dynamic> chatData = chats[receiverEmail];
        final List<dynamic> messagesData = chatData['messages'];

        final List<Map<String, dynamic>> messages = messagesData.map((message) {
          return {
            'text': message['text'].toString(),
            'date': message['date'].toString(),
            'time': message['time'].toString(),
            'senderEmail': message['senderEmail'].toString(),
          };
        }).toList();
        return messages;
      } else {
        print("Chat not found for $receiverEmail");
        return [];
      }
    } else {
      print("User not found in Firebase.");
      return [];
    }
  } catch (error) {
    print("Failed to retrieve messages: $error");
    return [];
  }
}
