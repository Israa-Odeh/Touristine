import 'package:touristine/WebApplication/Launcher/firebase_initializer.dart';
import 'package:touristine/AndroidMobileApp/Launcher/launcher.dart';
import 'package:touristine/WebApplication/Launcher/launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await initializeFirebaseWeb();
  } else {
    await Firebase.initializeApp();
  }

  kIsWeb ? runApp(const WebAppLauncher()) : runApp(const MobileAppLauncher());
}
