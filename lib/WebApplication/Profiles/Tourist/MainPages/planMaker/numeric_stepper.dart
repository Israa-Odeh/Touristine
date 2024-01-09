import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

class NumericStepButton extends StatefulWidget {
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onChanged;

  const NumericStepButton(
      {super.key,
      this.minValue = 1,
      this.maxValue = 100,
      required this.onChanged});

  @override
  State<NumericStepButton> createState() {
    return _NumericStepButtonState();
  }
}

class _NumericStepButtonState extends State<NumericStepButton> {
  static int counter = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: const Color(0xFF1E889E), width: 2.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.minus,
              color: Color(0xFF1E889E),
            ),
            padding: const EdgeInsets.all(8.0),
            iconSize: 24.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              _decrementCounter();
            },
          ),
          Text(
            '$counter',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color.fromARGB(196, 14, 62, 71),
              fontSize: 25.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.plus,
              color: Color(0xFF1E889E),
            ),
            padding: const EdgeInsets.all(8.0),
            iconSize: 24.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              _incrementCounter();
            },
          ),
        ],
      ),
    );
  }

  void _decrementCounter() {
    setState(() {
      if (counter > widget.minValue) {
        counter--;
      }
      widget.onChanged(counter);
    });
  }

  void _incrementCounter() {
    setState(() {
      if (counter < widget.maxValue) {
        counter++;
      }
      widget.onChanged(counter);
    });
  }
}
