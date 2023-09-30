import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_bottle/components/clickable_text.dart';
import 'package:the_bottle/components/dialog/show_dialog.dart';
import 'package:the_bottle/components/username.dart';
import 'package:the_bottle/util/profile_tap.dart';
import 'package:the_bottle/util/timestamp_to_string.dart';
import 'comment_like_button.dart';
import 'dialog/input_from_modal_bottom_sheet.dart';
import 'dialog/options_modal_bottom_sheet.dart';

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
                      leading: const Icon(Icons.edit),
                      title: const Text(
                        'Edit comment',
                      ),
                    ),
                    ListTile(
                      onTap: () => deleteComment(commentData['CommentedBy']),
                      leading: const Icon(Icons.delete),
                      title: const Text(
                        'Delete comment',
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
                    color: Theme.of(context).colorScheme.surfaceVariant,
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
                            style: const TextStyle(fontSize: 16),
                            onTap: () {
                              // Go to profile
                              profileTap(
                                context,
                                commentData['CommentedBy'],
                                heroTag: widget.postId,
                              );
                            },
                          ),
                          // timestamp
                          Text(
                            timestampToString(commentData['CommentTime']),
                          ),
                        ],
                      ),
                      // isEdited
                      Text(
                        isEdited ? 'edited' : '',
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                      // comment
                      ClickableText(commentData['CommentText']),
                    ],
                  ),
                ),
              ),
              // comment like
              CommentLikeButton(postId: widget.postId, commentId: widget.commentId),
            ],
          );
        } else {
          return const LinearProgressIndicator(
            minHeight: 50,
          );
        }
      },
    );
  }
}
