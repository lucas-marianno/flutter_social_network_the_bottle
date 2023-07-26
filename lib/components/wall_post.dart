import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/components/dialog_message.dart';
import 'package:the_wall/components/like_button.dart';

class WallPost extends StatefulWidget {
  const WallPost({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
  });

  final String message;
  final String user;
  final String postId;
  final List<String> likes;

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  final User currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

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

  void deletePost() async {
    // dismiss any keyboard
    FocusManager.instance.primaryFocus?.unfocus();
    if (context.mounted) Navigator.pop(context);

    if (widget.user != currentUser.email) {
      showDialog(
        context: context,
        builder: (context) => MessageDialog(
          context,
          'You can only delete posts made by you',
        ),
      );
      return;
    }
    // delete post from firebase firestore
    await FirebaseFirestore.instance.collection('User Posts').doc(widget.postId).delete();
  }

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.grey[900],
          showDragHandle: true,
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  ListTile(
                    onTap: deletePost,
                    leading: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    title: const Text('Delete post', style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            );
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white)),
        child: Row(
          children: [
            const SizedBox(width: 10),
            // like button
            Column(
              children: [
                LikeButton(isLiked: isLiked, onTap: toggleLike),
                Text(widget.likes.length.toString())
              ],
            ),

            const SizedBox(width: 15),
            // user + message
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.user, style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 10),
                SizedBox(width: 300, child: Text(widget.message)),
                // ConstrainedBox(
                //   constraints: BoxConstraints.tightForFinite(),
                //   child: RichText(
                //     textAlign: TextAlign.left,
                //     text: TextSpan(text: widget.message, style: TextStyle(color: Colors.black)),
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
