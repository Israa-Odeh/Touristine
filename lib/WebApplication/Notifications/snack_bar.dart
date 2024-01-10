import 'package:flutter/material.dart';

// A function to display a notification on a SnackBar.
void showCustomSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(milliseconds: 3000),
  double bottomMargin = 550.0, // Default margin value.
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Center(
        child: Text(
          message,
          style: const TextStyle(fontSize: 22),
        ),
      ),
      backgroundColor: const Color(0xFF1E889E),
      duration: duration,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(bottom: bottomMargin, top: 0),
    ),
  );
}
