import 'package:flutter/material.dart';

class ImagesUploadPage extends StatefulWidget {
  final String token;

  const ImagesUploadPage({super.key, required this.token});

  @override
  _ImagesUploadPageState createState() => _ImagesUploadPageState();
}

class _ImagesUploadPageState extends State<ImagesUploadPage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Images Upload Section'),
    );
  }
}
