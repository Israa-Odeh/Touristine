import 'package:flutter/material.dart';
import 'package:touristine/LoginAndRegistration/landingPage.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // Calculate the font size based on screen height
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LandingPage(),
    );
}
}