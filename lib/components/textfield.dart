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
      cursorColor: Theme.of(context).colorScheme.onSurface,
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
                  color: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: () => setState(() => isVisible = !isVisible))
            : null,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.onError, width: 4),
        ),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.onError)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }
}
