import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import '../components/elevated_button.dart';
import '../components/textfield.dart';
import '../firebase/account/login.dart';

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

  login() => loginToAccount(emailController.text, passwordController.text, context);

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
              Flexible(
                flex: 2,
                child: Image.asset(
                  'lib/assets/bottle-icon.png',
                  fit: BoxFit.contain,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Flexible(child: SizedBox(height: 50)),
              // slogan
              SizedBox(
                height: 25,
                child: DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: AnimatedTextKit(
                    pause: Duration.zero,
                    animatedTexts: [
                      RotateAnimatedText(
                        'write your message',
                        duration: const Duration(milliseconds: 1000),
                      ),
                      RotateAnimatedText(
                        'add a picture',
                        duration: const Duration(milliseconds: 1000),
                      ),
                      RotateAnimatedText(
                        'put it in a bottle',
                        duration: const Duration(milliseconds: 1000),
                      ),
                      RotateAnimatedText(
                        'throw it in the ocean',
                        duration: const Duration(milliseconds: 1000),
                      ),
                    ],
                  ),
                ),
              ),
              const Flexible(child: SizedBox(height: 50)),
              // email textfield
              MyTextField(
                controller: emailController,
                hintText: 'Email',
                allLowerCase: true,
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
                  const Text(
                    'Not a member? ',
                    style: TextStyle(
                      fontSize: 16,
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
