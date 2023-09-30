import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:the_bottle/components/dialog/input_from_modal_bottom_sheet.dart';
import 'package:the_bottle/components/message_baloon.dart';
import 'package:the_bottle/pages/conversation_page.dart';
import 'package:the_bottle/pages/conversations_page.dart';
import 'package:the_bottle/util/copy_text_to_clipboard.dart';
import 'package:the_bottle/firebase/account/get_username.dart';
import 'package:the_bottle/util/temporary_save_network_image.dart';
import 'package:the_bottle/util/timestamp_to_string.dart';

class ConversationController {
  ConversationController({
    required this.conversationId,
    required this.setStateCallback,
    required this.context,
    required this.itemScrollController,
  });

  final BuildContext? context;
  final String conversationId;
  final void Function(void Function() callback) setStateCallback;
  final ItemScrollController? itemScrollController;

  /// [getParticipants] will always return the current user as index 0, and talkingTo as index 1
  List<Widget> get getMessageOptions => _messageOptions;
  List<String> get getParticipants => _conversationParticipantsEmail;
  Map<String, String> get getUsernames => _conversationParticipantsUsernames;
  Map<String, dynamic>? get getSelectedMessageData => _selectedMessageData;
  String? get getSelectedMessageId => _selectedMessageId;
  bool get getShowReply => _showReply;
  bool get hasSelectedMessages => _hasSelectedMessages;

  void addMessageIndexToMemory(String messageId, int messageIndex) {
    _conversationMessagesIndexes[messageId] = messageIndex;
  }

