import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_bottle/components/conversation_tile.dart';
import 'package:the_bottle/components/textfield.dart';

class ConversationsPage extends StatelessWidget {
  const ConversationsPage({
    super.key,
    this.onConversationTileTap,
    this.onConversationTileLongPress,
  });

  final void Function(String conversationId)? onConversationTileTap;
  final void Function(String conversationId)? onConversationTileLongPress;

  @override
  Widget build(BuildContext context) {
    return Column(
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
                    onLongPress: () {
                      onConversationTileLongPress
                          ?.call(conversations[index].data()['conversationId']);
                    },
                    onTap: () {
                      onConversationTileTap?.call(conversations[index].data()['conversationId']);
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
    );
  }
}
