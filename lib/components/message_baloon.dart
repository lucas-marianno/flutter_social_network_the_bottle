import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_bottle/components/clickable_text.dart';

class MessageBaloon extends StatefulWidget {
  const MessageBaloon({
    super.key,
    required this.sender,
    required this.text,
    required this.timestamp,
    required this.messagePicture,
    required this.replyTo,
    required this.isIncoming,
    this.isSelected = false,
    this.isEdited = false,
    this.isLiked = false,
    this.showSender = true,
    this.forwarded = false,
    this.onLongPress,
    this.onSwipeRight,
    this.onDoubleTap,
  });

  final String sender;
  final String text;
  final String timestamp;
  final Widget messagePicture;
  final Widget? replyTo;
  final bool isIncoming;
  final bool isSelected;
  final bool isEdited;
  final bool isLiked;
  final bool showSender;
  final bool forwarded;
  final void Function()? onLongPress;
  final void Function()? onSwipeRight;
  final void Function()? onDoubleTap;

  @override
  State<MessageBaloon> createState() => _MessageBaloonState();
}

class _MessageBaloonState extends State<MessageBaloon> {
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.onLongPress,
      onDoubleTap: widget.onDoubleTap,
      onHorizontalDragEnd: (details) {
        //onSwipeRight
        (details.primaryVelocity ?? 0) > 0 ? widget.onSwipeRight?.call() : false;
      },
      child: Container(
        padding: EdgeInsets.only(top: widget.showSender ? 10 : 0, bottom: widget.isLiked ? 10 : 0),
        width: double.maxFinite,
        color: widget.isSelected ? const Color.fromARGB(117, 96, 125, 139) : Colors.transparent,
        child: Align(
          alignment: widget.isIncoming ? Alignment.centerLeft : Alignment.centerRight,
          child: FractionallySizedBox(
            widthFactor: 0.9,
            child: Align(
              alignment: widget.isIncoming ? Alignment.topLeft : Alignment.topRight,
              child: Container(
                constraints: const BoxConstraints(minWidth: 150),
                decoration: BoxDecoration(
                  color: widget.isIncoming
                      ? Theme.of(context).colorScheme.surfaceVariant
                      : Theme.of(context).colorScheme.inverseSurface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(widget.showSender && widget.isIncoming ? 0 : 10),
                    topRight: Radius.circular(widget.showSender && !widget.isIncoming ? 0 : 10),
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
                        // forwarded tag
                        !widget.forwarded
                            ? const SizedBox()
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Transform.flip(
                                    flipX: true,
                                    child: const Icon(
                                      Icons.reply,
                                      size: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const Text(
                                    '  forwarded',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                        SizedBox(height: widget.forwarded ? 5 : 0),
                        // sender
                        widget.showSender ? Text(widget.sender) : const SizedBox(),
                        SizedBox(height: widget.showSender ? 5 : 0),
                        // reply
                        widget.replyTo ?? const SizedBox(),
                        // picture
                        widget.messagePicture,
                        // message
                        ClickableText(widget.text),
                        const SizedBox(height: 5),
                      ],
                    ),
                    // like
                    !widget.isLiked
                        ? const SizedBox()
                        : Positioned(
                            right: widget.isIncoming ? null : -5,
                            left: !widget.isIncoming ? null : -5,
                            bottom: -32,
                            child: const Icon(Icons.favorite, color: Colors.red),
                          ),
                    // edited tag + timestamp
                    Positioned(
                      right: 0,
                      bottom: -10,
                      child: DefaultTextStyle(
                        style: const TextStyle(fontSize: 10),
                        child: Row(
                          children: [
                            Text(
                              widget.isEdited ? 'edited  •  ' : '',
                              style:
                                  const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                            ),
                            Text(
                              widget.timestamp,
                              style: const TextStyle(color: Colors.grey),
                            ),
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
    );
  }
}
