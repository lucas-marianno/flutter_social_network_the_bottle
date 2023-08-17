import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/components/conversation_tile.dart';
import 'package:the_wall/components/profile_picture.dart';
import 'package:the_wall/components/textfield.dart';
import 'package:the_wall/components/username.dart';
import 'package:the_wall/pages/conversation_page.dart';

class DrawerConversations extends StatelessWidget {
  const DrawerConversations({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    final conversationsCollectionRef = FirebaseFirestore.instance
        .collection('User Profile')
        .doc(currentUser!.email)
        .collection('Conversations');

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.primary,
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
                                    const SizedBox(width: 10),
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