  Stream conversationStream() {
    return FirebaseFirestore.instance
        .collection('Conversations')
        .doc(conversationId)
        .collection('Messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> deleteConversationIfEmpty({bool forceDelete = false}) async {
    if (!_initialized) await initController();

    /// TODO: Optional Bugfix: change deletion to only hiding the conversation, the conversation should
    ///  only be deleted from server if both participants choose to delete the conversation;
    ///  Add a field 'markedForDeletion' that stores a list of the users who asked for deletion;
    ///  Notify a participant that the conversation will only be deleted if both decide to delete
    ///  it;
    ///  Everytime a user sends a new message to a marked for deletion conversation, it should
    ///  restore everything

    if (forceDelete == false && await hasMessages()) return;

    // remove conversation from participants profile
    await FirebaseFirestore.instance
        .collection('User Profile')
        .doc(_conversationParticipantsEmail[0])
        .collection('Conversations')
        .doc(_conversationParticipantsEmail[1])
        .delete();
    await FirebaseFirestore.instance
        .collection('User Profile')
        .doc(_conversationParticipantsEmail[1])
        .collection('Conversations')
        .doc(_conversationParticipantsEmail[0])
        .delete();

    // delete conversation messages
    final messages = (await _conversationRef.collection('Messages').get()).docs;
    for (var message in messages) {
      await _conversationRef.collection('Messages').doc(message.id).delete();
    }

    // delete conversation document
    _conversationRef.delete();
  }

  void dispose() {
    deleteConversationIfEmpty();
    _conversationMessagesIndexes.clear();
  }

  void findAndShowMessage(String messageId) async {
    final foundMessage = _conversationMessagesIndexes[messageId];

    if (foundMessage == null) return;

    await itemScrollController?.scrollTo(
      index: foundMessage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.decelerate,
      alignment: 0.5,
    );
    selectMessage(messageId);
  }

  Future<void> initController() async {
    if (_initialized) return;

    _conversationRef = FirebaseFirestore.instance.collection('Conversations').doc(conversationId);

    _conversationParticipantsEmail =
        List<String>.from((await _conversationRef.get())['participants']);

    if (_conversationParticipantsEmail[0] != _currentUser.email!) {
      _conversationParticipantsEmail = _conversationParticipantsEmail.reversed.toList();
    }

    _conversationParticipantsUsernames = {
      _conversationParticipantsEmail[0]: await getUserName(_conversationParticipantsEmail[0]),
      _conversationParticipantsEmail[1]: await getUserName(_conversationParticipantsEmail[1]),
    };

    _initialized = true;
    setStateCallback(() {});
  }

  Future<bool> hasMessages() async {
    return (await _conversationRef.collection('Messages').get()).docs.isNotEmpty;
  }

  Future<void> markConversationAsSeenForCurrentUser() async {
    await FirebaseFirestore.instance
        .collection('User Profile')
        .doc(_currentUser.email)
        .collection('Conversations')
        .doc(_conversationParticipantsEmail[1])
        .set({'seen': true}, SetOptions(merge: true));
  }

  Future<void> scrollToLatestMessage() async {
    await itemScrollController?.scrollTo(
      index: 0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.decelerate,
    );
    setStateCallback(() {});
  }

  Future<void> selectMessage(String messageId) async {
    _hasSelectedMessages = true;
    _selectedMessageId = messageId;
    _selectedMessageRef = FirebaseFirestore.instance
        .collection('Conversations')
        .doc(conversationId)
        .collection('Messages')
        .doc(_selectedMessageId);
    _selectedMessageData = (await _selectedMessageRef!.get()).data()!;
    _createMessageOptions();
    setStateCallback(() {});
  }

  Future<void> sendMessage(
    String text,
    Uint8List? image, {
    bool forwarded = false,
  }) async {
    if (!_initialized) await initController();
    if (text.isEmpty && image == null) return;

    // send text message
    final messageRef = await _conversationRef.collection('Messages').add({
      'sender': _currentUser.email,
      'text': text,
      'timestamp': Timestamp.now(),
    });

    // add forward info (if exists)
    if (forwarded) {
      await messageRef.set({
        'forwarded': true,
      }, SetOptions(merge: true));
      unSelectMessages();
    }

    // add reply info (if exists)
    if (_showReply) {
      await messageRef.set({
        'replyto': _selectedMessageId!,
      }, SetOptions(merge: true));
      unSelectMessages();
    }

    // notify participants that there's a new message and the update's time
    for (String participant in _conversationParticipantsEmail) {
      if (participant != _currentUser.email) {
        final updateTime = Timestamp.now();
        // notify participant
        FirebaseFirestore.instance
            .collection('User Profile')
            .doc(participant)
            .collection('Conversations')
            .doc(_currentUser.email)
            .set({
          'conversationId': conversationId,
          'lastUpdated': updateTime,
          'seen': false,
        }, SetOptions(merge: true));

        // notify  current user
        FirebaseFirestore.instance
            .collection('User Profile')
            .doc(_currentUser.email)
            .collection('Conversations')
            .doc(participant)
            .set({
          'conversationId': conversationId,
          'lastUpdated': updateTime,
          'seen': true,
        }, SetOptions(merge: true));
      }
    }

    if (image != null) {
      // upload picture to firebase storage and retrieve download URL
      final imageUrl = await (await FirebaseStorage.instance
              .ref('Conversation Files/${messageRef.id}')
              .putData(image))
          .ref
          .getDownloadURL();

      // upload pictureUrl to firebase database
      await FirebaseFirestore.instance
          .collection('Conversations')
          .doc(conversationId)
          .collection('Messages')
          .doc(messageRef.id)
          .set(
        {'image': imageUrl},
        SetOptions(merge: true),
      );
    }

    scrollToLatestMessage();
  }

  Future<void> toggleMessageLike(String messageId) async {
    bool? isLiked =
        (await _conversationRef.collection('Messages').doc(messageId).get()).data()?['liked'];
    isLiked = isLiked ?? false;
    await _conversationRef.collection('Messages').doc(messageId).set(
      {'liked': !isLiked},
      SetOptions(merge: true),
    );
  }

  void unSelectMessages() {
    setStateCallback(() {
      _hasSelectedMessages = false;
      _selectedMessageId = null;
      _selectedMessageRef = null;
      _selectedMessageData = null;
      _messageOptions = [];
      _showReply = false;
    });
  }

  void _createMessageOptions() {
    bool isUserSender = _selectedMessageData!['sender']! as String == _currentUser.email;

    _messageOptions = [];

    // can reply
    _messageOptions.add(IconButton(onPressed: replyToMessage, icon: const Icon(Icons.reply)));
    // can show info
    _messageOptions.add(IconButton(onPressed: _messageInfo, icon: const Icon(Icons.info_outline)));
    // can delete
    if (isUserSender) {
      _messageOptions.add(IconButton(
        onPressed: _deleteMessage,
        icon: const Icon(Icons.delete),
      ));
    }
    // can copy
    _messageOptions.add(IconButton(onPressed: _copyMessageText, icon: const Icon(Icons.copy)));
    // can forward
    _messageOptions.add(Transform.flip(
      flipX: true,
      child: IconButton(onPressed: _forwardMessage, icon: const Icon(Icons.reply)),
    ));
    // can edit
    if (isUserSender) {
      _messageOptions.add(IconButton(onPressed: _editMessage, icon: const Icon(Icons.edit)));
    }
  }

  Future<void> _copyMessageText() async {
    if (context == null) throw "'context' must be provided";
    final sender = await getUserName(_selectedMessageData!['sender']);
    final text = _selectedMessageData!['text'];
    final timestamp = timestampToString(_selectedMessageData!['timestamp'], absolute: true);
    await copyTextToClipboard("""
$sender

$text

$timestamp
""", context!);

    unSelectMessages();
  }

  Future<void> _deleteMessage() async {
    if (_selectedMessageId == null) return;

    // delete message image (if exists)
    try {
      await FirebaseStorage.instance.ref('Conversation Files/$_selectedMessageId').delete();
    } on FirebaseException {
      // skip
    }
    _selectedMessageRef!.delete();
    unSelectMessages();
  }

  Future<void> _editMessage() async {
    if (context == null) throw "'context' must be provided";
    if (_selectedMessageId == null) return;

    // retrieve current message data
    final oldText = _selectedMessageData!['text']! as String;
    final oldTimeStamp = _selectedMessageData!['timestamp']! as Timestamp;
    final bool isFirstEdit = !(_selectedMessageData!['isEdited'] ?? false);

    // get new text from user
    String? newText = await getInputFromModalBottomSheet(
      context!,
      startingString: oldText,
      enterKeyPressSubmits: false,
    );

    if (newText == null || newText == oldText) return;

    // set new text value and tag as edited
    _selectedMessageRef!.set({
      'text': newText,
      'isEdited': true,
    }, SetOptions(merge: true));

    // save changes to history
    if (isFirstEdit) {
      await _selectedMessageRef!.collection('Edit History').add({
        'previousText': null,
        'newText': oldText,
        'timestamp': oldTimeStamp,
      });
    }
    await _selectedMessageRef!.collection('Edit History').add({
      'previousText': oldText,
      'newText': newText,
      'timestamp': Timestamp.now(),
    });
    unSelectMessages();
  }

  Future<void> _forwardMessage() async {
    if (context == null) throw "'context' must be provided";

    if (_selectedMessageId == null) return;

    final String forwardText = _selectedMessageData!['text'];
    final String? forwardImagePath =
        await saveTemporaryNetworkImage(_selectedMessageData!['image']);

    late final Uint8List? forwardImg;
    if (forwardImagePath != null) {
      forwardImg = await XFile(forwardImagePath).readAsBytes();
    } else {
      forwardImg = null;
    }

    await showDialog(
      context: context!,
      builder: (context) => AlertDialog(
        content: SizedBox(
          height: MediaQuery.of(context).size.height / 2,
          width: double.maxFinite,
          child: ConversationsPage(
            onConversationTileTap: (newConversationId) {
              Navigator.of(context).pop();

              ConversationController newConversation = ConversationController(
                conversationId: newConversationId,
                setStateCallback: (_) {},
                context: context,
                itemScrollController: null,
              );

              newConversation.sendMessage(
                forwardText,
                forwardImg,
                forwarded: true,
              );

              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ConversationPage(
                    conversationId: newConversationId,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
    unSelectMessages();
  }

  Future<void> _messageInfo() async {
    if (context == null) throw "'context' must be provided";

    if (_selectedMessageId == null) return;

    final history =
        (await _selectedMessageRef!.collection('Edit History').orderBy('timestamp').get()).docs;

    // ignore: use_build_context_synchronously
    await showDialog(
      context: context!,
      builder: (context) => AlertDialog(
        title: const Text('Message Info'),
        content: SizedBox(
          height: MediaQuery.of(context).size.height / 2,
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: history.isEmpty ? 1 : history.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              if (history.isEmpty) {
                return const Text('This message has never been edited');
              }
              return MessageBaloon(
                sender: _selectedMessageData!['sender'],
                showSender: false,
                text: history[index]['newText'],
                timestamp: timestampToString(history[index]['timestamp']),
                messagePicture: const SizedBox(height: 0, width: 0),
                replyTo: _selectedMessageData!.putIfAbsent('replyto', () => null),
                isIncoming: _currentUser != _selectedMessageData!['sender'],
              );
            },
          ),
        ),
      ),
    );
    unSelectMessages();
  }

  void replyToMessage() {
    if (!_hasSelectedMessages) throw "No selected messages";
    setStateCallback(() => _showReply = true);
  }

  late List<String> _conversationParticipantsEmail;
  late Map<String, String> _conversationParticipantsUsernames;
  late final DocumentReference<Map<String, dynamic>> _conversationRef;
  final _currentUser = FirebaseAuth.instance.currentUser!;
  final Map<String, int> _conversationMessagesIndexes = {};
  List<Widget> _messageOptions = [];
  Map<String, dynamic>? _selectedMessageData;
  String? _selectedMessageId;
  DocumentReference<Map<String, dynamic>>? _selectedMessageRef;
  bool _hasSelectedMessages = false;
  bool _initialized = false;
  bool _showReply = false;
}
