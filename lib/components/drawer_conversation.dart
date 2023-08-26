import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_bottle/components/conversation_tile.dart';
import 'package:the_bottle/components/options_modal_bottom_sheet.dart';
import 'package:the_bottle/components/profile_picture.dart';
import 'package:the_bottle/components/textfield.dart';
import 'package:the_bottle/components/username.dart';
import 'package:the_bottle/pages/conversation_page.dart';

class DrawerConversations extends StatelessWidget {
  const DrawerConversations({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    final conversationsCollectionRef = FirebaseFirestore.instance
        .collection('User Profile')
        .doc(currentUser!.email)
        .collection('Conversations');

    deleteConversation(String conversationId) async {
      final conversationRef =
          FirebaseFirestore.instance.collection('Conversations').doc(conversationId);

      // get participants
      final participants = (await conversationRef.get())['participants'] as List;

      // remove conversation from participants profile
      await FirebaseFirestore.instance
          .collection('User Profile')
          .doc(participants[0])
          .collection('Conversations')
          .doc(participants[1])
          .delete();
      await FirebaseFirestore.instance
          .collection('User Profile')
          .doc(participants[1])
          .collection('Conversations')
          .doc(participants[0])
          .delete();

      // delete conversation messages
      final messages = (await conversationRef.collection('Messages').get()).docs;
      for (final message in messages) {
        await conversationRef.collection('Messages').doc(message.id).delete();
      }

      // delete conversation document
      conversationRef.delete();
    }

    conversationOptions(String conversationId) async {
      await optionsFromModalBottomSheet(
        context,
        children: [
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete Conversation'),
            onTap: () => deleteConversation(conversationId),
          )
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
              stream: conversationsCollectionRef
                  .orderBy(
                    'lastUpdated',
                    descending: true,
                  )
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
                          // mark as seen
                          conversationsCollectionRef
                              .doc(conversation.id)
                              .set({'seen': true}, SetOptions(merge: true));
                          // go to conversation
                          Navigator.pop(context);
                          Navigator.of(context).popUntil((route) => route.isFirst);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ConversationPage(
                                conversationId: conversations[index].data()['conversationId'],
                                talkingTo: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ProfilePicture(
                                      profileEmailId: conversations[index].id,
                                      size: ProfilePictureSize.small,
                                    ),
                                    const SizedBox(width: 10),
                                    Username(userEmail: conversations[index].id),
                                  ],
                                ),
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
