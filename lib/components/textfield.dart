import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  const MyTextField({
    super.key,
    this.controller,
    this.hintText,
    this.onSubmited,
    this.onChanged,
    this.obscureText = false,
    this.autofocus = true,
    this.enterKeyPressSubmits = false,
    this.allLowerCase = false,
    this.maxLength,
  });
  final TextEditingController? controller;
  final String? hintText;
  final void Function()? onSubmited;
  final void Function()? onChanged;
  final bool obscureText;
  final bool autofocus;
  final bool enterKeyPressSubmits;
  final bool allLowerCase;
  final int? maxLength;

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool isVisible = false;
  int? maxLength;
  bool enterSendsPost = false;

  getSettings() async {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    enterSendsPost =
        (await FirebaseFirestore.instance.collection('User Settings').doc(currentUserEmail).get())
                .data()?['enterSendsPost'] ??
            false;
    // setState(() {});
  }

  @override
  void initState() {
    getSettings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool enterKeyPressSubmits = widget.enterKeyPressSubmits || enterSendsPost;

    return TextField(
      autofocus: widget.autofocus,
      controller: widget.controller,
      obscureText: widget.obscureText ? !isVisible : false,
      maxLength: maxLength,
      autocorrect: !widget.obscureText,
      onChanged: (value) {
        if (widget.allLowerCase) {
          widget.controller?.value = widget.controller!.value.copyWith(text: value.toLowerCase());
        }
        if (widget.maxLength != null && widget.controller!.text.length > widget.maxLength! / 2) {
          maxLength = widget.maxLength;
        } else {
          maxLength = null;
        }
        widget.onChanged?.call();
        setState(() {});
      },
      onSubmitted: enterKeyPressSubmits ? (value) => widget.onSubmited?.call() : null,
      textInputAction: enterKeyPressSubmits ? null : TextInputAction.none,
      maxLines: widget.obscureText ? 1 : null,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () => setState(() => isVisible = !isVisible))
            : null,
        focusedBorder: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(),
        filled: true,
      ),
    );
  }
}
