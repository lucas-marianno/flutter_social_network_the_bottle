import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../settings.dart';

class Username extends StatelessWidget {
  const Username({super.key, required this.postOwner});
  final String postOwner;

  @override
  Widget build(BuildContext context) {
    if (!UserConfig().replaceEmailWithUsernameOnWallPost) {
      return Text(
        postOwner,
        style: TextStyle(color: Theme.of(context).colorScheme.onBackground, fontSize: 16),
      );
    } else {
      return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('User Profile').doc(postOwner).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text(
              snapshot.data!.data()!['username'] ?? postOwner,
              style: TextStyle(color: Theme.of(context).colorScheme.onBackground, fontSize: 16),
            );
          } else {
            return Expanded(
              child: LinearProgressIndicator(
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
                color: Theme.of(context).colorScheme.surface,
                minHeight: 16,
              ),
            );
          }
        },
      );
    }
  }
}
