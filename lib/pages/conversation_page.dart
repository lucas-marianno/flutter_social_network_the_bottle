import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:the_bottle/components/blurred_appbar.dart';
import 'package:the_bottle/components/drawer_conversation.dart';
import 'package:the_bottle/components/input_field.dart';
import 'package:the_bottle/components/message_reply.dart';
import 'package:the_bottle/components/post_picture.dart';
import 'package:the_bottle/components/conversation_reply.dart';
import 'package:the_bottle/components/message_baloon.dart';
import 'package:the_bottle/components/profile_picture.dart';
import 'package:the_bottle/components/username.dart';
import 'package:the_bottle/firebase/conversation/conversation_controller.dart';
import 'package:the_bottle/pages/profile_page.dart';
import 'package:the_bottle/util/timestamp_to_string.dart';

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
  final ItemScrollController itemScrollController = ItemScrollController();
  late final Widget currentUserUsername;
  late final Widget talkingToUsername;
  late final Widget talkingToProfilePicture;
  bool initialized = false;

  asyncInit() async {
    // init controller
    conversationController = ConversationController(
      conversationId: widget.conversationId,
      setStateCallback: setState,
      context: context,
      itemScrollController: itemScrollController,
    );
    await conversationController.initController();
    conversationController.markConversationAsSeenForCurrentUser();

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

    setState(() => initialized = true);
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
    conversationController.dispose();
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
                IconButton(
                  onPressed: () {
                    itemScrollController.scrollTo(
                      index: 0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.decelerate,
                    );
                  },
                  icon: const Icon(Icons.find_in_page),
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
                          return ScrollablePositionedList.builder(
                            itemScrollController: itemScrollController,
                            shrinkWrap: true,
                            reverse: true,
                            itemCount: itemCount,
                            itemBuilder: (context, index) {
                              final message = snapshot.data!.docs[index];
                              conversationController.addMessageIndexToMemory(message.id, index);
                              late final bool showsender;
                              late final String? imageUrl;
                              late final bool isEdited;
                              late final String? replyTo;
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
                              try {
                                replyTo = message['replyto'];
                              } catch (e) {
                                replyTo = null;
                              }
                              return Column(
                                children: [
                                  index == itemCount - 1
                                      ? SizedBox(
                                          height: MediaQuery.of(context).size.height / 6,
                                          child: const Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Text('This is where the conversation starts')),
                                        )
                                      : const SizedBox(),
                                  MessageBaloon(
                                    sender: message['sender'],
                                    text: message['text'],
                                    timestamp: timestampToString(message['timestamp']),
                                    messagePicture: PostPicture(
                                      imageHeight: 200,
                                      context: context,
                                      padding: const EdgeInsets.only(bottom: 10),
                                      postImageUrl: imageUrl,
                                    ),
                                    replyTo: Column(
                                      children: [
                                        MessageBaloonReply(
                                          conversationId: widget.conversationId,
                                          replyToId: replyTo,
                                          conversationController: conversationController,
                                        ),
                                      ],
                                    ),
                                    isSelected:
                                        conversationController.getSelectedMessageId == message.id,
                                    showSender: showsender,
                                    isEdited: isEdited,
                                    onLongPress: () =>
                                        conversationController.selectMessage(message.id),
                                  ),
                                ],
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
                InputField(
                  onSendTap: conversationController.sendMessage,
                  dismissKeyboardOnSend: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
