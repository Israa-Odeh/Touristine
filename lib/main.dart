import 'package:touristine/AndroidMobileApp/Launcher/launcher.dart';
import 'package:touristine/WebApplication/Launcher/launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await initializeFirebaseWeb();
  }
  await Firebase.initializeApp();

  kIsWeb ? runApp(const WebAppLauncher()) : runApp(const MobileAppLauncher());
}