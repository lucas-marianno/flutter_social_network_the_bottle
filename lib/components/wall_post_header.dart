import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/components/profile_picture.dart';
import 'package:the_wall/components/show_dialog.dart';
import 'package:the_wall/components/username.dart';
import '../pages/profile_page.dart';
import '../util/timestamp_to_string.dart';
import 'input_from_modal_bottom_sheet.dart';
import 'options_modal_bottom_sheet.dart';

class WallPostHeader extends StatefulWidget {
  const WallPostHeader({
    super.key,
    required this.message,
    required this.postId,
    required this.postOwner,
    required this.postTimeStamp,
    this.isEdited = false,
    this.isFullScreen = false,
  });
  final String message;
  final String postId;
  final String postOwner;
  final Timestamp postTimeStamp;
  final bool isEdited;
  final bool isFullScreen;

  @override
  State<WallPostHeader> createState() => _WallPostHeaderState();
}

class _WallPostHeaderState extends State<WallPostHeader> {
  final User currentUser = FirebaseAuth.instance.currentUser!;
  late final bool userOwnsPost;

  void profileTap() {
    optionsFromModalBottomSheet(
      context,
      children: [
        ListTile(
          onTap: () {
            // TODO: Implementat: send message
            FirebaseFirestore.instance.collection('User Conversations').doc(widget.postOwner).set({
              'participants': [widget.postOwner, currentUser.email],
            });
            // Navigator.pop(context);
            // Navigator.of(context).push(MaterialPageRoute(
            //   builder: (context) => ConversationPage(),
            // ));
          },
          leading: Icon(Icons.message, color: Theme.of(context).colorScheme.onPrimary),
          title: Row(
            children: [
              Text(
                'Message ',
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
              Username(
                userEmail: widget.postOwner,
                style: TextStyle(color: Theme.of(context).colorScheme.onBackground, fontSize: 16),
              ),
            ],
          ),
        ),
        ListTile(
          onTap: () {
            // Go to profile
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProfilePage(
                  userEmail: widget.postOwner,
                  heroTag: widget.postId,
                ),
              ),
            );
          },
          leading: Icon(Icons.person, color: Theme.of(context).colorScheme.onPrimary),
          title: Text(
            'View Profile',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
      ],
    );
  }

  void postOptions() {
    if (widget.isFullScreen) return;
    optionsFromModalBottomSheet(
      context,
      children: [
        ListTile(
          onTap: editPost,
          leading: Icon(Icons.edit, color: Theme.of(context).colorScheme.onPrimary),
          title: Text(
            'Edit post',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
        ListTile(
          onTap: deletePost,
          leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.onPrimary),
          title: Text(
            'Delete post',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
      ],
    );
  }

  void editPost() async {
    // dismiss any keyboard
    FocusManager.instance.primaryFocus?.unfocus();
    if (context.mounted) Navigator.pop(context);

    if (widget.postOwner != currentUser.email) {
      showMyDialog(
        context,
        title: 'Nope!',
        content: 'You cannot edit posts made by someone else',
      );
      return;
    }

    // get new text from user
    String? newPostText = await getInputFromModalBottomSheet(
      context,
      startingString: widget.message,
      enterKeyPressSubmits: false,
    );

    if (newPostText == null || newPostText.isEmpty || newPostText == widget.message) return;

    // edit post in firebase firestore
    FirebaseFirestore.instance.collection('User Posts').doc(widget.postId).set({
      'Message': newPostText,
      'Edited': true,
    }, SetOptions(merge: true));
  }

  void deletePost() {
    // TODO: bugfix: when deleting a post, you must first delete its comments, otherwise the
    // comments colection will remain even after the parent collection has been deleted
    // dismiss any keyboard
    FocusManager.instance.primaryFocus?.unfocus();
    if (context.mounted) Navigator.pop(context);

    if (widget.postOwner != currentUser.email) {
      showMyDialog(context,
          title: 'Nope!', content: 'You cannot delete posts made by someone else');
      return;
    }
    // delete post from firebase storage
    try {
      FirebaseStorage.instance.ref('Post Pictures/${widget.postId}').delete();
    } catch (e) {
      e;
    }
    // delete post from firebase firestore
    FirebaseFirestore.instance.collection('User Posts').doc(widget.postId).delete();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userOwnsPost = widget.postOwner == currentUser.email;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // profile thumbnail
        Hero(
          tag: widget.postId,
          child: ProfilePicture(
            profileEmailId: widget.postOwner,
            size: ProfilePictureSize.small,
            onTap: profileTap,
          ),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // username
            Username(
              userEmail: widget.postOwner,
              onTap: profileTap,
              style: TextStyle(color: Theme.of(context).colorScheme.onBackground, fontSize: 16),
            ),
            // timestamp
            Text(
              timestampToString(widget.postTimeStamp),
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            )
          ],
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // more
            userOwnsPost
                ? Material(
                    color: Colors.transparent,
                    child: InkWell(onTap: postOptions, child: const Icon(Icons.more_horiz)))
                : Container(),
            // edited flag
            Text(
              widget.isEdited ? 'edited' : '',
              textAlign: TextAlign.end,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
