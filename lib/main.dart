import 'package:touristine/AndroidMobileApp/LoginAndRegistration/MainPages/top_outer_screen.dart';
import 'package:touristine/AndroidMobileApp/UserData/user_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyDzAHOWKiZDM97eOAjq4SuECDOFAPZ2YHs",
            appId: "1:889464890314:web:26147ed3501be78f06e533",
            messagingSenderId: "889464890314",
            projectId: "touristine-authentication"));
  }
  await Firebase.initializeApp();

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
