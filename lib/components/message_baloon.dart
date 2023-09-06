import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_bottle/components/username.dart';

class MessageBaloon extends StatefulWidget {
  const MessageBaloon({
    super.key,
    required this.sender,
    required this.text,
    required this.timestamp,
    required this.messagePicture,
    this.isSelected = false,
    this.showSender = true,
    this.isEdited = false,
    this.onLongPress,
  });

  final String sender;
  final String text;
  final String timestamp;
  final Widget messagePicture;
  final bool isSelected;
  final bool showSender;
  final bool isEdited;
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
    return Column(
      children: [
        widget.showSender ? const SizedBox(height: 10) : Container(),
        Container(
          width: double.maxFinite,
          color: widget.isSelected ? const Color.fromARGB(117, 96, 125, 139) : Colors.transparent,
          child: Align(
            alignment: isIncoming ? Alignment.centerLeft : Alignment.centerRight,
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
                      constraints: const BoxConstraints(minWidth: 150),
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
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      padding: const EdgeInsets.only(
                        top: 10,
                        left: 10,
                        right: 10,
                        bottom: 20,
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // body
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // sender
                              widget.showSender
                                  ? Username(userEmail: widget.sender)
                                  : const SizedBox.square(dimension: 0),
                              // picture
                              widget.messagePicture,
                              // message
                              Text(widget.text),
                            ],
                          ),
                          // options button (web only)
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
                          // edited tag + timestamp
                          Positioned(
                            right: 0,
                            bottom: -15,
                            child: DefaultTextStyle(
                              style: const TextStyle(fontSize: 10),
                              child: Row(
                                children: [
                                  Text(
                                    widget.isEdited ? 'edited  •  ' : '',
                                    style: const TextStyle(fontStyle: FontStyle.italic),
                                  ),
                                  Text(widget.timestamp),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
