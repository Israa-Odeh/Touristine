import 'package:flutter/material.dart';

class DotsBar extends StatelessWidget {
  final int itemCount;
  final int currentIndex;
  final MainAxisAlignment alignment;

  const DotsBar(
      {super.key,
      required this.itemCount,
      required this.currentIndex,
      required this.alignment});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
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
