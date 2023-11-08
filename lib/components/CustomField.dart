import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final FaIcon fieldPrefixIcon;
  final bool readOnly;


  const CustomField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.fieldPrefixIcon,
    this.readOnly = false,

  }) : super(key: key);

  @override
  _CustomFieldState createState() => _CustomFieldState();
}

class _CustomFieldState extends State<CustomField> {
  late FocusNode focusNode; // To store which text field is currently in focus.
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
                blurRadius: 2.0,
                offset: Offset(0, 0),
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
          readOnly: widget.readOnly,
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
            fillColor: Color.fromARGB(255, 255, 255, 255),
            filled: true,
            hintText: '',
            hintStyle: const TextStyle(
              color: Color(0xFF37474f), // Set hint text color to #37474f
              fontSize: 20.0,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              widget.fieldPrefixIcon.icon,
              color: const Color(0xFF1E889E),
            ),
            suffixIcon: widget.obscureText
                ? IconButton(
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
                    ),
                  )
                : null,
            labelText: isFocused ? widget.hintText : widget.hintText,
            labelStyle: TextStyle(
              color: isFocused? const Color(0xFF1E889E): const Color(0xFF37474f), // Set label text color
              fontSize: isFocused ? 25 : 20,
              fontWeight: isFocused ? FontWeight.w500: FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
