import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/components/drawer_conversation.dart';
import 'package:the_wall/util/timestamp_to_string.dart';
import '../components/drawer_navigation.dart';
import '../components/message_baloon.dart';
import '../components/textfield.dart';

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
          Padding(
            padding: const EdgeInsets.only(left: 25, right: 10),
            child: Row(
              children: [
                // preview of loaded image
                if (loadedImage == null)
                  Container()
                else
                  GestureDetector(
                    onTap: viewSelectedImage,
                    onLongPress: unSelectImage,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Image.memory(loadedImage!, fit: BoxFit.cover),
                    ),
                  ),
                loadedImage == null ? Container() : const SizedBox(width: 10),
                // input textfield
                // TODO: Bugfix: either put a character limit or find a way to scroll through
                // the written text. (Check Kazu's video message for details)
                Expanded(
                  child: MyTextField(
                    controller: controller,
                    hintText: loadedImage == null ? 'Write your post' : 'Write your description',
                    onSubmited: postMessage,
                    autofocus: false,
                  ),
                ),
                // post image button
                IconButton(
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    selectImage();
                  },
                  icon: const Icon(Icons.add_photo_alternate_outlined, size: 38),
                ),
                // post text button
                IconButton(
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    postMessage();
                  },
                  icon: Icon(loadedImage == null ? Icons.post_add : Icons.send, size: 40),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
