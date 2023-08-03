import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LikeButton extends StatefulWidget {
  const LikeButton({super.key, required this.postId});

  final String postId;

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
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
                  color: isLiked ? Colors.red : Colors.grey,
                ),
                Text(
                  '${likes.length} $label',
                  style: TextStyle(color: Colors.grey[600]),
                )
              ],
            );
          } else {
            return SizedBox(
              height: 50,
              width: 75,
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey[200],
                color: Colors.grey[100],
                minHeight: 50,
              ),
            );
          }
        },
      ),
    );
  }
}
