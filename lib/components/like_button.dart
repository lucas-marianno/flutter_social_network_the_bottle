import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PostLikeButton extends StatefulWidget {
  const PostLikeButton({super.key, required this.postId});

  final String postId;

  @override
  State<PostLikeButton> createState() => _PostLikeButtonState();
}

class _PostLikeButtonState extends State<PostLikeButton> {
  final User currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;

  void toggleLike() {
    setState(() => isLiked = !isLiked);

    final postReference = FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);
    if (isLiked) {
      postReference.update({
        'Likes': FieldValue.arrayUnion([currentUser.email]),
      });
    } else {
      postReference.update({
        'Likes': FieldValue.arrayRemove([currentUser.email]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: toggleLike,
      child: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('User Posts').doc(widget.postId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final likes = snapshot.data!.data()!['Likes'] as List;
            final nOfLikes = likes.length;
            final String label = nOfLikes == 1 ? 'like' : 'likes';
            final bool isLiked = likes.contains(currentUser.email);
            return Column(
              children: [
                Icon(
                  isLiked ? Icons.favorite : Icons.favorite_outline,
                  color: isLiked ? Colors.red : Theme.of(context).colorScheme.secondary,
                ),
                Text(
                  '${likes.length} $label',
                  style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                )
              ],
            );
          } else {
            return SizedBox(
              height: 50,
              width: 75,
              child: LinearProgressIndicator(
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
                color: Theme.of(context).colorScheme.surface,
                minHeight: 50,
              ),
            );
          }
        },
      ),
    );
  }
}

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
    print('hi');
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

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: toggleLike,
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('User Posts')
            .doc(widget.postId)
            .collection('Comments')
            .doc(widget.commentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List likes = snapshot.data!.data()?['CommentLikes'] ?? [];

            final bool isLiked = likes.contains(currentUser.email);
            return Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiary,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                // alignment: Alignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 5),
                  Icon(
                    isLiked ? Icons.favorite : Icons.favorite_outline,
                    color: isLiked ? Colors.red : Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    likes.isEmpty ? '' : '${likes.length}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ],
              ),
            );
          } else {
            return SizedBox(
              height: 50,
              width: 75,
              child: LinearProgressIndicator(
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
                color: Theme.of(context).colorScheme.surface,
                minHeight: 50,
              ),
            );
          }
        },
      ),
    );
  }
}
