import 'package:flutter/material.dart';

class CracksMapViewer extends StatefulWidget {
  final String token;

  const CracksMapViewer({super.key, required this.token});

  @override
  _CracksMapViewerState createState() => _CracksMapViewerState();
}

class _CracksMapViewerState extends State<CracksMapViewer> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'This is the Cracks Map Viewer page!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
