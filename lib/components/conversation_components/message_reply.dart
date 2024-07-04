import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_bottle/components/username.dart';
import 'package:the_bottle/firebase/conversation/conversation_controller.dart';

class MessageBaloonReply extends StatelessWidget {
  const MessageBaloonReply({
    super.key,
    required this.conversationId,
    required this.replyToId,
    required this.conversationController,
  });
  final String conversationId;
  final String? replyToId;
  final ConversationController conversationController;

  @override
  Widget build(BuildContext context) {
    if (replyToId == null || replyToId!.isEmpty) return const SizedBox();

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('Conversations')
          .doc(conversationId)
          .collection('Messages')
          .doc(replyToId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          String? sender = snapshot.data!.data()?['sender'];
          String? text = snapshot.data!.data()?['text'];
          String? imageUrl = snapshot.data!.data()?['image'];
          bool selfReply =
              snapshot.data!.data()?['sender'] == FirebaseAuth.instance.currentUser!.email!;

          return GestureDetector(
            onTap: () => conversationController.findAndShowMessage(replyToId!),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(5),
                ),
                clipBehavior: Clip.hardEdge,
                height: 60,
                child: Row(
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    // reply line
                    Container(
                      color: selfReply ? Colors.blue[800] : Colors.blueGrey,
                      width: 5,
                    ),
                    // message data
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints.loose(Size(MediaQuery.of(context).size.width - 150, 60)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: sender == null || text == null
                              ? [
                                  const Text(
                                    'This message was deleted',
                                    style: TextStyle(fontStyle: FontStyle.italic),
                                  ),
                                ]
                              : [
                                  //min size
                                  const SizedBox(width: 150),
                                  // sender
                                  Username(userEmail: sender),
                                  // message text
                                  Text(text, overflow: TextOverflow.ellipsis),
                                ],
                        ),
                      ),
                    ),
                    // image thumbnail
                    imageUrl == null ? const SizedBox() : const Spacer(),
                    imageUrl == null
                        ? const SizedBox()
                        : SizedBox(
                            height: 60,
                            width: 60,
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
