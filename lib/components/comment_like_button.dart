import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_bottle/components/show_likes_list.dart';

class CommentLikeButton extends StatefulWidget {
  const CommentLikeButton({
    super.key,
    required this.postId,
    required this.commentId,
  });

  final String postId;
  final String commentId;

  @override
  State<CommentLikeButton> createState() => _CommentLikeButtonState();
}

class _CommentLikeButtonState extends State<CommentLikeButton> {
  late bool isLiked;
  final User currentUser = FirebaseAuth.instance.currentUser!;

  void toggleLike() {
    setState(() => isLiked = !isLiked);

    final postReference = FirebaseFirestore.instance
        .collection('User Posts')
        .doc(widget.postId)
        .collection('Comments')
        .doc(widget.commentId);
    if (isLiked) {
      postReference.update({
        'CommentLikes': FieldValue.arrayUnion([currentUser.email]),
      });
    } else {
      postReference.update({
        'CommentLikes': FieldValue.arrayRemove([currentUser.email]),
      });
    }
  }

  void showLikes() async {
    // get likes list
    final likesList = (await FirebaseFirestore.instance
            .collection('User Posts')
            .doc(widget.postId)
            .collection('Comments')
            .doc(widget.commentId)
            .get())
        .data()?['CommentLikes'] as List?;

    // ignore: use_build_context_synchronously
    showLikesList(context, likesList);
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
        if (snapshot.hasData) {
          final List likes = snapshot.data!.data()?['CommentLikes'] ?? [];

          isLiked = likes.contains(currentUser.email);
          return Material(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(5),
            child: InkWell(
              borderRadius: BorderRadius.circular(5),
              onTap: toggleLike,
              onLongPress: showLikes,
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 5),
                    Icon(
                      isLiked ? Icons.favorite : Icons.favorite_outline,
                      color: isLiked ? Colors.red : null,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      likes.isEmpty ? '' : '${likes.length}',
                      style: const TextStyle(),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return const SizedBox(
            height: 50,
            width: 75,
            child: LinearProgressIndicator(
              minHeight: 50,
            ),
          );
        }
      },
    );
  }
}
