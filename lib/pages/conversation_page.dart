import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:the_bottle/components/blurred_appbar.dart';
import 'package:the_bottle/components/drawer_conversation.dart';
import 'package:the_bottle/components/input_field.dart';
import 'package:the_bottle/components/post_picture.dart';
import 'package:the_bottle/components/conversation_reply.dart';
import 'package:the_bottle/components/message_baloon.dart';
import 'package:the_bottle/components/profile_picture.dart';
import 'package:the_bottle/components/username.dart';
import 'package:the_bottle/firebase/conversation/conversation_controller.dart';
import 'package:the_bottle/pages/profile_page.dart';
import 'package:the_bottle/util/timestamp_to_string.dart';

// TODO: Feature: implement reply to messages - WIP
// TODO: Feature: implement copy text button
// TODO: Feature: implement favorite message
// TODO: Feature: implement forward message
// TODO: Feature: implement message like
// TODO: Feature: implement multiple message selection
// TODO: Feature: implement download image

class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key, required this.conversationId});
  final String conversationId;

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  late final ConversationController conversationController;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController scrollController = ScrollController();
  late final Widget currentUserUsername;
  late final Widget talkingToUsername;
  late final Widget talkingToProfilePicture;
  bool initialized = false;

  void sendMessage(String text, Uint8List? loadedImage) async {
    await conversationController.sendMessage(text, loadedImage);

    // scroll to most recent message
    await scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.decelerate,
    );
  }

  asyncInit() async {
    // init controller
    conversationController = ConversationController(
      conversationId: widget.conversationId,
      setStateCallback: setState,
      context: context,
    );
    await conversationController.initController();
    conversationController.markConversationAsSeenForCurrentUser;

    // init widgets
    currentUserUsername = Username(
      userEmail: conversationController.getParticipants[0],
    );
    talkingToUsername = Username(
      userEmail: conversationController.getParticipants[1],
    );
    talkingToProfilePicture = ProfilePicture(
      profileEmailId: conversationController.getParticipants[1],
    );

    setState(() {
      initialized = true;
    });
  }

  void navigateToProfile() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ProfilePage(userEmail: conversationController.getParticipants[1]),
    ));
  }

  @override
  void initState() {
    asyncInit();
    super.initState();
  }

  @override
  void dispose() {
    conversationController.deleteConversationIfEmpty(forceDelete: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!initialized) return Container();
    return Scaffold(
      key: scaffoldKey,
      endDrawer: const DrawerConversations(),
      extendBodyBehindAppBar: true,
      appBar: BlurredAppBar(
        centerTitle: false,
        onTap: !conversationController.hasSelectedMessages ? navigateToProfile : null,
        title: conversationController.hasSelectedMessages
            ? Container()
            : Row(
                children: [
                  talkingToProfilePicture,
                  const SizedBox(width: 10),
                  talkingToUsername,
                ],
              ),
        actions: conversationController.hasSelectedMessages
            ? conversationController.getMessageOptions
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
          if (conversationController.getSelectedMessageId != null) {
            conversationController.unSelectMessages();
            return false;
          }
          return true;
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'lib/assets/${Theme.of(context).brightness.name}doodle.jpg',
              fit: BoxFit.cover,
            ),
            Column(
              children: [
                // conversation
                Expanded(
                  child: GestureDetector(
                    onTap: conversationController.unSelectMessages,
                    child: StreamBuilder(
                      stream: conversationController.conversationStream(),
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
                              late final bool isEdited;
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
                              try {
                                isEdited = message['isEdited'];
                              } catch (e) {
                                isEdited = false;
                              }
                              return MessageBaloon(
                                sender: message['sender'],
                                text: message['text'],
                                timestamp: timestampToStringRelative(message['timestamp']),
                                messagePicture: PostPicture(
                                  imageHeight: 200,
                                  context: context,
                                  padding: const EdgeInsets.only(bottom: 10),
                                  postImageUrl: imageUrl,
                                ),
                                isSelected:
                                    conversationController.getSelectedMessageId == message.id,
                                showSender: showsender,
                                isEdited: isEdited,
                                onLongPress: () => conversationController.selectMessage(message.id),
                              );
                            },
                          );
                        } else {
                          return const Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
                ),
                // reply field
                ConversationReply(conversationController),
                // post message
                InputField(onSendTap: sendMessage, dismissKeyboardOnSend: false),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
