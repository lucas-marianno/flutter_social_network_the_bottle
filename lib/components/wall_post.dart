import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/components/comment_button.dart';
import 'package:the_wall/components/comments.dart';
import 'package:the_wall/components/options_modal_bottom_sheet.dart';
import 'package:the_wall/components/show_dialog.dart';
import 'package:the_wall/components/like_button.dart';
import 'package:the_wall/settings.dart';
import 'input_from_modal_bottom_sheet.dart';

class WallPost extends StatefulWidget {
  const WallPost({
    super.key,
    required this.message,
    required this.postOwner,
    required this.postId,
    required this.likes,
    required this.postTimeStamp,
  });

  final String message;
  final String postOwner;
  final String postId;
  final List<String> likes;
  final String postTimeStamp;

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

  void deletePost() {
    // dismiss any keyboard
    FocusManager.instance.primaryFocus?.unfocus();
    if (context.mounted) Navigator.pop(context);

    if (widget.postOwner != currentUser.email) {
      showMyDialog(context,
          title: 'Nope!', content: 'You cannot delete posts made by someone else');
      return;
    }

    // delete post from firebase firestore
    FirebaseFirestore.instance.collection('User Posts').doc(widget.postId).delete();
  }

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
  void initState() {
    isLiked = widget.likes.contains(currentUser.email);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => optionsFromModalBottomSheet(
        context,
        children: [
          ListTile(
            onTap: deletePost,
            leading: const Icon(Icons.delete, color: Colors.white),
            title: const Text('Delete post', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // user + timestamp
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // user.email | username
                !configReplaceEmailWithUsernameOnWallPost
                    ? Text(
                        widget.postOwner,
                        style: TextStyle(color: Colors.grey[900], fontSize: 16),
                      )
                    : StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('User Profile')
                            .doc(widget.postOwner)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              snapshot.data!.data()!['username'] ?? widget.postOwner,
                              style: TextStyle(color: Colors.grey[900], fontSize: 16),
                            );
                          } else {
                            return Expanded(
                              child: LinearProgressIndicator(
                                backgroundColor: Colors.grey[200],
                                color: Colors.grey[100],
                                minHeight: 16,
                              ),
                            );
                          }
                        },
                      ),
                // timestamp
                Text(widget.postTimeStamp, style: const TextStyle(color: Colors.grey))
              ],
            ),
            const SizedBox(height: 10),
            // post text
            Text(widget.message, textAlign: TextAlign.justify),
            const SizedBox(height: 10),
            // interaction buttons + comments
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('User Posts')
                  .doc(widget.postId)
                  .collection('Comments')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final int commentsCount = snapshot.data!.docs.length;
                  final List<QueryDocumentSnapshot<Map<String, dynamic>>> comments =
                      snapshot.data!.docs;
                  return Column(
                    children: [
                      // like + comment buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LikeButton(
                            isLiked: isLiked,
                            onTap: toggleLike,
                            nOfLikes: widget.likes.length,
                          ),
                          const SizedBox(width: 10),
                          CommentButton(
                            onTap: addComment,
                            nOfComments: commentsCount,
                          ),
                        ],
                      ),
                      // comments
                      Comments(postId: widget.postId, comments: comments),
                    ],
                  );
                } else {
                  return LinearProgressIndicator(
                    backgroundColor: Colors.grey[200],
                    color: Colors.grey[100],
                    minHeight: 50,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
