import 'package:firebase_core/firebase_core.dart';

Future<void> initializeFirebaseWeb() async {
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: "AIzaSyDzAHOWKiZDM97eOAjq4SuECDOFAPZ2YHs",
    appId: "1:889464890314:web:26147ed3501be78f06e533",
    messagingSenderId: "889464890314",
    projectId: "touristine-authentication",
    storageBucket: "touristine-authentication.appspot.com",
  ));
}
