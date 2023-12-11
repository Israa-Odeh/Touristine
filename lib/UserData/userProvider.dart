import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String firstName;
  String lastName;
  String password;
  String? imageURL;

  UserProvider({
    required this.firstName,
    required this.lastName,
    required this.password,
    this.imageURL,
  });

  void updateData({
    required String newFirstName,
    required String newLastName,
    required String newPassword,
  }) {
    firstName = newFirstName;
    lastName = newLastName;
    password = newPassword;
    print("--------------------------------" + firstName);
    print("--------------------------------" + lastName);
    print("--------------------------------" + password);

    notifyListeners();
  }

  void updateImage({
    String? newImageURL,
  }) {
    if (newImageURL != null && newImageURL != "") {
      imageURL = newImageURL;
      print("--------------------------------" + imageURL!);
      notifyListeners();
    } 
    else {
      imageURL = "";
      print("Received a null newImageURL");
    }
  }
}
