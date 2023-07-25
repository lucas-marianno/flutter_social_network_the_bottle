import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.likes.contains(currentUser.email)) ;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white)),
      child: Row(
        children: [
          const SizedBox(width: 10),
          // like button
          LikeButton(isLiked: false, onTap: () {}),

          const SizedBox(width: 15),
          // user + message
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.user, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 10),
              Text(widget.message),
            ],
          ),
        ],
      ),
    );
  }
}
