import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../settings.dart';

class Username extends StatelessWidget {
  const Username({
    super.key,
    required this.postOwner,
    this.onTap,
  });
  final String postOwner;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    if (!UserConfig().replaceEmailWithUsernameOnWallPost) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Text(
            postOwner,
            style: TextStyle(color: Theme.of(context).colorScheme.onBackground, fontSize: 16),
          ),
        ),
      );
    } else {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: StreamBuilder(
            stream:
                FirebaseFirestore.instance.collection('User Profile').doc(postOwner).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.data() != null) {
                return Text(
                  snapshot.data!.data()!['username'] ?? postOwner,
                  style: TextStyle(color: Theme.of(context).colorScheme.onBackground, fontSize: 16),
                );
              } else if (snapshot.data?.data() == null) {
                return Text(
                  postOwner,
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
          ),
        ),
      );
    }
  }
}
