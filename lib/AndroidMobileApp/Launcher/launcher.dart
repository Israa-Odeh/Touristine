import 'package:touristine/AndroidMobileApp/LoginAndRegistration/MainPages/top_outer_screen.dart';
import 'package:touristine/AndroidMobileApp/UserData/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class MobileAppLauncher extends StatelessWidget {
  const MobileAppLauncher({super.key});

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
