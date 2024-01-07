import 'Profiles/Tourist/Profile/Sections/Notifications/notification_initializer.dart';
import 'package:touristine/LoginAndRegistration/MainPages/TopOuterScreen.dart';
import 'package:touristine/UserData/userProvider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize Touristine Notification Channel.
  await initializeNotifications();

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
        home: TopOuterScreen(),
      ),
    );
  }
}
