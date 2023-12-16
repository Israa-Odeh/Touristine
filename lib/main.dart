import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touristine/LoginAndRegistration/MainPages/TopOuterScreen.dart';
import 'package:touristine/Profiles/Admin/MainPages/admin.dart';
import 'package:touristine/UserData/userProvider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => UserProvider(
                firstName: "", lastName: "", password: "", imageURL: ""))
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AdminProfile(token: ''),
      ),
    );
  }
}
