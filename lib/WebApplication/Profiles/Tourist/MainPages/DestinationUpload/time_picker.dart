import 'package:flutter/material.dart';

class TimeWheelPicker extends StatefulWidget {
  final Function(int, int) onTimeChanged;
  final int initialHours;
  final int initialMins;

  const TimeWheelPicker(
      {super.key,
      required this.onTimeChanged,
      required this.initialHours,
      required this.initialMins});

  @override
  State<TimeWheelPicker> createState() => _TimeWheelPickerState();
}

class _TimeWheelPickerState extends State<TimeWheelPicker> {
  late int selectedHours;
  late int selectedMinutes;

  @override
  void initState() {
    super.initState();
    selectedHours = widget.initialHours;
    selectedMinutes = widget.initialMins;
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontSize: 22.0,
      height: 1.5,
      color: Color.fromARGB(170, 0, 0, 0),
    );

    return SizedBox(
      height: 55.0,
      child: Stack(
        fit: StackFit.expand,
        children: [
          centerBar(context),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 20),
              _buildDigitButton(selectedHours ~/ 10),
              _buildDigitButton(selectedHours % 10),
              const Text(" : ", style: textStyle),
              _buildDigitButton(selectedMinutes ~/ 10),
              _buildDigitButton(selectedMinutes % 10),
              const SizedBox(width: 20),
              SizedBox(
                width: 35,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      // Increment hours count cyclically.
                      selectedHours = (selectedHours + 1) % 17;

                      widget.onTimeChanged(selectedHours, selectedMinutes);
                    });
                  },
                  icon: const Padding(
                    padding: EdgeInsets.only(left: 5.0),
                    child: Icon(Icons.add, size: 20),
                  ),
                  label: const Text(''),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E889E),
                    padding: const EdgeInsets.symmetric(
                      vertical: 18.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              SizedBox(
                width: 35,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      // Decrement hours count cyclically.
                      selectedHours = (selectedHours - 1) % 17;

                      if (selectedHours < 0) {
                        selectedHours += 17;
                      }

                      widget.onTimeChanged(selectedHours, selectedMinutes);
                    });
                  },
                  icon: const Padding(
                    padding: EdgeInsets.only(left: 5.0),
                    child: Icon(Icons.remove, size: 20),
                  ),
                  label: const Text(''),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E889E),
                    padding: const EdgeInsets.symmetric(
                      vertical: 18.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDigitButton(int digit) {
    return Text(
      "$digit",
      style: const TextStyle(
        fontSize: 21.0,
        height: 1.5,
        color: Color.fromARGB(170, 0, 0, 0),
      ),
    );
  }

  Widget centerBar(BuildContext context) {
    return Center(
      child: Container(
        height: 53.0,
        width: 200,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 13, 47, 48).withAlpha(26),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}
