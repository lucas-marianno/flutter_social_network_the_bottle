import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:the_bottle/components/input_from_modal_bottom_sheet.dart';
import 'package:the_bottle/components/message_baloon.dart';
import 'package:the_bottle/util/timestamp_to_string.dart';

class ConversationController {
  ConversationController({
    required this.conversationId,
    required this.setStateCallback,
    required this.context,
  }) {
    _initController();
  }
  List<Widget> get messageOptions => _messageOptions;
  Map<String, dynamic>? get selectedMessageData => _selectedMessageData;
  String? get selectedMessageId => _selectedMessageId;
  bool get showOptions => _showOptions;
  bool get showReply => _showReply;

  Stream conversationStream() {
    return FirebaseFirestore.instance
        .collection('Conversations')
        .doc(conversationId)
        .collection('Messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<bool> hasMessages() async {
    return (await _conversationRef.collection('Messages').get()).docs.isNotEmpty;
  }

  void deleteConversationIfEmpty({bool forceDelete = false}) async {
    /// TODO: Bugfix: change deletion to only hiding the conversation, the conversation should
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
        .doc(_conversationParticipants[0])
        .collection('Conversations')
        .doc(_conversationParticipants[1])
        .delete();
    await FirebaseFirestore.instance
        .collection('User Profile')
        .doc(_conversationParticipants[1])
        .collection('Conversations')
        .doc(_conversationParticipants[0])
        .delete();

    // delete conversation messages
    final messages = (await _conversationRef.collection('Messages').get()).docs;
    for (final message in messages) {
      await _conversationRef.collection('Messages').doc(message.id).delete();
    }

    // delete conversation document
    _conversationRef.delete();
  }

  void markConversationAsSeenForCurrentUser() {
    FirebaseFirestore.instance
        .collection('User Profile')
        .doc(_currentUser.email)
        .collection('Conversations')
        .doc(conversationId)
        .set({'seen': true}, SetOptions(merge: true));
  }

  void selectMessage(String messageId) async {
    _showOptions = true;
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

  void sendMessage(String text, Uint8List? image) async {
    if (text.isEmpty && image == null) return;

    // send text message
    final messageRef = await _conversationRef.collection('Messages').add({
      'sender': _currentUser.email,
      'text': text,
      'timestamp': Timestamp.now(),
    });

    // notify participants that there's a new message and the update's time
    for (String participant in _conversationParticipants) {
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

    if (image == null) return;

    // upload picture to firebase storage and retrieve download URL
    final String storageUrl = await (await FirebaseStorage.instance
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
      {'image': storageUrl},
      SetOptions(merge: true),
    );
  }

  void unSelectMessages() {
    setStateCallback(() {
      _showOptions = false;
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
    _messageOptions.add(IconButton(onPressed: _replyToMessage, icon: const Icon(Icons.reply)));
    // can favorite
    _messageOptions.add(const IconButton(onPressed: null, icon: Icon(Icons.star)));
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
    _messageOptions.add(const IconButton(onPressed: null, icon: Icon(Icons.copy)));
    // can reply
    _messageOptions.add(Transform.flip(
      flipX: true,
      child: const IconButton(onPressed: null, icon: Icon(Icons.reply)),
    ));
    // can edit
    if (isUserSender) {
      _messageOptions.add(IconButton(onPressed: _editMessage, icon: const Icon(Icons.edit)));
    }
  }

  void _deleteMessage() async {
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

  void _editMessage() async {
    if (_selectedMessageId == null) return;

    // retrieve current message data
    final oldText = _selectedMessageData!['text']! as String;
    final oldTimeStamp = _selectedMessageData!['timestamp']! as Timestamp;
    final bool isFirstEdit = !(_selectedMessageData!['isEdited'] ?? false);

    // get new text from user
    String? newText = await getInputFromModalBottomSheet(
      context,
      startingString: oldText,
      enterKeyPressSubmits: false,
    );

    if (newText == null || newText.isEmpty || newText == oldText) return;

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

  void _initController() async {
    _conversationRef = FirebaseFirestore.instance.collection('Conversations').doc(conversationId);
    _conversationParticipants = (await _conversationRef.get())['participants'];
  }

  void _messageInfo() async {
    if (_selectedMessageId == null) return;

    final history =
        (await _selectedMessageRef!.collection('Edit History').orderBy('timestamp').get()).docs;

    // ignore: use_build_context_synchronously
    await showDialog(
      context: context,
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
              );
            },
          ),
        ),
      ),
    );
    unSelectMessages();
  }

  void _replyToMessage() {
    setStateCallback(() => _showReply = true);
  }

  final BuildContext context;
  final String conversationId;
  final void Function(void Function() callback) setStateCallback;
  late final List _conversationParticipants;
  late final DocumentReference<Map<String, dynamic>> _conversationRef;
  final _currentUser = FirebaseAuth.instance.currentUser!;
  List<Widget> _messageOptions = [];
  Map<String, dynamic>? _selectedMessageData;
  String? _selectedMessageId;
  DocumentReference<Map<String, dynamic>>? _selectedMessageRef;
  bool _showOptions = false;
  bool _showReply = false;
}
