import 'package:flutter/material.dart';
import 'package:wheel_picker/wheel_picker.dart';

class TimeWheelPicker extends StatefulWidget {
  final Function(int, int) onTimeChanged;

  const TimeWheelPicker({super.key, required this.onTimeChanged});

  @override
  State<TimeWheelPicker> createState() => _TimeWheelPickerState();
}

class _TimeWheelPickerState extends State<TimeWheelPicker> {
  int selectedHours = 0;
  int selectedMinutes = 0;

  final now = TimeOfDay.now();
  late final hoursWheel = WheelPickerController(
    itemCount: 16,
    initialIndex: 0,
  );
  late final minutesWheel = WheelPickerController(
    itemCount: 60,
    initialIndex: 0,
    mounts: [hoursWheel],
  );

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontSize: 22.0,
      height: 1.5,
      color: Color.fromARGB(170, 0, 0, 0),
    );
    final wheelStyle = WheelPickerStyle(
      height: 40,
      itemExtent: textStyle.fontSize! * textStyle.height!,
      squeeze: 1.25,
      diameterRatio: .8,
      surroundingOpacity: .25,
      magnification: 1.2,
    );

    Widget itemBuilder(BuildContext context, int index) {
      return Text("$index".padLeft(2, '0'), style: textStyle);
    }

    return SizedBox(
      height: 55.0,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _centerBar(context),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              WheelPicker(
                builder: itemBuilder,
                controller: hoursWheel,
                looping: false,
                style: wheelStyle,
                selectedIndexColor: const Color.fromARGB(255, 0, 0, 0),
                onIndexChanged: (index) {
                  setState(() {
                    selectedHours = index;
                    widget.onTimeChanged(selectedHours, selectedMinutes);
                  });
                },
              ),
              const Text(":", style: textStyle),
              WheelPicker(
                builder: itemBuilder,
                controller: minutesWheel,
                style: wheelStyle,
                enableTap: true,
                selectedIndexColor: const Color.fromARGB(255, 0, 0, 0),
                 onIndexChanged: (index) {
                  setState(() {
                    selectedMinutes = index;
                    widget.onTimeChanged(selectedHours, selectedMinutes);
                  });
                },
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    hoursWheel.dispose();
    minutesWheel.dispose();
    super.dispose();
  }

  Widget _centerBar(BuildContext context) {
    return Center(
      child: Container(
        height: 55.0,
        width: 150,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 19, 67, 69).withAlpha(26),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}
