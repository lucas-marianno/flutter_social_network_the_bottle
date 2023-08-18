import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/auth/login_or_register.dart';
import 'package:the_wall/sandbox.dart';
import 'package:the_wall/settings.dart';
import '../pages/home_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // user is logged in
          if (snapshot.hasData) {
            UserConfig().init();
            if (sandboxEnabled) {
              return const Sandbox();
            }
            return const HomePage();
          }
          // user is not logged in
          return const LoginOrRegister();
        },
      ),
    );
  }
}
