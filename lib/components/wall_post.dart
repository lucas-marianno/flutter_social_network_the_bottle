import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/components/comment_button.dart';
import 'package:the_wall/components/comments.dart';
import 'package:the_wall/components/like_button.dart';

class WallPost extends StatefulWidget {
  const WallPost({
    super.key,
    required this.header,
    required this.message,
    required this.postId,
    required this.postPicture,
    this.isFullScreen = false,
  });
  final Widget header;
  final String message;
  final String postId;
  final Widget postPicture;
  final bool isFullScreen;

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  final User currentUser = FirebaseAuth.instance.currentUser!;

  void viewComments() async {
    if (widget.isFullScreen) return;

    await showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: WallPost(
            header: widget.header,
            message: widget.message,
            postId: widget.postId,
            isFullScreen: true,
            postPicture: widget.postPicture,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Theme.of(context).colorScheme.shadow, spreadRadius: 5, blurRadius: 5)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // post header
          widget.header,
          const SizedBox(height: 15),
          // post text
          Text(widget.message, textAlign: TextAlign.justify),
          const SizedBox(height: 15),
          // post picture
          widget.postPicture,
          const SizedBox(height: 15),
          // like + comment buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PostLikeButton(postId: widget.postId),
              ViewCommentsButton(
                onTap: viewComments,
                postId: widget.postId,
              )
            ],
          ),
          // comments
          widget.isFullScreen ? Comments(postId: widget.postId) : Container(),
        ],
      ),
    );
  }
}
