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
    print(
        "Chat between $newReceiverEmail and ${user.email} has been added successfully.");
  } else {
    print("Chat already exists between $newReceiverEmail and ${user.email}");
  }
}

Future<void> updateChatListInFirebase(
    String userEmail, Map<String, Chat> chats) async {
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
      existingChats.addAll(chats
          .map((receiverEmail, chat) => MapEntry(receiverEmail, chat.toMap())));
      await userDocRef.update({'chats': existingChats});
      print("The chat has been updated successfully.");
    } else {
      print("User not found in Firebase.");
    }
  } catch (error) {
    print("Failed to update the chat list: $error");
  }
}

void sendMessage(User user, String receiverEmail, String message) {
  final Chat? existingChat = user.chats[receiverEmail];

  if (existingChat != null) {
    // Chat already exists, add a new message
    final Message newMessage = Message(
      text: message,
      dateTime: DateTime.now(),
      senderEmail: user.email,
    );
    existingChat.messages.add(newMessage);

    // Update the chat in Firebase
    updateChatInFirebase(user.email, receiverEmail, existingChat);
  } else {
    // Chat does not exist, create a new Chat with the initial message
    final Chat newChat = Chat(messages: []);
    final Message initialMessage = Message(
      text: message,
      dateTime: DateTime.now(),
      senderEmail: user.email,
    );
    newChat.messages.add(initialMessage);

    // Update the chat in Firebase
    updateChatInFirebase(user.email, receiverEmail, newChat);

    // Optionally, you can also update the local user object
    user.addChat(receiverEmail, newChat);
  }
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
      final Map<String, dynamic>? existingChatData = chats[receiverEmail];

      if (existingChatData != null) {
        // If the chat exists, merge new messages with existing ones
        List<dynamic> existingMessagesData = existingChatData['messages'];
        List<Map<String, dynamic>> existingMessages =
            List.from(existingMessagesData);

        // Append new messages to existing messages
        existingMessages
            .addAll(chat.messages.map((message) => message.toMap()));

        // Update the chat in Firebase
        chats[receiverEmail]['messages'] = existingMessages;
        await userDocRef.update({'chats': chats});
      } else {
        // If the chat does not exist, create a new entry with new messages
        chats[receiverEmail] = chat.toMap();
        await userDocRef.update({'chats': chats});
      }

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
