import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class User {
  final String firstName;
  final String lastName;
  final String token;

  User({required this.firstName, required this.lastName, required this.token});
}

class FirebaseStorageExample extends StatelessWidget {
  final User user = User(
    firstName: "John",
    lastName: "Doe",
    token: "userToken125",
  );

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<void> addUser() {
    return usersCollection
        .doc(user.token)
        .set({
          'firstName': user.firstName,
          'lastName': user.lastName,
          'token': user.token,
        })
        .then((value) => print("User added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Firebase Storage Example'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              addUser();
            },
            child: Text('Add User to Firebase'),
          ),
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(FirebaseStorageExample());
}
