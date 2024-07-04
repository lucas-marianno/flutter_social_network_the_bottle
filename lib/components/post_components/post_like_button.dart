import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_bottle/components/show_likes_list.dart';
import 'package:the_bottle/firebase/post/like_post.dart';

class PostLikeButton extends StatefulWidget {
  const PostLikeButton({super.key, required this.postId});

  final String postId;

  @override
  State<PostLikeButton> createState() => _PostLikeButtonState();
}

class _PostLikeButtonState extends State<PostLikeButton> {
  final User currentUser = FirebaseAuth.instance.currentUser!;
  late bool isLiked;

  void toggleLike() {
    setState(() => isLiked = !isLiked);
    likePost(widget.postId, isLiked);
  }

  showLikes() async {
    // get likes list
    final likesList =
        (await FirebaseFirestore.instance.collection('User Posts').doc(widget.postId).get())
            .data()?['Likes'] as List;

    // ignore: use_build_context_synchronously
    showLikesList(context, likesList);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: toggleLike,
      onLongPress: showLikes,
      child: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('User Posts').doc(widget.postId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List likes = snapshot.data!.data()?['Likes'] ?? [];
            final nOfLikes = likes.length;
            final String label = nOfLikes == 1 ? 'like' : 'likes';
            isLiked = likes.contains(currentUser.email);
            return Column(
              children: [
                Icon(
                  isLiked ? Icons.favorite : Icons.favorite_outline,
                  color: isLiked ? Colors.red : null,
                ),
                Text(
                  '$nOfLikes $label',
                )
              ],
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
      ),
    );
  }
}
