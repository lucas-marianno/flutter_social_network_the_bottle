import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/settings.dart';
import '../util/timestamp_to_string.dart';

// ignore: must_be_immutable
class Comments extends StatelessWidget {
  Comments({
    super.key,
    required this.postId,
  });

  final String postId;
  int nOfComments = 0;
  int get count => nOfComments;

  @override
  Widget build(BuildContext context) {
    if (configEnablePostComments) {
      return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('User Posts')
            .doc(postId)
            .collection('Comments')
            .orderBy('CommentTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            nOfComments = snapshot.data!.docs.length;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final commentData = snapshot.data!.docs[index].data();
                return Comment(
                  text: commentData['CommentText'],
                  user: commentData['CommentedBy'],
                  time: timestampToString(commentData['CommentTime']),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else {
            return Center(
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey[200],
                color: Colors.grey[100],
                minHeight: 50,
              ),
            );
          }
        },
      );
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
