import 'package:touristine/WebApplication/LoginAndRegistration/MainPages/top_outer_screen.dart';
import 'package:touristine/WebApplication/UserData/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class WebAppLauncher extends StatelessWidget {
  const WebAppLauncher({super.key});

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
        home: TopOuterScreen(),
      ),
    );
  }
}
