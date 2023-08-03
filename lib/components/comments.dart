import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/settings.dart';
import '../util/timestamp_to_string.dart';

class Comments extends StatelessWidget {
  const Comments({
    super.key,
    required this.postId,
    required this.comments,
  });

  final String postId;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> comments;

  @override
  Widget build(BuildContext context) {
    if (configEnablePostComments) {
      return Column(
        children: comments.map((doc) {
          final commentData = doc.data();
          return Comment(
            text: commentData['CommentText'],
            user: commentData['CommentedBy'],
            time: timestampToString(commentData['CommentTime']),
          );
        }).toList(),
      );

      // ListView.builder(
      //   shrinkWrap: true,
      //   physics: const NeverScrollableScrollPhysics(),
      //   itemCount: comments.length,
      //   itemBuilder: (context, index) {
      //     final commentData = comments[index].data();
      //     return Comment(
      //       text: commentData['CommentText'],
      //       user: commentData['CommentedBy'],
      //       time: timestampToString(commentData['CommentTime']),
      //     );
      //   },
      // );
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
    required this.time,
  });
  final String text;
  final String user;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
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
              Text(user),
              // time
              Text(time, style: const TextStyle(color: Colors.grey)),
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
