import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/components/username.dart';

class MessageBaloon extends StatelessWidget {
  const MessageBaloon({
    super.key,
    required this.text,
    required this.timestamp,
    required this.sender,
  });

  final String text;
  final String timestamp;
  final String sender;

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isIncoming = sender != currentUser!.email;
    return Align(
      alignment: isIncoming ? Alignment.topLeft : Alignment.topRight,
      child: FractionallySizedBox(
        widthFactor: 0.9,
        child: Align(
          alignment: isIncoming ? Alignment.topLeft : Alignment.topRight,
          child: Container(
            constraints: const BoxConstraints(minWidth: 130),
            decoration: BoxDecoration(
              color: isIncoming
                  ? Theme.of(context).colorScheme.tertiary
                  : Theme.of(context).colorScheme.onSecondary,
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.only(
              top: 10,
              left: 10,
              right: 10,
              bottom: 20,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // sender
                    Username(userEmail: sender),
                    // message
                    Text(text),
                  ],
                ),
                // timestamp
                Positioned(
                  right: 0,
                  bottom: -15,
                  child: Text(
                    timestamp,
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
