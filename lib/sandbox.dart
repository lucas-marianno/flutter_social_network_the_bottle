import 'package:flutter/material.dart';
import 'package:the_wall/pages/profile_page.dart';

class Sandbox extends StatelessWidget {
  const Sandbox({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfilePage(userEmail: 'lucas.marianno94@gmail.com');
  }
}
