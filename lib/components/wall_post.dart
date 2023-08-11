import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/components/comment_button.dart';
import 'package:the_wall/components/comments.dart';
import 'package:the_wall/components/input_from_modal_bottom_sheet.dart';
import 'package:the_wall/components/options_modal_bottom_sheet.dart';
import 'package:the_wall/components/profile_picture.dart';
import 'package:the_wall/components/show_dialog.dart';
import 'package:the_wall/components/like_button.dart';
import 'package:the_wall/components/username.dart';
import 'package:the_wall/util/timestamp_to_string.dart';

import '../pages/profile_page.dart';

class WallPost extends StatefulWidget {
  const WallPost({
    super.key,
    required this.message,
    required this.postOwner,
    required this.postId,
    required this.postTimeStamp,
    this.isEdited = false,
    this.isFullScreen = false,
  });
  final String message;
  final String postOwner;
  final String postId;
  final Timestamp postTimeStamp;
  final bool isEdited;
  final bool isFullScreen;

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  final User currentUser = FirebaseAuth.instance.currentUser!;

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
    // dismiss any keyboard
    FocusManager.instance.primaryFocus?.unfocus();
    if (context.mounted) Navigator.pop(context);

    if (widget.postOwner != currentUser.email) {
      showMyDialog(context,
          title: 'Nope!', content: 'You cannot delete posts made by someone else');
      return;
    }

    // delete post from firebase firestore
    FirebaseFirestore.instance.collection('User Posts').doc(widget.postId).delete();
  }

  void viewComments() async {
    if (widget.isFullScreen) return;

    await showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: WallPost(
            message: widget.message,
            postOwner: widget.postOwner,
            postId: widget.postId,
            postTimeStamp: widget.postTimeStamp,
            isFullScreen: true,
          ),
        );
      },
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Theme.of(context).colorScheme.shadow, spreadRadius: 5, blurRadius: 5)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // post header + body
          GestureDetector(
            onLongPress: postOptions,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // header
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // profile thumbnail
                    Hero(
                      tag: widget.postId,
                      child: ProfilePicture(
                        profileEmailId: widget.postOwner,
                        size: ProfilePictureSize.small,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(
                                userEmail: widget.postOwner,
                                heroTag: widget.postId,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // username
                        Username(postOwner: widget.postOwner),
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
                        GestureDetector(onTap: postOptions, child: const Icon(Icons.more_horiz)),
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
                ),
                const SizedBox(height: 15),
                // body
                Text(widget.message, textAlign: TextAlign.justify),
                const SizedBox(height: 15),
              ],
            ),
          ),
          // like + comment buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PostLikeButton(postId: widget.postId),
              ViewCommentsButton(
                onTap: viewComments,
                postId: widget.postId,
              )
            ],
          ),
          // comments
          widget.isFullScreen ? Comments(postId: widget.postId) : Container(),
        ],
      ),
    );
  }
}
