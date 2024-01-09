import 'package:flutter/material.dart';

class CracksAnalysisPage extends StatefulWidget {
  final String token;

  const CracksAnalysisPage({super.key, required this.token});

  @override
  _CracksAnalysisPageState createState() => _CracksAnalysisPageState();
}

class _CracksAnalysisPageState extends State<CracksAnalysisPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('This will be the Cracks Analysis Page.'),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
