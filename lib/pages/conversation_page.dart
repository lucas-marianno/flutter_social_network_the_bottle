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
import 'package:the_bottle/firebase/conversation/conversation_controller.dart';
import 'package:the_bottle/pages/profile_page.dart';
import 'package:the_bottle/util/timestamp_to_string.dart';

// TODO: Feature: implement multiple message selection

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
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  late final Widget talkingToProfilePicture;
  late final String currentUserEmail;
  late final String talkingToEmail;
  bool initialized = false;
  bool showFloatingActionButton = false;

  asyncInit() async {
    // init controller
    conversationController = ConversationController(
      conversationId: widget.conversationId,
      setStateCallback: setState,
      context: context,
      itemScrollController: itemScrollController,
    );
    await conversationController.initController();
    await conversationController.markConversationAsSeenForCurrentUser();

    // init users
    currentUserEmail = conversationController.getParticipants[0];
    talkingToEmail = conversationController.getParticipants[1];

    // init widget
    talkingToProfilePicture = ProfilePicture(
      profileEmailId: conversationController.getParticipants[1],
    );

    itemPositionsListener.itemPositions.addListener(
      () {
        final previousState = showFloatingActionButton;
        showFloatingActionButton = itemPositionsListener.itemPositions.value.first.index > 10;
        if (previousState != showFloatingActionButton) {
          setState(() {});
        }
      },
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
                  Text(conversationController.getUsernames[talkingToEmail]!),
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
                          return ScrollablePositionedList.builder(
                            itemScrollController: itemScrollController,
                            itemPositionsListener: itemPositionsListener,
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
                              late final bool forwarded;
                              late final bool isLiked;
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
                              try {
                                forwarded = message['forwarded'];
                              } catch (e) {
                                forwarded = false;
                              }
                              try {
                                isLiked = message['liked'];
                              } catch (e) {
                                isLiked = false;
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
                                    sender: conversationController.getUsernames[message['sender']]!,
                                    text: message['text'],
                                    timestamp: timestampToString(message['timestamp']),
                                    messagePicture: PostPicture(
                                      imageHeight: 200,
                                      context: context,
                                      padding: const EdgeInsets.only(bottom: 10),
                                      postImageUrl: imageUrl,
                                    ),
                                    replyTo: MessageBaloonReply(
                                      conversationId: widget.conversationId,
                                      replyToId: replyTo,
                                      conversationController: conversationController,
                                    ),
                                    isIncoming: currentUserEmail != message['sender'],
                                    isSelected:
                                        conversationController.getSelectedMessageId == message.id,
                                    showSender: showsender,
                                    isEdited: isEdited,
                                    isLiked: isLiked,
                                    forwarded: forwarded,
                                    onLongPress: () =>
                                        conversationController.selectMessage(message.id),
                                    onDoubleTap: () =>
                                        conversationController.toggleMessageLike(message.id),
                                    onSwipeRight: () {
                                      conversationController.selectMessage(message.id);
                                      conversationController.replyToMessage();
                                    },
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
                // input field
                InputField(
                  onSendTap: conversationController.sendMessage,
                  dismissKeyboardOnSend: false,
                ),
              ],
            ),
          ],
        ),
      ),
      // go to most recent button
      floatingActionButton: showFloatingActionButton
          ? Stack(
              alignment: Alignment.bottomRight,
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  bottom: 75,
                  child: IconButton.filled(
                    onPressed: () {
                      conversationController.scrollToLatestMessage();
                    },
                    icon: const Icon(Icons.arrow_downward),
                  ),
                ),
              ],
            )
          : const SizedBox(),
    );
  }
}
