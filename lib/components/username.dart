import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../settings.dart';

class Username extends StatelessWidget {
  const Username({super.key, required this.postOwner});
  final String postOwner;

  @override
  Widget build(BuildContext context) {
    if (!configReplaceEmailWithUsernameOnWallPost) {
      return Text(
        postOwner,
        style: TextStyle(color: Colors.grey[900], fontSize: 16),
      );
    } else {
      return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('User Profile').doc(postOwner).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text(
              snapshot.data!.data()!['username'] ?? postOwner,
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
      );
    }
  }
}
