import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:the_bottle/components/username.dart';
import 'package:the_bottle/firebase/conversation/conversation_controller.dart';

class ConversationReply extends StatelessWidget {
  const ConversationReply(
    this.conversationController, {
    super.key,
  });
  final ConversationController conversationController;

  @override
  Widget build(BuildContext context) {
    final bool showField = conversationController.getShowReply;
    final Map<String, dynamic>? selectedMessageData = conversationController.getSelectedMessageData;

    if (!showField || selectedMessageData == null) return Container();

    String sender = selectedMessageData['sender'];
    String messageText = selectedMessageData['text'];
    String? imageUrl = selectedMessageData['image'];
    bool selfReply = sender == FirebaseAuth.instance.currentUser!.email;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.all(10),
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        height: 60,
        child: Stack(
          children: [
            Row(
              children: [
                // reply line
                Container(color: selfReply ? Colors.blue[800] : Colors.blueGrey, width: 5),
                const SizedBox(width: 5),
                // message data
                ConstrainedBox(
                  constraints:
                      BoxConstraints.loose(Size(MediaQuery.of(context).size.width - 100, 60)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 5),
                      // sender
                      Text(conversationController.getUsernames[sender]!),
                      // message text
                      Text(
                        messageText,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
              ],
            ),
            // message picture
            imageUrl == null
                ? Container()
                : Positioned(
                    right: 0,
                    child: SizedBox(
                      height: 60,
                      width: 60,
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
            // cancel button
            Positioned(
              right: 5,
              top: 5,
              child: InkWell(
                onTap: conversationController.unSelectMessages,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(131, 255, 255, 255),
                  ),
                  child: const Icon(Icons.close, size: 15),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
