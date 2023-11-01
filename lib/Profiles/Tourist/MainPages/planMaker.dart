import 'package:flutter/material.dart';

class PlanMakerPage extends StatefulWidget {
  final String token;

  const PlanMakerPage({super.key, required this.token});

  @override
  _PlanMakerPageState createState() => _PlanMakerPageState();
}

class _PlanMakerPageState extends State<PlanMakerPage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Plan Maker Section'),
    );
  }
}
