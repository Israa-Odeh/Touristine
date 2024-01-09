import 'package:flutter/material.dart';

class DotsBar extends StatelessWidget {
  final int itemCount;
  final int currentIndex;

  const DotsBar({super.key, required this.itemCount, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        return Container(
          margin: const EdgeInsets.all(4),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentIndex == index
                ? const Color(0xFF1E889E)
                : const Color.fromARGB(56, 15, 68, 78),
          ),
        );
      }),
    );
  }
}
