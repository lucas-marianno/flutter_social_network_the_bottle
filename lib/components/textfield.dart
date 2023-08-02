import 'package:flutter/material.dart';
import 'package:the_wall/settings.dart';

class MyTextField extends StatefulWidget {
  const MyTextField({
    super.key,
    this.controller,
    this.hintText,
    this.onSubmited,
    this.obscureText = false,
    this.autofocus = true,
    this.enterKeyPressSubmits = false,
  });
  final TextEditingController? controller;
  final String? hintText;
  final void Function()? onSubmited;
  final bool obscureText;
  final bool autofocus;
  final bool enterKeyPressSubmits;

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    bool enterKeyPressSubmits = widget.enterKeyPressSubmits || configEnterSendsPost;

    return TextField(
      autofocus: widget.autofocus,
      controller: widget.controller,
      obscureText: widget.obscureText ? !isVisible : false,
      onSubmitted: enterKeyPressSubmits ? (value) => widget.onSubmited?.call() : null,
      textInputAction: enterKeyPressSubmits ? null : TextInputAction.none,
      maxLines: widget.obscureText || enterKeyPressSubmits ? 1 : null,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => isVisible = !isVisible))
            : null,
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 4),
        ),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }
}
