import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../settings.dart';

class Username extends StatelessWidget {
  const Username({
    super.key,
    required this.userEmail,
    this.style,
    this.onTap,
  });
  final String userEmail;
  final void Function()? onTap;
  final TextStyle? style;
  @override
  Widget build(BuildContext context) {
    // TODO: bugfix: colorscheme problems when shown in options in lightmode
    if (!UserConfig().replaceEmailWithUsernameOnWallPost) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Text(
            userEmail,
            style: style,
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
                FirebaseFirestore.instance.collection('User Profile').doc(userEmail).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.data() != null) {
                return Text(snapshot.data!.data()!['username'] ?? userEmail, style: style);
              } else if (snapshot.data?.data() == null) {
                return Text(userEmail, style: style);
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
