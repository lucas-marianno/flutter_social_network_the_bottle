import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_bottle/components/conversation_tile.dart';
import 'package:the_bottle/components/options_modal_bottom_sheet.dart';
import 'package:the_bottle/components/textfield.dart';
import 'package:the_bottle/firebase/conversation/conversation_controller.dart';
import 'package:the_bottle/pages/conversation_page.dart';

class DrawerConversations extends StatelessWidget {
  const DrawerConversations({super.key});

  @override
  Widget build(BuildContext context) {
    conversationOptions(String conversationId) async {
      ConversationController conversationController = ConversationController(
        conversationId: conversationId,
        setStateCallback: (_) {},
        context: context,
        scrollController: ScrollController(),
      );
      await conversationController.initController();
      // ignore: use_build_context_synchronously
      await optionsFromModalBottomSheet(
        context,
        children: [
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete Conversation'),
            onTap: () {
              conversationController.deleteConversationIfEmpty(forceDelete: true);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    }

    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Center(child: Text('C O N V E R S A T I O N S')),
                  MyTextField(
                    hintText: 'Search for a conversation',
                    autofocus: false,
                  ),
                ],
              ),
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('User Profile')
                  .doc(FirebaseAuth.instance.currentUser!.email)
                  .collection('Conversations')
                  .orderBy('lastUpdated', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final conversations = snapshot.data!.docs;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = conversations[index];
                      return ConversationTile(
                        seen: conversation['seen'],
                        userEmail: conversation.id,
                        lastUpdated: conversation['lastUpdated'],
                        onLongPress: () =>
                            conversationOptions(conversations[index].data()['conversationId']),
                        onTap: () {
                          // go to conversation
                          Navigator.pop(context);
                          Navigator.of(context).popUntil((route) => route.isFirst);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ConversationPage(
                                conversationId: conversations[index].data()['conversationId'],
                                // talkingTo: Row(
                                //   mainAxisSize: MainAxisSize.min,
                                //   children: [
                                //     ProfilePicture(
                                //       profileEmailId: conversations[index].id,
                                //       size: ProfilePictureSize.small,
                                //     ),
                                //     const SizedBox(width: 10),
                                //     Username(userEmail: conversations[index].id),
                                //   ],
                                // ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
