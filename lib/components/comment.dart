import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/components/like_button.dart';
import 'package:the_wall/components/username.dart';
import 'package:the_wall/util/timestamp_to_string.dart';

class Comment extends StatelessWidget {
  const Comment({
    super.key,
    required this.postId,
    required this.commentId,
  });
  final String postId;
  final String commentId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('User Posts')
          .doc(postId)
          .collection('Comments')
          .doc(commentId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data?.data() != null) {
          final commentData = snapshot.data!.data()!;
          return Stack(
            alignment: Alignment.bottomRight,
            clipBehavior: Clip.none,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 10,
                  right: 20,
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
                        Username(postOwner: commentData['CommentedBy']),
                        // timestamp
                        Text(
                          timestampToString(commentData['CommentTime']),
                          style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // comment
                    Text(commentData['CommentText'], textAlign: TextAlign.justify),
                  ],
                ),
              ),
              Positioned(
                bottom: -5,
                right: -25,
                child: CommentLikeButton(postId: postId, commentId: commentId),
              ),
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
