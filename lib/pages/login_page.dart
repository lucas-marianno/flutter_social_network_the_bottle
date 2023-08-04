import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/show_dialog.dart';
import '../components/elevated_button.dart';
import '../components/textfield.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.onTap,
  });

  final Function()? onTap;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showMyDialog(context, title: 'Log in failed!', content: e.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // logo
              const Flexible(
                flex: 2,
                child: FittedBox(
                  child: Icon(Icons.lock),
                ),
              ),
              const Flexible(child: SizedBox(height: 25)),

              // welcome back message
              Flexible(
                child: Text(
                  'Welcome back, you\'ve been missed!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              const Flexible(child: SizedBox(height: 50)),

              // email textfield
              MyTextField(
                controller: emailController,
                hintText: 'Email',
              ),

              const Flexible(child: SizedBox(height: 25)),

              // password texfield
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
                onSubmited: login,
                enterKeyPressSubmits: true,
              ),

              const Flexible(child: SizedBox(height: 50)),

              // sign in button
              MyButton(text: 'Sign in', onTap: login),

              const Flexible(child: SizedBox(height: 25)),
              // go to register page
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Not a member? ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      'Register now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[600],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
