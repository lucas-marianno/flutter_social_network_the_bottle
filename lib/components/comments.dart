import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/components/comment.dart';
import 'package:the_wall/components/elevated_button.dart';
import 'package:the_wall/settings.dart';
import 'input_from_modal_bottom_sheet.dart';

class Comments extends StatefulWidget {
  const Comments({
    super.key,
    required this.postId,
  });

  final String postId;

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  final User currentUser = FirebaseAuth.instance.currentUser!;
  ScrollController scrollController = ScrollController();

  void addComment() async {
    final commentText = await getInputFromModalBottomSheet(
      context,
      title: 'Add Comment',
      hintText: 'New Comment',
    );

    if (commentText == null) return;

    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 1500),
      curve: Curves.decelerate,
    );
    // write the comment to firestore under the comments collection for this post
    FirebaseFirestore.instance
        .collection('User Posts')
        .doc(widget.postId)
        .collection('Comments')
        .add({
      'CommentText': commentText,
      'CommentedBy': currentUser.email,
      'CommentTime': Timestamp.now(),
      'CommentLikes': [],
    });
  }

  @override
  Widget build(BuildContext context) {
    if (UserConfig().enablePostComments) {
      return Flexible(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('User Posts')
                    .doc(widget.postId)
                    .collection('Comments')
                    .orderBy('CommentTime', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.docs.isEmpty) return const Text('');

                    return ListView.builder(
                      controller: scrollController,
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        return Comment(
                          postId: widget.postId,
                          commentId: snapshot.data!.docs[index].id,
                        );
                      },
                    );
                  } else {
                    return LinearProgressIndicator(
                      backgroundColor: Theme.of(context).colorScheme.onPrimary,
                      color: Theme.of(context).colorScheme.surface,
                      minHeight: 50,
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            Material(child: MyButton(text: 'Add Comment', onTap: addComment)),
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}
