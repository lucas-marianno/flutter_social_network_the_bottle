import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/components/comment_button.dart';
import 'package:the_wall/components/comments.dart';
import 'package:the_wall/components/options_modal_bottom_sheet.dart';
import 'package:the_wall/components/show_dialog.dart';
import 'package:the_wall/components/like_button.dart';
import 'package:the_wall/components/username.dart';

class WallPost extends StatefulWidget {
  const WallPost({
    super.key,
    required this.message,
    required this.postOwner,
    required this.postId,
    required this.postTimeStamp,
    this.displayComments = false,
  });

  final String message;
  final String postOwner;
  final String postId;
  final String postTimeStamp;
  final bool displayComments;

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  final User currentUser = FirebaseAuth.instance.currentUser!;

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
    if (widget.displayComments) return;

    await showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Flexible(
            fit: FlexFit.loose,
            child: WallPost(
              message: widget.message,
              postOwner: widget.postOwner,
              postId: widget.postId,
              postTimeStamp: widget.postTimeStamp,
              displayComments: true,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => optionsFromModalBottomSheet(
        context,
        children: [
          ListTile(
            onTap: deletePost,
            leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.onPrimary),
            title: Text('Delete post',
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
          )
        ],
      ),
      child: Container(
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
            // user + timestamp
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // username
                Username(postOwner: widget.postOwner),
                // timestamp
                Text(
                  widget.postTimeStamp,
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                )
              ],
            ),
            const SizedBox(height: 15),
            // post text
            Text(widget.message, textAlign: TextAlign.justify),
            const SizedBox(height: 15),
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
            widget.displayComments ? Comments(postId: widget.postId) : Container(),
          ],
        ),
      ),
    );
  }
}
