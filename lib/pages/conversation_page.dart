import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/components/drawer_conversation.dart';
import 'package:the_wall/components/input_field.dart';
import 'package:the_wall/util/timestamp_to_string.dart';
import '../components/drawer_navigation.dart';
import '../components/message_baloon.dart';

class ConversationPage extends StatelessWidget {
  const ConversationPage({
    super.key,
    required this.conversationId,
    required this.talkingTo,
  });
  final String conversationId;
  final Widget talkingTo;

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final ScrollController scrollController = ScrollController();
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.background,
      drawer: const DrawerNavigation(),
      endDrawer: const DrawerConversations(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: true,
        title: talkingTo,
        actions: [
          IconButton(
            onPressed: () {
              scaffoldKey.currentState?.openEndDrawer();
            },
            icon: const Icon(Icons.message),
          )
        ],
      ),
      body: Column(
        children: [
          // conversation
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Conversations')
                  .doc(conversationId)
                  .collection('Messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('start a conversation'));
                  }
                  return ListView.builder(
                    controller: scrollController,
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final message = snapshot.data!.docs[index];
                      return MessageBaloon(
                        sender: message['sender'],
                        text: message['text'],
                        timestamp: timestampToString(message['timestamp']),
                      );
                    },
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          // post message
          InputField(
            postMessageFunction: (textEditingController, loadedImage) {},
          ),
        ],
      ),
    );
  }
}
