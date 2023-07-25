import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MyTextField extends StatefulWidget {
  MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String hintText;
  bool obscureText;

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.obscureText ? !isVisible : false,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => isVisible = !isVisible))
            : null,
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 3),
        ),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }
}
