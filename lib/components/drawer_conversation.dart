import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/components/conversation_tile.dart';
import 'package:the_wall/components/textfield.dart';
import 'package:the_wall/components/username.dart';
import 'package:the_wall/pages/conversation_page.dart';

class DrawerConversations extends StatelessWidget {
  const DrawerConversations({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    // TODO: implement: this!

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
              stream: FirebaseFirestore.instance
                  .collection('User Profile')
                  .doc(currentUser!.email)
                  .collection('Conversations')
                  .orderBy('lastUpdated')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final conversations = snapshot.data!.docs;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      return ConversationTile(
                        userEmail: conversations[index].id,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).popUntil((route) => route.isFirst);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ConversationPage(
                                conversationId: conversations[index].data()['conversationId'],
                                talkingTo: Username(userEmail: conversations[index].id),
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
