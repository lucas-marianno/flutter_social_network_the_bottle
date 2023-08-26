import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:the_bottle/components/blurred_appbar.dart';
import 'package:the_bottle/components/drawer_conversation.dart';
import 'package:the_bottle/components/input_field.dart';
import 'package:the_bottle/components/wall_post_picture.dart';
import 'package:the_bottle/util/timestamp_to_string.dart';
import '../components/message_baloon.dart';

class ConversationPage extends StatefulWidget {
  const ConversationPage({
    super.key,
    required this.conversationId,
    required this.talkingTo,
  });
  final String conversationId;
  final Widget talkingTo;

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController scrollController = ScrollController();
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool showOptions = false;
  String? selectedMessageId;

  void sendMessage(String text, Uint8List? loadedImage) async {
    final conversationRef =
        FirebaseFirestore.instance.collection('Conversations').doc(widget.conversationId);
    // update conversation
    final messageRef = await conversationRef.collection('Messages').add({
      'sender': currentUser.email,
      'text': text,
      'timestamp': Timestamp.now(),
    });

    // adds image to message
    if (loadedImage != null) {
      addImageToMessage(messageRef.id, loadedImage);
    }

    // scroll to most recent message
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.decelerate,
    );

    // notify participants that there's a new message and the update time
    final List participants = (await conversationRef.get())['participants'];
    for (String participant in participants) {
      if (participant != currentUser.email) {
        final updateTime = Timestamp.now();
        // notify participant
        FirebaseFirestore.instance
            .collection('User Profile')
            .doc(participant)
            .collection('Conversations')
            .doc(currentUser.email)
            .set({
          'conversationId': widget.conversationId,
          'lastUpdated': updateTime,
          'seen': false,
        }, SetOptions(merge: true));

        // notify  current user
        FirebaseFirestore.instance
            .collection('User Profile')
            .doc(currentUser.email)
            .collection('Conversations')
            .doc(participant)
            .set({
          'conversationId': widget.conversationId,
          'lastUpdated': updateTime,
          'seen': true,
        }, SetOptions(merge: true));
      }
    }
  }

  void deleteEmptyConversation() async {
    final ref = FirebaseFirestore.instance.collection('Conversations').doc(widget.conversationId);

    // verify if conversation has messages
    final hasMessages = (await ref.collection('Messages').get()).docs.isNotEmpty;
    if (hasMessages) return;

    // delete conversation if empty
    await ref.delete();
  }

  void addImageToMessage(String messageId, Uint8List image) async {
    // upload picture to firebase storage and retrieve download URL
    final String storageUrl =
        await (await FirebaseStorage.instance.ref('Conversation Files/$messageId').putData(image))
            .ref
            .getDownloadURL();

    // upload pictureUrl to firebase database
    await FirebaseFirestore.instance
        .collection('Conversations')
        .doc(widget.conversationId)
        .collection('Messages')
        .doc(messageId)
        .set(
      {'image': storageUrl},
      SetOptions(merge: true),
    );

    // unload image after post
    setState(() {});
  }

  void selectMessage(String messageId) {
    // TODO: Implement multiple selection
    setState(() {
      showOptions = true;
      selectedMessageId = messageId;
    });
  }

  void unSelectMessages() {
    setState(() {
      showOptions = false;
      selectedMessageId = null;
    });
  }

  void deleteMessage() async {
    // delete message image (if exists)
    try {
      await FirebaseStorage.instance.ref('Conversation Files/$selectedMessageId').delete();
    } on FirebaseException {
      // skip
    }
    // delete message
    FirebaseFirestore.instance
        .collection('Conversations')
        .doc(widget.conversationId)
        .collection('Messages')
        .doc(selectedMessageId)
        .delete();
    unSelectMessages();
  }

  @override
  void dispose() {
    deleteEmptyConversation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      endDrawer: const DrawerConversations(),
      extendBodyBehindAppBar: true,
      appBar: BlurredAppBar(
        centerTitle: false,
        title: widget.talkingTo,
        actions: showOptions
            ? [
                IconButton(onPressed: () {}, icon: const Icon(Icons.reply)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.star)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.info_outline)),
                IconButton(onPressed: deleteMessage, icon: const Icon(Icons.delete)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.copy)),
                Transform.flip(
                  flipX: true,
                  child: IconButton(onPressed: () {}, icon: const Icon(Icons.reply)),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
              ]
            : [
                IconButton(
                  onPressed: () {
                    scaffoldKey.currentState?.openEndDrawer();
                  },
                  icon: const Icon(Icons.message),
                ),
              ],
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (selectedMessageId != null) {
            unSelectMessages();
            return false;
          }
          return true;
        },
        child: GestureDetector(
          onTap: unSelectMessages,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('lib/assets/${Theme.of(context).brightness.name}doodle.jpg',
                  fit: BoxFit.cover),
              Column(
                children: [
                  // conversation
                  Expanded(
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('Conversations')
                          .doc(widget.conversationId)
                          .collection('Messages')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.docs.isEmpty) {
                            return const Center(child: Text('start a conversation'));
                          }
                          final int itemCount = snapshot.data!.docs.length;
                          return ListView.builder(
                            controller: scrollController,
                            shrinkWrap: true,
                            reverse: true,
                            itemCount: itemCount,
                            itemBuilder: (context, index) {
                              final message = snapshot.data!.docs[index];
                              late final bool showsender;
                              late final String? imageUrl;
                              if (index == itemCount - 1 ||
                                  snapshot.data!.docs[index + 1]['sender'] != message['sender']) {
                                showsender = true;
                              } else {
                                showsender = false;
                              }
                              try {
                                imageUrl = message['image'];
                              } catch (e) {
                                imageUrl = null;
                              }
                              return MessageBaloon(
                                sender: message['sender'],
                                text: message['text'],
                                timestamp: timestampToString(message['timestamp']),
                                messagePicture: PostPicture(
                                  imageHeight: 200,
                                  context: context,
                                  padding: const EdgeInsets.only(bottom: 10),
                                  postImageUrl: imageUrl,
                                ),
                                isSelected: selectedMessageId == message.id,
                                showSender: showsender,
                                onLongPress: () => selectMessage(message.id),
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
                  InputField(onSendTap: sendMessage, dismissKeyboardOnSend: false),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
