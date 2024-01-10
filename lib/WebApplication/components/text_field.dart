import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final FaIcon fieldPrefixIcon;

  const MyTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.obscureText,
      required this.fieldPrefixIcon});

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  late FocusNode focusNode; // To store which textfield is currently in focus.
  bool isPasswordVisible = false;
  bool isFocused = false;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    focusNode.addListener(() {
      setState(() {
        isFocused = focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),

          // Create a shadow effect surrounding the currently selected text field.
          boxShadow: [
            if (isFocused)
              const BoxShadow(
                color: Color(0xFF1E889E),
                blurRadius: 5.0,
                offset: Offset(0, 2),
              ),
          ],
        ),
        child: TextField(
          controller: widget.controller,
          obscureText: widget.obscureText && !isPasswordVisible,
          style: const TextStyle(
            color: Color(0xFF37474f), // Set text color to #37474f
            fontSize: 20.0,
            fontWeight: FontWeight.w400,
          ),
          focusNode: focusNode,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isFocused ? Colors.transparent : const Color(0xFF455a64),
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF1E889E)),
              borderRadius: BorderRadius.circular(10.0),
            ),
            fillColor: const Color(0xFFebebeb),
            filled: true,
            hintText: widget.hintText,
            hintStyle: const TextStyle(
              color: Color(0xFF37474f), // Set hint text color to #37474f
              fontSize: 20.0,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Icon(
                widget.fieldPrefixIcon.icon,
                size: 20,
                color: const Color(0xFF1E889E),
              ),
            ),
            suffixIcon: widget.obscureText
                ? Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: IconButton(
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                      icon: FaIcon(
                        isPasswordVisible
                            ? FontAwesomeIcons.eye
                            : FontAwesomeIcons.eyeSlash,
                        color: const Color(0xFF1E889E),
                        size: 20,
                      ),
                    ),
                )
                : null,
          ),
        ),
      ),
    );
  }
}
