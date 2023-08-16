import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/components/like_button.dart';
import 'package:the_wall/components/show_dialog.dart';
import 'package:the_wall/components/username.dart';
import 'package:the_wall/util/timestamp_to_string.dart';
import 'input_from_modal_bottom_sheet.dart';
import 'options_modal_bottom_sheet.dart';

class Comment extends StatefulWidget {
  const Comment({
    super.key,
    required this.postId,
    required this.commentId,
  });
  final String postId;
  final String commentId;

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  final currentUser = FirebaseAuth.instance.currentUser;
  // late String commentText;

  void editComment(String postOwner, String currentCommentText) async {
    // dismiss any keyboard
    FocusManager.instance.primaryFocus?.unfocus();
    if (context.mounted) Navigator.pop(context);

    if (postOwner != currentUser!.email) {
      showMyDialog(context,
          title: 'Nope!', content: 'You cannot edit comments made by someone else');
      return;
    }

    // get new text from user
    String? newPostText = await getInputFromModalBottomSheet(
      context,
      startingString: currentCommentText,
      enterKeyPressSubmits: false,
    );

    if (newPostText == null || newPostText.isEmpty || newPostText == currentCommentText) return;

    // edit comment from firebase firestore
    FirebaseFirestore.instance
        .collection('User Posts')
        .doc(widget.postId)
        .collection('Comments')
        .doc(widget.commentId)
        .set({
      'CommentText': newPostText,
      'Edited': true,
    }, SetOptions(merge: true));
  }

  void deleteComment(String postOwner) {
    // dismiss any keyboard
    FocusManager.instance.primaryFocus?.unfocus();
    if (context.mounted) Navigator.pop(context);

    if (postOwner != currentUser!.email) {
      showMyDialog(context,
          title: 'Nope!', content: 'You cannot delete comments made by someone else');
      return;
    }

    // delete comment from firebase firestore
    FirebaseFirestore.instance
        .collection('User Posts')
        .doc(widget.postId)
        .collection('Comments')
        .doc(widget.commentId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('User Posts')
          .doc(widget.postId)
          .collection('Comments')
          .doc(widget.commentId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data?.data() != null) {
          final commentData = snapshot.data!.data()!;
          final isEdited = commentData.containsKey('Edited') ? commentData['Edited'] : false;
          return Stack(
            alignment: Alignment.bottomRight,
            clipBehavior: Clip.none,
            children: [
              // comment body
              GestureDetector(
                onLongPress: () => optionsFromModalBottomSheet(
                  context,
                  children: [
                    ListTile(
                      onTap: () => editComment(
                        commentData['CommentedBy'],
                        commentData['CommentText'],
                      ),
                      leading: Icon(Icons.edit, color: Theme.of(context).colorScheme.onPrimary),
                      title: Text(
                        'Edit comment',
                        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                    ListTile(
                      onTap: () => deleteComment(commentData['CommentedBy']),
                      leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.onPrimary),
                      title: Text(
                        'Delete comment',
                        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.only(
                    top: 15,
                    right: 15,
                    left: 10,
                    bottom: 10,
                  ),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // user + time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // user
                          Username(
                            userEmail: commentData['CommentedBy'],
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onBackground, fontSize: 16),
                          ),
                          // timestamp
                          Text(
                            timestampToString(commentData['CommentTime']),
                            style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                          ),
                        ],
                      ),
                      // isEdited
                      Text(
                        isEdited ? 'edited' : '',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                      // comment
                      Text(commentData['CommentText'], textAlign: TextAlign.justify),
                    ],
                  ),
                ),
              ),
              // comment like
              CommentLikeButton(postId: widget.postId, commentId: widget.commentId),
            ],
          );
        } else {
          return LinearProgressIndicator(
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            color: Theme.of(context).colorScheme.surface,
            minHeight: 50,
          );
        }
      },
    );
  }
}
