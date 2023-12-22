import 'package:flutter/material.dart';

class SuggestedPlacesPage extends StatefulWidget {
  final String token;

  const SuggestedPlacesPage({super.key, required this.token});

  @override
  _SuggestedPlacesPageState createState() => _SuggestedPlacesPageState();
}

class _SuggestedPlacesPageState extends State<SuggestedPlacesPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('This will be the users suggested places page.'),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
