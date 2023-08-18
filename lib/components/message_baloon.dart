import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/components/username.dart';

class MessageBaloon extends StatelessWidget {
  const MessageBaloon({
    super.key,
    required this.text,
    required this.timestamp,
    required this.sender,
    this.onLongPress,
    this.showSender = true,
  });

  final String text;
  final String timestamp;
  final String sender;
  final bool showSender;
  final void Function()? onLongPress;

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
          child: GestureDetector(
            onLongPress: onLongPress,
            child: Container(
              constraints: const BoxConstraints(minWidth: 130),
              decoration: BoxDecoration(
                color: isIncoming
                    ? Theme.of(context).colorScheme.surface
                    : Theme.of(context).colorScheme.inverseSurface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(showSender && isIncoming ? 0 : 10),
                  topRight: Radius.circular(showSender && !isIncoming ? 0 : 10),
                  bottomLeft: const Radius.circular(10),
                  bottomRight: const Radius.circular(10),
                ),
              ),
              margin: EdgeInsets.only(
                top: showSender ? 10 : 0,
                left: 10,
                right: 10,
                bottom: 5,
              ),
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
                      showSender
                          ? Username(userEmail: sender)
                          : const SizedBox.square(dimension: 0),
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
      ),
    );
  }
}
