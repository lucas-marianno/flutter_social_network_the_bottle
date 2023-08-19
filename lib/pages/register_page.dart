import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_bottle/components/show_dialog.dart';
import '../components/elevated_button.dart';
import '../components/textfield.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
    required this.onTap,
  });

  final Function()? onTap;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  void register() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) return;
    if (passwordController.text != confirmPasswordController.text) {
      showMyDialog(context, title: 'Nope!', content: 'Passwords don\'t match.');
      return;
    }
    if (passwordController.text.length < 6) {
      showMyDialog(
        context,
        title: 'Weak Passord!',
        content: 'Password must be at least 6 characters long',
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      // creates new user
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      if (context.mounted) Navigator.pop(context);
      // creates user profile
      await FirebaseFirestore.instance.collection('User Profile').doc(emailController.text).set({
        'username': emailController.text.split('@')[0],
        'bio': 'Write about yourself here...',
      });
    } on FirebaseAuthException catch (e) {
      if (context.mounted) Navigator.pop(context);
      showMyDialog(context, content: e.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              const Text(
                'Let\'s create an account for you',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
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
              ),

              const Flexible(child: SizedBox(height: 25)),
              // confirm password texfield
              MyTextField(
                controller: confirmPasswordController,
                hintText: 'Confirm Password',
                obscureText: true,
                onSubmited: register,
                enterKeyPressSubmits: true,
              ),

              const Flexible(child: SizedBox(height: 50)),

              // sign up button
              MyButton(text: 'Sign up', onTap: register),

              const Flexible(child: SizedBox(height: 25)),
              // go to register page
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      'Log in now',
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
