import 'package:flutter/material.dart';

class ChattingPage extends StatefulWidget {
  final String token;

  const ChattingPage({super.key, required this.token});

  @override
  _ChattingPageState createState() => _ChattingPageState();
}

class _ChattingPageState extends State<ChattingPage> {
  // You can add variables and methods here for your stateful widget
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Chatting with admins Section'),
    );
  }
}
