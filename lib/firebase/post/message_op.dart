import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_bottle/firebase/is_current_user.dart';
import '../../pages/conversation_page.dart';

void messageOriginalPoster(String opEmail, BuildContext context) async {
  if (isCurrentUser(opEmail)) return;

  User currentUser = FirebaseAuth.instance.currentUser!;

  // check profile for a previous conversation
  final conversation = await FirebaseFirestore.instance
      .collection('User Profile')
      .doc(currentUser.email)
      .collection('Conversations')
      .doc(opEmail)
      .get();

  // if theres a conversation, navigate to conversation
  if (conversation.exists) {
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    // ignore: use_build_context_synchronously
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConversationPage(
          conversationId: conversation['conversationId'],
        ),
      ),
    );
  } else {
    // if theres no conversation, create a new one
    final newConversation = FirebaseFirestore.instance.collection('Conversations').doc();
    newConversation.set({
      'participants': [currentUser.email, opEmail]
    });

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    // ignore: use_build_context_synchronously
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConversationPage(
          conversationId: newConversation.id,
        ),
      ),
    );
  }
}
