import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/components/username.dart';

class MessageBaloon extends StatefulWidget {
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
  State<MessageBaloon> createState() => _MessageBaloonState();
}

class _MessageBaloonState extends State<MessageBaloon> {
  final currentUser = FirebaseAuth.instance.currentUser;
  bool isHovering = false;
  @override
  Widget build(BuildContext context) {
    final isIncoming = widget.sender != currentUser?.email;
    return Align(
      alignment: isIncoming ? Alignment.topLeft : Alignment.topRight,
      child: FractionallySizedBox(
        widthFactor: 0.9,
        child: Align(
          alignment: isIncoming ? Alignment.topLeft : Alignment.topRight,
          child: MouseRegion(
            onEnter: (_) => setState(() => isHovering = true),
            onExit: (_) => setState(() => isHovering = false),
            child: GestureDetector(
              onLongPress: widget.onLongPress,
              child: Container(
                constraints: const BoxConstraints(minWidth: 130),
                decoration: BoxDecoration(
                  color: isIncoming
                      ? Theme.of(context).colorScheme.surfaceVariant
                      : Theme.of(context).colorScheme.inverseSurface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(widget.showSender && isIncoming ? 0 : 10),
                    topRight: Radius.circular(widget.showSender && !isIncoming ? 0 : 10),
                    bottomLeft: const Radius.circular(10),
                    bottomRight: const Radius.circular(10),
                  ),
                ),
                margin: EdgeInsets.only(
                  top: widget.showSender ? 10 : 0,
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
                    Positioned(
                      top: -10,
                      right: -10,
                      child: isHovering
                          ? IconButton(
                              onPressed: widget.onLongPress,
                              icon: const Icon(Icons.keyboard_arrow_down),
                            )
                          : Container(),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // sender
                        widget.showSender
                            ? Username(userEmail: widget.sender)
                            : const SizedBox.square(dimension: 0),
                        // message
                        Text(widget.text),
                      ],
                    ),
                    // timestamp
                    Positioned(
                      right: 0,
                      bottom: -15,
                      child: Text(
                        widget.timestamp,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
