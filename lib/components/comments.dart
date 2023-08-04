import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/components/elevated_button.dart';
import 'package:the_wall/components/username.dart';
import 'package:the_wall/settings.dart';
import '../util/timestamp_to_string.dart';
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

  void addComment() async {
    final commentText = await getInputFromModalBottomSheet(
      context,
      title: 'Add Comment',
      hintText: 'New Comment',
    );

    if (commentText == null) return;
    // write the comment to firestore under the comments collection for this post
    FirebaseFirestore.instance
        .collection('User Posts')
        .doc(widget.postId)
        .collection('Comments')
        .add({
      'CommentText': commentText,
      'CommentedBy': currentUser.email,
      'CommentTime': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    if (configEnablePostComments) {
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
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final commentData = snapshot.data!.docs[index].data();
                        return Comment(
                          text: commentData['CommentText'],
                          user: commentData['CommentedBy'],
                          timestamp: timestampToString(commentData['CommentTime']),
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

class Comment extends StatelessWidget {
  const Comment({
    super.key,
    required this.text,
    required this.user,
    required this.timestamp,
  });
  final String text;
  final String user;
  final String timestamp;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        // TODO: implement comment likes:
        // wrap this in a row, and add an like button by the end
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // user + time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // user
              Username(postOwner: user),
              // timestamp
              Text(timestamp, style: TextStyle(color: Theme.of(context).colorScheme.onBackground)),
            ],
          ),
          const SizedBox(height: 10),
          // comment
          Text(text, textAlign: TextAlign.justify),
        ],
      ),
    );
  }
}
